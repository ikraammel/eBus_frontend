import 'package:equatable/equatable.dart';
import 'package:smart_bus/models/Ligne.dart';

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