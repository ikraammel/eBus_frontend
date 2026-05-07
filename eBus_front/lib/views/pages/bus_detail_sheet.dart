import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_bus/bloc/bus_tracking/bus_tracking_bloc.dart';
import 'package:smart_bus/bloc/bus_tracking/bus_tracking_event.dart';
import 'package:smart_bus/bloc/bus_tracking/bus_tracking_state.dart';
import 'package:smart_bus/bloc/ligne/ligne_bloc.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/constants/app_colors.dart';
import 'package:smart_bus/models/bus_position.dart';
import 'package:smart_bus/models/ligne.dart';
import 'package:smart_bus/services/horaire_service.dart';
import 'package:smart_bus/services/realtime_bus_service.dart';

/// Ouvrir ce sheet :
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (_) => BusDetailSheet(bus: busPosition),
/// );
/// ```
class BusDetailSheet extends StatefulWidget {
  final BusPosition bus;

  const BusDetailSheet({super.key, required this.bus});

  @override
  State<BusDetailSheet> createState() => _BusDetailSheetState();
}

class _BusDetailSheetState extends State<BusDetailSheet> {
  late final BusTrackingBloc _trackingBloc;
  final MapController _mapController = MapController();
  Ligne? _ligne;
  bool _followBus = true; // Auto-centre la carte sur le bus

  @override
  void initState() {
    super.initState();

    _trackingBloc = BusTrackingBloc(
      realtimeService: RealtimeBusService(),
      horaireService: HoraireService(),
    );

    // Trouve la ligne correspondante
    final ligneState = context.read<LigneBloc>().state;
    if (ligneState is LigneLoaded) {
      try {
        _ligne = ligneState.lignes
            .firstWhere((l) => l.id == widget.bus.ligneId);
        _trackingBloc.loadLigneData(_ligne!);
      } catch (_) {}
    }

    // Démarre le suivi
    _trackingBloc.add(StartBusTracking(
      widget.bus.busKey,
      widget.bus.ligneId,
    ));
  }

  @override
  void dispose() {
    _trackingBloc.add(StopBusTracking());
    _trackingBloc.close();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _trackingBloc,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // ── Poignée ──────────────────────────────────────────────────
                const _DragHandle(),

                // ── En-tête du bus ───────────────────────────────────────────
                _BusHeader(bus: widget.bus),

                // ── Contenu scrollable ───────────────────────────────────────
                Expanded(
                  child: BlocBuilder<BusTrackingBloc, BusTrackingState>(
                    builder: (context, state) {
                      return ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          // Mini-carte de suivi
                          _TrackingMap(
                            state: state,
                            bus: widget.bus,
                            ligne: _ligne,
                            mapController: _mapController,
                            followBus: _followBus,
                            onFollowToggled: (v) =>
                                setState(() => _followBus = v),
                          ),

                          // Panel informations
                          _InfoPanel(state: state, bus: widget.bus),

                          // Prochain arrêt
                          if (state is BusTrackingActive &&
                              state.prochainArret != null)
                            _NextStopCard(state: state),

                          // Liste des arrêts de la ligne
                          if (_ligne != null)
                            _StopsTimeline(ligne: _ligne!, currentPos: state),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Poignée ─────────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ─── En-tête ─────────────────────────────────────────────────────────────────

class _BusHeader extends StatelessWidget {
  final BusPosition bus;
  const _BusHeader({required this.bus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          // Icône bus
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_bus,
                color: AppColors.darkBlue, size: 28),
          ),
          const SizedBox(width: 14),
          // Immatriculation + ligne
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.immatriculation.isNotEmpty
                      ? bus.immatriculation
                      : 'Bus ${bus.numero}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ligne ${bus.numero}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Badge statut
          _StatutBadge(statut: bus.statut),
        ],
      ),
    );
  }
}

// ─── Badge statut ─────────────────────────────────────────────────────────────

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (statut) {
      case 'en_retard':
        color = Colors.orange;
        label = 'En retard';
        break;
      case 'inactif':
        color = Colors.grey;
        label = 'Inactif';
        break;
      default:
        color = Colors.green;
        label = 'En service';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Mini-carte de suivi ──────────────────────────────────────────────────────

class _TrackingMap extends StatefulWidget {
  final BusTrackingState state;
  final BusPosition bus;
  final Ligne? ligne;
  final MapController mapController;
  final bool followBus;
  final ValueChanged<bool> onFollowToggled;

  const _TrackingMap({
    required this.state,
    required this.bus,
    required this.ligne,
    required this.mapController,
    required this.followBus,
    required this.onFollowToggled,
  });

  @override
  State<_TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<_TrackingMap> {
  @override
  void didUpdateWidget(_TrackingMap old) {
    super.didUpdateWidget(old);
    // Auto-centre sur le bus si followBus est activé
    if (widget.followBus && widget.state is BusTrackingActive) {
      final s = widget.state as BusTrackingActive;
      try {
        widget.mapController.move(
          LatLng(s.currentPosition.latitude, s.currentPosition.longitude),
          15.5,
        );
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = widget.state;
    final initLat = widget.bus.latitude;
    final initLng = widget.bus.longitude;

    // Arrêts de la ligne
    final stationMarkers = widget.ligne?.stations
        .where((s) => s.latitude != null && s.longitude != null)
        .map((s) => Marker(
      point: LatLng(s.latitude!, s.longitude!),
      width: 130,
      height: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle,
              size: 10, color: AppColors.darkBlue.withOpacity(0.7)),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 4)
              ],
            ),
            child: Text(
              s.nom,
              style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ))
        .toList() ??
        [];

    // Polyline du trajet de la ligne
    final polylines = <Polyline>[];
    if (widget.ligne != null) {
      final pts = widget.ligne!.stations
          .where((s) => s.latitude != null && s.longitude != null)
          .toList()
        ..sort((a, b) => a.ordre.compareTo(b.ordre));
      if (pts.length >= 2) {
        polylines.add(Polyline(
          points: pts.map((s) => LatLng(s.latitude!, s.longitude!)).toList(),
          color: AppColors.darkBlue.withOpacity(0.3),
          strokeWidth: 3,
        ));
      }
    }

    // Trajectoire parcourue par le bus (en rouge)
    if (trackingState is BusTrackingActive &&
        trackingState.trajectory.length >= 2) {
      polylines.add(Polyline(
        points: trackingState.trajectory,
        color: Colors.red.withOpacity(0.8),
        strokeWidth: 3.5,
      ));
    }

    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          FlutterMap(
            mapController: widget.mapController,
            options: MapOptions(
              initialCenter: LatLng(initLat, initLng),
              initialZoom: 15.5,
              onMapEvent: (_) {
                // Si l'utilisateur bouge la carte → désactive le suivi auto
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ebus.smart_bus',
              ),
              PolylineLayer(polylines: polylines),
              MarkerLayer(markers: stationMarkers),
              // Marker du bus (position actuelle)
              MarkerLayer(
                markers: [
                  Marker(
                    point: trackingState is BusTrackingActive
                        ? LatLng(
                        trackingState.currentPosition.latitude,
                        trackingState.currentPosition.longitude)
                        : LatLng(initLat, initLng),
                    width: 80,
                    height: 80,
                    child: _AnimatedBusMarker(
                      immatriculation: widget.bus.immatriculation,
                      numero: widget.bus.numero,
                      isEnRetard: trackingState is BusTrackingActive
                          ? trackingState.isEnRetard
                          : false,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bouton "Suivre le bus"
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton.small(
              heroTag: 'follow_toggle',
              backgroundColor: widget.followBus
                  ? AppColors.darkBlue
                  : Colors.white,
              onPressed: () =>
                  widget.onFollowToggled(!widget.followBus),
              child: Icon(
                Icons.my_location,
                color:
                widget.followBus ? Colors.white : AppColors.darkBlue,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Marker animé du bus ──────────────────────────────────────────────────────

class _AnimatedBusMarker extends StatefulWidget {
  final String immatriculation;
  final String numero;
  final bool isEnRetard;

  const _AnimatedBusMarker({
    required this.immatriculation,
    required this.numero,
    required this.isEnRetard,
  });

  @override
  State<_AnimatedBusMarker> createState() => _AnimatedBusMarkerState();
}

class _AnimatedBusMarkerState extends State<_AnimatedBusMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isEnRetard ? Colors.orange : Colors.red;
    final label = widget.immatriculation.isNotEmpty
        ? widget.immatriculation
        : widget.numero;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: _pulseAnim.value,
        child: child,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus, color: color, size: 36),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panel informations ───────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final BusTrackingState state;
  final BusPosition bus;

  const _InfoPanel({required this.state, required this.bus});

  @override
  Widget build(BuildContext context) {
    final vitesse = state is BusTrackingActive
        ? (state as BusTrackingActive).currentPosition.vitesse
        : null;

    final ponctualite = state is BusTrackingActive
        ? (state as BusTrackingActive).ponctualiteLabel
        : 'Chargement...';

    final isEnRetard =
        state is BusTrackingActive && (state as BusTrackingActive).isEnRetard;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _InfoTile(
            icon: Icons.speed,
            label: 'Vitesse',
            value: vitesse != null
                ? '${vitesse.toStringAsFixed(0)} km/h'
                : '— km/h',
          ),
          const SizedBox(width: 12),
          _InfoTile(
            icon: Icons.schedule,
            label: 'Ponctualité',
            value: ponctualite,
            valueColor: isEnRetard ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 12),
          _InfoTile(
            icon: Icons.update,
            label: 'MAJ',
            value: _formatUpdatedAt(
              state is BusTrackingActive
                  ? (state as BusTrackingActive).currentPosition.updatedAt
                  : bus.updatedAt,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUpdatedAt(int? ms) {
    if (ms == null) return '—';
    final diff =
        DateTime.now().millisecondsSinceEpoch - ms;
    if (diff < 5000) return 'À l\'instant';
    if (diff < 60000) return '${(diff / 1000).round()}s';
    return '${(diff / 60000).round()} min';
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.darkBlue.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.darkBlue),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade500)),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? AppColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Prochain arrêt ───────────────────────────────────────────────────────────

class _NextStopCard extends StatelessWidget {
  final BusTrackingActive state;
  const _NextStopCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prochain arrêt',
                    style:
                    TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  state.prochainArret!.nom,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Timeline des arrêts ──────────────────────────────────────────────────────

class _StopsTimeline extends StatelessWidget {
  final Ligne ligne;
  final BusTrackingState currentPos;

  const _StopsTimeline({required this.ligne, required this.currentPos});

  @override
  Widget build(BuildContext context) {
    final stations = ligne.stations.toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));

    final nextStopNom = currentPos is BusTrackingActive
        ? (currentPos as BusTrackingActive).prochainArret?.nom
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arrêts de la ligne ${ligne.numero}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.darkBlue),
          ),
          const SizedBox(height: 10),
          ...stations.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            final isNext = s.nom == nextStopNom;
            final isFirst = i == 0;
            final isLast = i == stations.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne verticale + point
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      if (!isFirst)
                        Container(
                          width: 2,
                          height: 14,
                          color: AppColors.darkBlue.withOpacity(0.2),
                        ),
                      Container(
                        width: isNext ? 14 : 10,
                        height: isNext ? 14 : 10,
                        decoration: BoxDecoration(
                          color: isNext
                              ? Colors.green
                              : isFirst || isLast
                              ? AppColors.darkBlue
                              : AppColors.darkBlue.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 14,
                          color: AppColors.darkBlue.withOpacity(0.2),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Nom de l'arrêt
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      s.nom,
                      style: TextStyle(
                        fontSize: isNext ? 14 : 13,
                        fontWeight: isNext
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isNext
                            ? Colors.green
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
                if (isNext)
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(Icons.directions_bus,
                        size: 14, color: Colors.green),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}