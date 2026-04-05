import 'package:equatable/equatable.dart';
import 'package:smart_bus/models/Reclamation.dart';

abstract class ClaimsEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoadClaims extends ClaimsEvent {
}

class CreateClaim extends ClaimsEvent {
  final Reclamation reclamation;
  CreateClaim(this.reclamation);

  @override
  List<Object?> get props => [reclamation];
}

class UpdateClaim extends ClaimsEvent {
  final int id;
  final Map<String, dynamic> patch;
  UpdateClaim({required this.id, required this.patch});
  @override
  List<Object?> get props => [id, patch];
}

class DeleteClaim extends ClaimsEvent {
  final int id;
  DeleteClaim(this.id);
  @override
  List<Object?> get props => [id];
}

