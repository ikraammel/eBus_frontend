import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import '../models/ligne.dart';
import '../models/station.dart';
import '../services/bus_service.dart';

class BusSimulator {
  final FirebaseDatabase _db = GetIt.instance<FirebaseDatabase>();
  final BusService _busService = BusService();
  final Map<String, Timer> _timers = {};
  final Map<String, _BusState> _states = {};

  Future<void> startAll(List<Ligne> lignes) async {
    for (final ligne in lignes) {
      final stations = ligne.stations
          .where((s) => s.latitude != null && s.longitude != null)
          .toList()
        ..sort((a, b) => a.ordre.compareTo(b.ordre));
      if (stations.length < 2) continue;

      final busKey = 'bus_${ligne.id}';

      // Récupère l'immatriculation depuis l'API Spring Boot
      String immatriculation = '';
      try {
        final buses = await _busService.getBusesByLigne(ligne.id!);
        if (buses.isNotEmpty) {
          immatriculation = buses.first.immatriculation;
        }
      } catch (_) {
        immatriculation = 'BUS-L${ligne.id}';
      }

      _states[busKey] = _BusState(
        stations: stations,
        immatriculation: immatriculation,
      );
      _startBus(busKey, ligne, immatriculation);
    }
  }

  void _startBus(String busKey, Ligne ligne, String immatriculation) {
    _timers[busKey] = Timer.periodic(const Duration(seconds: 2), (_) async {
      final state = _states[busKey];
      if (state == null) return;

      final pos = state.nextPosition();
      final vitesse = state.estimatedSpeed;

      await _db.ref('buses/$busKey').update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'ligneId': ligne.id,
        'numero': ligne.numero,
        'immatriculation': immatriculation, // NOUVEAU
        'actif': true,
        'statut': 'en_service',            // NOUVEAU
        'vitesse': vitesse,                 // NOUVEAU
        'prochainArretIndex': state.nextStationIndex, // NOUVEAU
      });
    });
  }

  void stop(String busKey) {
    _timers[busKey]?.cancel();
    _timers.remove(busKey);
  }

  void stopAll() {
    for (final t in _timers.values) t.cancel();
    _timers.clear();
  }
}


class _BusState {
  final List<Station> stations;
  final String immatriculation;

  int _segmentIndex = 0;
  double _progress = 0.0;
  bool _forward = true;
  _LatLng? _lastPos;
  int _lastTime = 0;
  double _estimatedSpeed = 30.0;

  _BusState({required this.stations, required this.immatriculation});

  double get estimatedSpeed => _estimatedSpeed;

  int get nextStationIndex {
    if (_forward) {
      return (_segmentIndex + 1).clamp(0, stations.length - 1);
    } else {
      return _segmentIndex.clamp(0, stations.length - 1);
    }
  }

  _LatLng nextPosition() {
    final from = stations[_segmentIndex];
    final to = stations[_segmentIndex + (_forward ? 1 : -1)];

    final lat =
        from.latitude! + (to.latitude! - from.latitude!) * _progress;
    final lng =
        from.longitude! + (to.longitude! - from.longitude!) * _progress;

    // Calcul vitesse estimée (distance / temps)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastPos != null && _lastTime > 0) {
      final dt = (now - _lastTime) / 3600000; // heures
      final dist = _haversine(_lastPos!.latitude, _lastPos!.longitude, lat, lng);
      if (dt > 0 && dist > 0) {
        _estimatedSpeed = (dist / dt).clamp(0.0, 90.0);
      }
    }
    _lastPos = _LatLng(lat, lng);
    _lastTime = now;

    _progress += 0.05;
    if (_progress >= 1.0) {
      _progress = 0.0;
      if (_forward) {
        _segmentIndex++;
        if (_segmentIndex >= stations.length - 1) {
          _forward = false;
          _segmentIndex = stations.length - 2;
        }
      } else {
        _segmentIndex--;
        if (_segmentIndex < 0) {
          _forward = true;
          _segmentIndex = 0;
        }
      }
    }
    return _LatLng(lat, lng);
  }

  /// Distance entre deux points GPS en km (formule de Haversine)
  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}

class _LatLng {
  final double latitude;
  final double longitude;
  _LatLng(this.latitude, this.longitude);
}