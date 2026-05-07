import 'package:equatable/equatable.dart';
import '../../models/horaire.dart';

abstract class HoraireEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHoraires extends HoraireEvent {
  final int ligneId;
  LoadHoraires(this.ligneId);

  @override
  List<Object?> get props => [ligneId];
}

class CreateHoraire extends HoraireEvent {
  final Horaire horaire;
  CreateHoraire(this.horaire);

  @override
  List<Object?> get props => [horaire];
}

class UpdateHoraire extends HoraireEvent {
  final int id;
  final Horaire horaire;
  UpdateHoraire(this.id, this.horaire);

  @override
  List<Object?> get props => [id, horaire];
}

class DeleteHoraire extends HoraireEvent {
  final int id;
  DeleteHoraire(this.id);

  @override
  List<Object?> get props => [id];
}