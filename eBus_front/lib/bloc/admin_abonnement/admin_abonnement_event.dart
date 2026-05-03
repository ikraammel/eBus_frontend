import 'package:equatable/equatable.dart';

abstract class AdminAbonnementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAbonnements extends AdminAbonnementEvent {}

class FilterAbonnementEvent extends AdminAbonnementEvent {
  final String status;
  FilterAbonnementEvent(this.status);

  @override
  List<Object?> get props => [status];
}
