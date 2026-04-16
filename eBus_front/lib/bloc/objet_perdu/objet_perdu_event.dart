import 'package:equatable/equatable.dart';

abstract class ObjetPerduEvent extends Equatable {
  const ObjetPerduEvent();

  @override
  List<Object?> get props => [];
}

// ---------------- LOAD ----------------
class LoadObjetsPerdus extends ObjetPerduEvent {
  const LoadObjetsPerdus();
}

// ---------------- ADD ----------------
class AddObjetPerdu extends ObjetPerduEvent {
  final Map<String, dynamic> objetData;

  const AddObjetPerdu({required this.objetData});

  @override
  List<Object?> get props => [objetData];
}

// ---------------- UPDATE STATUS ----------------
class UpdateObjetPerduStatus extends ObjetPerduEvent {
  final int id;
  final String newStatus;

  const UpdateObjetPerduStatus({
    required this.id,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [id, newStatus];
}

// ---------------- DELETE ----------------
class DeleteObjetPerdu extends ObjetPerduEvent {
  final int id;

  const DeleteObjetPerdu({required this.id});

  @override
  List<Object?> get props => [id];
}
