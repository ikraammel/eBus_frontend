// lib/bloc/bus_tracking/bus_tracking_bloc.dart

import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../models/bus_position.dart';
import '../../models/ligne.dart';
import '../../models/station.dart';
import '../../services/realtime_bus_service.dart';
import '../../services/horaire_service.dart';
import '../../models/horaire.dart';
import 'bus_tracking_event.dart';
import 'bus_tracking_state.dart';

class BusTrackingBloc extends Bloc<BusTrackingEvent, BusTrackingState> {
  final RealtimeBusService _realtimeService;
  final HoraireService _horaireService;

  StreamSubscription<BusPosition?>? _positionSub;
  Ligne? _ligne;
  List<Horaire> _horaires = [];
  final List<LatLng> _trajectory = [];
  static const int _maxTrajectoryPoints = 200;

  BusTrackingBloc({
    required RealtimeBusService realtimeService,
    required HoraireService horaireService,
  })  : _realtimeService = realtimeService,
        _horaireService = horaireService,
        super(BusTrackingInitial()) {

    on<StartBusTracking>((event, emit) async {
      _trajectory.clear();
      await _positionSub?.cancel();

      _positionSub = _realtimeService
          .watchSingleBus(event.busKey)
          .listen((pos) {
        if (pos != null) {
          add(BusPositionReceived(
            latitude: pos.latitude,
            longitude: pos.longitude,
            statut: pos.statut,
            vitesse: pos.vitesse,
            updatedAt: pos.updatedAt,
          ));
        }
      });
    });

    // ─── BusPositionReceived ─────────────────────────────────────────────────
    on<BusPositionReceived>((event, emit) {
      if (state is! BusTrackingActive && state is! BusTrackingInitial) return;

      // Ajoute la nouvelle position à la trajectoire
      final newPoint = LatLng(event.latitude, event.longitude);
      _trajectory.add(newPoint);
      if (_trajectory.length > _maxTrajectoryPoints) {
        _trajectory.removeAt(0);
      }

      // Cherche le prochain arrêt (station la plus proche dans le sens du trajet)
      Station? prochainArret;
      if (_ligne != null) {
        prochainArret = _findNextStation(
          event.latitude,
          event.longitude,
          _ligne!.stations,
        );
      }

      // Calcule le retard par rapport aux horaires
      int? retardMin;
      if (_horaires.isNotEmpty) {
        retardMin = _estimateDelay(_horaires);
      }

      final currentBusPos = state is BusTrackingActive
          ? (state as BusTrackingActive).currentPosition
          : null;

      // Construit la BusPosition mise à jour
      final updatedPos = currentBusPos != null
          ? BusPosition(
        busKey: currentBusPos.busKey,
        ligneId: currentBusPos.ligneId,
        numero: currentBusPos.numero,
        immatriculation: currentBusPos.immatriculation,
        latitude: event.latitude,
        longitude: event.longitude,
        actif: true,
        updatedAt: event.updatedAt,
        statut: event.statut,
        vitesse: event.vitesse,
      )
          : BusPosition(
        busKey: '',
        ligneId: 0,
        numero: '',
        latitude: event.latitude,
        longitude: event.longitude,
        actif: true,
        updatedAt: event.updatedAt,
        statut: event.statut,
        vitesse: event.vitesse,
      );

      if (state is BusTrackingActive) {
        emit((state as BusTrackingActive).copyWith(
          currentPosition: updatedPos,
          trajectory: List<LatLng>.from(_trajectory),
          prochainArret: prochainArret,
          retardMinutes: retardMin,
        ));
      } else {
        emit(BusTrackingActive(
          busKey: '',
          currentPosition: updatedPos,
          trajectory: List<LatLng>.from(_trajectory),
          prochainArret: prochainArret,
          retardMinutes: retardMin,
        ));
      }
    });

    // ─── StopBusTracking ─────────────────────────────────────────────────────
    on<StopBusTracking>((event, emit) async {
      await _positionSub?.cancel();
      _positionSub = null;
      _trajectory.clear();
      emit(BusTrackingInitial());
    });
  }

  /// Charge la ligne et les horaires associés au bus suivi
  Future<void> loadLigneData(Ligne ligne) async {
    _ligne = ligne;
    try {
      _horaires = await _horaireService.getHorairesByLigne(ligne.id!);
    } catch (_) {
      _horaires = [];
    }
  }

  // ─── Trouve la prochaine station selon la position GPS ─────────────────────
  Station? _findNextStation(
      double lat, double lng, List<Station> stations) {
    if (stations.isEmpty) return null;

    final stationsWithCoords = stations
        .where((s) => s.latitude != null && s.longitude != null)
        .toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));

    if (stationsWithCoords.isEmpty) return null;

    // Trouve la station la plus proche
    double minDist = double.infinity;
    int closestIndex = 0;
    for (int i = 0; i < stationsWithCoords.length; i++) {
      final s = stationsWithCoords[i];
      final d = _distanceKm(lat, lng, s.latitude!, s.longitude!);
      if (d < minDist) {
        minDist = d;
        closestIndex = i;
      }
    }

    // La prochaine station = la suivante après la plus proche
    if (closestIndex + 1 < stationsWithCoords.length) {
      return stationsWithCoords[closestIndex + 1];
    }
    return stationsWithCoords.last;
  }

  // ─── Estime le retard en minutes par rapport aux horaires ──────────────────
  int? _estimateDelay(List<Horaire> horaires) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (final h in horaires) {
      // Parse "HH:mm" → minutes depuis minuit
      final parts = h.heureDepart.split(':');
      if (parts.length < 2) continue;
      final departMinutes =
          (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
      final diff = nowMinutes - departMinutes;
      if (diff >= 0 && diff < 60) {
        return diff > 2 ? diff : 0;
      }
    }
    return null;
  }

  // ─── Distance Haversine en km ───────────────────────────────────────────────
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    return super.close();
  }
}