import 'package:equatable/equatable.dart';
import '../../models/abonnement.dart';

abstract class AdminAbonnementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminAbonnementInitial extends AdminAbonnementState {}

class AdminAbonnementLoading extends AdminAbonnementState {}

class AdminAbonnementLoaded extends AdminAbonnementState {
  final List<Abonnement> abonnements;
  final List<Abonnement> filteredAbonnements;
  final String currentFilter;

  AdminAbonnementLoaded({
    required this.abonnements,
    required this.filteredAbonnements,
    this.currentFilter = 'TOUS',
  });

  @override
  List<Object?> get props => [abonnements, filteredAbonnements, currentFilter];
}

class AdminAbonnementError extends AdminAbonnementState {
  final String message;
  AdminAbonnementError(this.message);

  @override
  List<Object?> get props => [message];
}
