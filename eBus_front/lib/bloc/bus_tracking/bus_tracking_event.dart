
import 'package:equatable/equatable.dart';

abstract class BusTrackingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Lance le suivi d'un bus précis
class StartBusTracking extends BusTrackingEvent {
  final String busKey;
  final int ligneId;
  StartBusTracking(this.busKey, this.ligneId);

  @override
  List<Object?> get props => [busKey, ligneId];
}

/// Arrête le suivi
class StopBusTracking extends BusTrackingEvent {}

class BusPositionReceived extends BusTrackingEvent {
  final double latitude;
  final double longitude;
  final String statut;
  final double? vitesse;
  final int? updatedAt;
  BusPositionReceived({
    required this.latitude,
    required this.longitude,
    required this.statut,
    this.vitesse,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [latitude, longitude, statut, updatedAt];
}