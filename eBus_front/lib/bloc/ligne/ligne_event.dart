import 'package:equatable/equatable.dart';

import '../../models/ligne.dart';
import '../../models/station.dart';

abstract class LigneEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoadLignes extends LigneEvent {}

class SearchLignes extends LigneEvent{
  final String query;
  SearchLignes(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateLigne extends LigneEvent{
  final Ligne ligne;
  CreateLigne(this.ligne);

  @override
  List<Object?> get props => [ligne];
}

class DeleteLine extends LigneEvent{
  final int id;
  DeleteLine(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateLine extends LigneEvent{
  final int id;
  final Ligne patch;
  UpdateLine(this.id,this.patch);

  @override
  List<Object?> get props => [id,patch];
}

class DeleteStation extends LigneEvent{
  final int ligneId;
  final int stationId;
  DeleteStation(this.ligneId,this.stationId);

  @override
  List<Object?> get props => [ligneId,stationId];
}

class CreateStation extends LigneEvent{
  final int ligneId;
  final Station station;
  CreateStation(this.ligneId,this.station);

  @override
  List<Object?> get props => [ligneId,station];
}

class UpdateStation extends LigneEvent{
  final int ligneId;
  final int stationId;
  final Station station;
  UpdateStation(this.station,this.ligneId,this.stationId);

  @override
  List<Object?> get props => [station,ligneId,stationId];
}

