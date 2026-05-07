
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../models/bus_position.dart';
import '../../models/station.dart';

abstract class BusTrackingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BusTrackingInitial extends BusTrackingState {}

class BusTrackingActive extends BusTrackingState {
  final String busKey;
  final BusPosition currentPosition;

  /// Historique des positions pour dessiner la trajectoire
  final List<LatLng> trajectory;

  /// Prochaine station estimée
  final Station? prochainArret;

  /// Retard estimé en minutes (null = inconnu)
  final int? retardMinutes;

  BusTrackingActive({
    required this.busKey,
    required this.currentPosition,
    this.trajectory = const [],
    this.prochainArret,
    this.retardMinutes,
  });

  BusTrackingActive copyWith({
    BusPosition? currentPosition,
    List<LatLng>? trajectory,
    Station? prochainArret,
    int? retardMinutes,
  }) {
    return BusTrackingActive(
      busKey: busKey,
      currentPosition: currentPosition ?? this.currentPosition,
      trajectory: trajectory ?? this.trajectory,
      prochainArret: prochainArret ?? this.prochainArret,
      retardMinutes: retardMinutes,
    );
  }

  /// Libellé de ponctualité affiché dans l'UI
  String get ponctualiteLabel {
    if (retardMinutes == null) return 'À l\'heure';
    if (retardMinutes! <= 0) return 'À l\'heure';
    if (retardMinutes! < 5) return '+${retardMinutes} min';
    return 'En retard (${retardMinutes} min)';
  }

  bool get isEnRetard => retardMinutes != null && retardMinutes! > 2;

  @override
  List<Object?> get props =>
      [busKey, currentPosition, trajectory, prochainArret, retardMinutes];
}

class BusTrackingError extends BusTrackingState {
  final String message;
  BusTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}