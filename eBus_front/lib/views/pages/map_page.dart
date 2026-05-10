import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/bus_position.dart';
import 'package:smart_bus/models/horaire.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/services/horaire_service.dart';
import 'package:smart_bus/services/realtime_bus_service.dart';
import 'package:smart_bus/views/pages/bus_detail_sheet.dart';

import '../../models/bus_simulator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, this.showBackButton = false});
  final bool showBackButton;

  @override
  State<MapPage> createState() => _MapPageState();
}

final _simulator = BusSimulator();

class _MapPageState extends State<MapPage> {
  final _realtimeService = RealtimeBusService();
  final _horaireService = HoraireService();
  final _mapController = MapController();

  List<BusPosition> _busPositions = [];
  StreamSubscription? _busSub;
  bool _simulatorStarted = false;

  Ligne? _selectedLigne;
  List<Horaire> _horaires = [];
  bool _loadingHoraires = false;

  // Centre sur Safi
  static const _defaultCenter = LatLng(32.2994, -9.2372);

  @override
  void initState() {
    super.initState();

    // Écoute temps réel tous les bus
    _busSub = _realtimeService.watchAllBuses().listen((buses) {
      if (mounted) setState(() => _busPositions = buses);
    });

    // Démarre le simulateur avec les lignes déjà chargées
    final ligneState = context.read<LigneBloc>().state;
    if (ligneState is LigneLoaded && !_simulatorStarted) {
      _simulatorStarted = true;
      _simulator.startAll(ligneState.lignes);
    } else if (ligneState is! LigneLoaded) {
      // Déclenche le chargement des lignes si pas encore fait
      context.read<LigneBloc>().add(LoadLignes());
    }
  }

  @override
  void dispose() {
    _simulator.stopAll();
    _busSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ─── Sélection de ligne ──────────────────────────────────────────────────────

  Future<void> _onLigneSelected(Ligne? ligne) async {
    setState(() {
      _selectedLigne = ligne;
      _horaires = [];
    });

    if (ligne == null) return;

    setState(() => _loadingHoraires = true);
    try {
      final h = await _horaireService.getHorairesByLigne(ligne.id!);
      if (mounted) setState(() => _horaires = h);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingHoraires = false);
    }

    final stationsWithCoords =
    ligne.stations.where((s) => s.latitude != null && s.longitude != null);
    if (stationsWithCoords.isNotEmpty) {
      final first = stationsWithCoords.first;
      _mapController.move(LatLng(first.latitude!, first.longitude!), 13.5);
    } else {
      // Même sans coords dans les stations, centre sur Safi
      _mapController.move(_defaultCenter, 13.0);
    }
  }

  // ─── Bus visibles selon filtre ligne ────────────────────────────────────────

  List<BusPosition> get _visibleBuses => _selectedLigne == null
      ? _busPositions
      : _busPositions.where((b) => b.ligneId == _selectedLigne!.id).toList();

  // ─── Tap sur un bus → ouvre BusDetailSheet ────────────────────────────────

  void _onBusTapped(BusPosition bus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BusDetailSheet(bus: bus),
    );
  }

  // ─── Construction des markers de bus ────────────────────────────────────────

  List<Marker> _buildBusMarkers() {
    return _visibleBuses.map((bus) {
      final color = _busColor(bus.statut);
      final label = bus.immatriculation.isNotEmpty
          ? bus.immatriculation
          : 'L${bus.numero}';

      return Marker(
        point: LatLng(bus.latitude, bus.longitude),
        width: 90,
        height: 72,
        child: GestureDetector(
          onTap: () => _onBusTapped(bus),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Point vert "en direct" si mis à jour récemment
              if (bus.isRecent)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              Icon(Icons.directions_bus, color: color, size: 36),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ─── COULEUR : vert pour en_service ─────────────────────────────────────────

  Color _busColor(String statut) {
    switch (statut) {
      case 'en_retard':
        return Colors.orange;
      case 'inactif':
        return Colors.grey;
      case 'en_service':
      default:
        return Colors.green; // ✅ VERT pour les bus actifs
    }
  }

  // ─── Markers des stations ────────────────────────────────────────────────────

  List<Marker> _buildStationMarkers() {
    if (_selectedLigne == null) return [];
    return _selectedLigne!.stations
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => Marker(
      point: LatLng(s.latitude!, s.longitude!),
      width: 140,
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on,
              color: AppColors.darkBlue, size: 28),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 1))
              ],
            ),
            child: Text(
              s.nom,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ))
        .toList();
  }

  // ─── Polylines ───────────────────────────────────────────────────────────────

  List<Polyline> _buildPolylines() {
    if (_selectedLigne == null) return [];
    final points = _selectedLigne!.stations
        .where((s) => s.latitude != null && s.longitude != null)
        .toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));

    if (points.length < 2) return [];

    return [
      Polyline(
        points: points.map((s) => LatLng(s.latitude!, s.longitude!)).toList(),
        color: AppColors.darkBlue,
        strokeWidth: 3.5,
      ),
    ];
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text(
          'Suivi en temps réel',
          style: TextStyle(
              color: AppColors.darkBlue, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: const Icon(Icons.directions_bus,
                  size: 16, color: Colors.white),
              label: Text(
                '${_visibleBuses.length} bus',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.green,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: BlocListener<LigneBloc, LigneState>(
        // ⬇️ Démarre le simulateur dès que les lignes sont chargées
        listener: (context, state) {
          if (state is LigneLoaded && !_simulatorStarted) {
            _simulatorStarted = true;
            _simulator.startAll(state.lignes);
          }
        },
        child: Column(
          children: [
            // ── Légende statuts ──────────────────────────────────────────────
            _StatusLegend(busPositions: _busPositions),

            // ── Sélecteur de ligne ───────────────────────────────────────────
            _LigneFilterBar(
              selectedLigne: _selectedLigne,
              onSelected: _onLigneSelected,
            ),

            // ── Carte ────────────────────────────────────────────────────────
            Expanded(
              flex: _selectedLigne != null ? 3 : 5,
              child: FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.ebus.smart_bus',
                  ),
                  PolylineLayer(polylines: _buildPolylines()),
                  MarkerLayer(
                    markers: [
                      ..._buildStationMarkers(),
                      ..._buildBusMarkers(),
                    ],
                  ),
                ],
              ),
            ),

            // ── Panel horaires ───────────────────────────────────────────────
            if (_selectedLigne != null)
              _HorairesPanel(
                ligne: _selectedLigne!,
                horaires: _horaires,
                loading: _loadingHoraires,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Légende des statuts ──────────────────────────────────────────────────────

class _StatusLegend extends StatelessWidget {
  final List<BusPosition> busPositions;
  const _StatusLegend({required this.busPositions});

  @override
  Widget build(BuildContext context) {
    final enService =
        busPositions.where((b) => b.statut == 'en_service').length;
    final enRetard =
        busPositions.where((b) => b.statut == 'en_retard').length;
    final inactifs =
        busPositions.where((b) => b.statut == 'inactif').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          _LegendDot(color: Colors.green, label: 'En service ($enService)'),
          const SizedBox(width: 12),
          _LegendDot(color: Colors.orange, label: 'Retard ($enRetard)'),
          const SizedBox(width: 12),
          _LegendDot(color: Colors.grey, label: 'Inactif ($inactifs)'),
          const Spacer(),
          const Icon(Icons.touch_app, size: 13, color: Colors.grey),
          const SizedBox(width: 3),
          const Text('Tap = détails',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}

// ─── Widget sélecteur de lignes ───────────────────────────────────────────────

class _LigneFilterBar extends StatelessWidget {
  final Ligne? selectedLigne;
  final ValueChanged<Ligne?> onSelected;

  const _LigneFilterBar({
    required this.selectedLigne,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LigneBloc, LigneState>(
      builder: (context, state) {
        if (state is! LigneLoaded) {
          return const SizedBox(
            height: 44,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            children: [
              _Chip(
                label: 'Tous',
                selected: selectedLigne == null,
                onTap: () => onSelected(null),
                icon: Icons.map,
              ),
              ...state.lignes.map(
                    (l) => _Chip(
                  label: 'Ligne ${l.numero}',
                  selected: selectedLigne?.id == l.id,
                  onTap: () => onSelected(l),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkBlue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14,
                  color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panel horaires ───────────────────────────────────────────────────────────

class _HorairesPanel extends StatelessWidget {
  final Ligne ligne;
  final List<Horaire> horaires;
  final bool loading;

  const _HorairesPanel({
    required this.ligne,
    required this.horaires,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.schedule,
                    size: 18, color: AppColors.darkBlue),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Ligne ${ligne.numero}  •  ${ligne.startPoint} → ${ligne.endPoint}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.darkBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${ligne.stations.length} arrêts',
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          if (loading)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (horaires.isEmpty)
            const Expanded(
              child: Center(
                child: Text('Aucun horaire disponible',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: horaires.length,
                itemBuilder: (_, i) => _HoraireCard(horaires[i]),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> seedFirebaseBuses(List<Ligne> lignes) async {
  final db = GetIt.instance<FirebaseDatabase>();
  for (final ligne in lignes) {
    final stations = ligne.stations
        .where((s) => s.latitude != null && s.longitude != null)
        .toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
    if (stations.isEmpty) continue;
    final firstStation = stations.first;
    await db.ref('buses/bus_${ligne.id}').set({
      'ligneId': ligne.id,
      'numero': ligne.numero,
      'immatriculation': 'BUS-L${ligne.numero}',
      'latitude': firstStation.latitude,
      'longitude': firstStation.longitude,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'actif': true,
      'statut': 'en_service',
      'vitesse': 0.0,
    });
  }
}

class _HoraireCard extends StatelessWidget {
  final Horaire h;
  const _HoraireCard(this.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBlue.withOpacity(0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(h.heureDepart,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.darkBlue)),
          const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
          Text(h.heureArrivee,
              style:
              const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(
            h.jours,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}