import 'package:equatable/equatable.dart';
import 'package:smart_bus/models/Ligne.dart';
import 'package:smart_bus/models/Station.dart';

abstract class LigneState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LigneInitial extends LigneState{}

class LigneLoading extends LigneState{}

class LigneLoaded extends LigneState {
  final List<Ligne> lignes;
  LigneLoaded(this.lignes);

  @override
  List<Object?> get props => [lignes];
}

class LigneError extends LigneState {
  final String error;
  LigneError(this.error);

  @override
  List<Object?> get props => [error];
}

class LigneCreated extends LigneState{
  final Ligne ligne;
  LigneCreated(this.ligne);

  @override
  List<Object?> get props => [ligne];
}

class LigneDeleted extends LigneState{
  final int id;
  LigneDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class LigneUpdated extends LigneState{
  final int id;
  final Map<String, dynamic> patch;
  LigneUpdated(this.id,this.patch);

  @override
  List<Object?> get props => [id,patch];
}

class StationCreated extends LigneState{
  final int ligneId;
  final Station station;
  StationCreated(this.ligneId,this.station);

  @override
  List<Object?> get props => [ligneId,station];
}

class StationUpdated extends LigneState{
  final int ligneId;
  final int stationId;
  final Station station;
  StationUpdated(this.station,this.ligneId,this.stationId);

  @override
  List<Object?> get props => [station,ligneId,stationId];
}

class StationDeleted extends LigneState{
  final int ligneId;
  final int stationId;
  StationDeleted(this.ligneId,this.stationId);

  @override
  List<Object?> get props => [ligneId,stationId];
}