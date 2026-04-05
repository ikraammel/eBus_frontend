import 'package:equatable/equatable.dart';

import '../../models/Reclamation.dart';

abstract class ClaimsState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ClaimsInitial extends ClaimsState{}
class ClaimsLoading extends ClaimsState{}
class ClaimsLoaded extends ClaimsState{
  final List<Reclamation> claims;
  ClaimsLoaded(this.claims);
  @override
  List<Object?> get props => [claims];
}

class ClaimsError extends ClaimsState{
  final String error;
  ClaimsError(this.error);
  @override
  List<Object?> get props => [error];
}

class ClaimsCreated extends ClaimsState{
  final Reclamation reclamation;
  ClaimsCreated(this.reclamation);
  @override
  List<Object?> get props => [reclamation];
}

class ClaimsUpdated extends ClaimsState{
  final int id;
  final Map<String, dynamic> patch;
  ClaimsUpdated(this.id,this.patch);
  @override
  List<Object?> get props => [id,patch];
}

class ClaimsDeleted extends ClaimsState{
  final int id;
  ClaimsDeleted(this.id);
  @override
  List<Object?> get props => [id];

}