import 'package:equatable/equatable.dart';
import '../../models/dossier.dart';

abstract class AdminDossierState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminDossierInitial extends AdminDossierState {}

class AdminDossierLoading extends AdminDossierState {}

class AdminDossierLoaded extends AdminDossierState {
  final List<Dossier> dossiers;
  AdminDossierLoaded(this.dossiers);

  @override
  List<Object?> get props => [dossiers];
}

class AdminDossierActionSuccess extends AdminDossierState {
  final String message;
  AdminDossierActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminDossierError extends AdminDossierState {
  final String message;
  AdminDossierError(this.message);

  @override
  List<Object?> get props => [message];
}
