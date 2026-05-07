import 'package:equatable/equatable.dart';

abstract class AdminDossierEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDossiers extends AdminDossierEvent {}

class ValiderDossierEvent extends AdminDossierEvent {
  final int id;
  ValiderDossierEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RejeterDossierEvent extends AdminDossierEvent {
  final String reason;
  final int id;
  RejeterDossierEvent(this.id,this.reason);

  @override
  List<Object?> get props => [id];
}
