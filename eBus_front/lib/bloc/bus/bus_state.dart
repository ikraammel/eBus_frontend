import 'package:equatable/equatable.dart';

import '../../models/bus.dart';

abstract class BusState extends Equatable{
  BusState();
  @override
  List<Object?> get props => [];
}

class BusInitial extends BusState {}

class BusLoading extends BusState{}

class BusLoaded extends BusState{
  final List<Bus> buses;
  BusLoaded(this.buses);

  @override
  List<Object> get props => [buses];
}

class BusError extends BusState{
  final String error;
  BusError(this.error);

  @override
  List<Object> get props => [error];
}

class BusCreated extends BusState{
  final Bus bus;
  BusCreated(this.bus);

  @override
  List<Object> get props => [bus];
}

class BusUpdated extends BusState{
  final int id;
  final Bus bus;
  BusUpdated(this.id,this.bus);

  @override
  List<Object> get props => [id,bus];
}

class BusDeleted extends BusState{
  final int id;
  BusDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class BusDetailsLoaded extends BusState {
  final Bus bus;
  BusDetailsLoaded(this.bus);

  @override
  List<Object> get props => [bus];
}
