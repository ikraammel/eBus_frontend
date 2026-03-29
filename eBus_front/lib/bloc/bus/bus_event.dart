import 'package:equatable/equatable.dart';

import '../../models/Bus.dart';

abstract class BusEvent extends Equatable{
  @override
  List<Object> get props => [];
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