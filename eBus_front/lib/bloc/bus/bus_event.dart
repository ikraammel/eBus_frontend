import 'package:equatable/equatable.dart';

import '../../models/bus.dart';

abstract class BusEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoadBuses extends BusEvent{
  @override
  List<Object> get props => [];
}

class CreateBus extends BusEvent{
  final Bus bus;
  CreateBus(this.bus);

  @override
  List<Object> get props => [bus];
}

class UpdateBus extends BusEvent{
  final int id;
  final Bus bus;
  UpdateBus(this.id,this.bus);

  @override
  List<Object> get props => [id,bus];
}

class DeleteBus extends BusEvent{
  final int id;
  DeleteBus(this.id);

  @override
  List<Object> get props => [id];
}

class LoadBusById extends BusEvent {
  final int id;
  LoadBusById(this.id);

  @override
  List<Object> get props => [id];
}

class SearchBusByImmatriculation extends BusEvent {
  final String immatriculation;
  SearchBusByImmatriculation(this.immatriculation);

  @override
  List<Object> get props => [immatriculation];
}

class FilterBusByLigne extends BusEvent {
  final int ligneId;
  FilterBusByLigne(this.ligneId);

  @override
  List<Object> get props => [ligneId];
}
