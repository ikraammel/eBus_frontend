import 'package:equatable/equatable.dart';
import 'package:smart_bus/models/objet_perdu.dart';

abstract class ObjetPerduState extends Equatable {
  const ObjetPerduState();

  @override
  List<Object?> get props => [];
}

// ---------------- INITIAL ----------------
class ObjetPerduInitial extends ObjetPerduState {
  const ObjetPerduInitial();
}

// ---------------- LOADING ----------------
class ObjetPerduLoading extends ObjetPerduState {
  const ObjetPerduLoading();
}

// ---------------- SUCCESS LOAD ----------------
class ObjetPerduLoadSuccess extends ObjetPerduState {
  final List<ObjetPerdu> objets;

  const ObjetPerduLoadSuccess({required this.objets});

  @override
  List<Object?> get props => [objets];
}

// ---------------- OPERATION SUCCESS ----------------
class ObjetPerduOperationSuccess extends ObjetPerduState {
  final String message;

  const ObjetPerduOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// ---------------- FAILURE ----------------
class ObjetPerduFailure extends ObjetPerduState {
  final String error;

  const ObjetPerduFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
