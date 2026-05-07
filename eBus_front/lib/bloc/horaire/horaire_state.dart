import 'package:equatable/equatable.dart';
import '../../models/horaire.dart';

abstract class HoraireState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HoraireInitial extends HoraireState {}

class HoraireLoading extends HoraireState {}

class HoraireLoaded extends HoraireState {
  final List<Horaire> horaires;
  final int ligneId;
  HoraireLoaded(this.horaires, this.ligneId);

  @override
  List<Object?> get props => [horaires, ligneId];
}

class HoraireError extends HoraireState {
  final String error;
  HoraireError(this.error);

  @override
  List<Object?> get props => [error];
}

class HoraireCreated extends HoraireState {
  final Horaire horaire;
  HoraireCreated(this.horaire);

  @override
  List<Object?> get props => [horaire];
}

class HoraireUpdated extends HoraireState {
  final Horaire horaire;
  HoraireUpdated(this.horaire);

  @override
  List<Object?> get props => [horaire];
}

class HoraireDeleted extends HoraireState {
  final int id;
  HoraireDeleted(this.id);

  @override
  List<Object?> get props => [id];
}