import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/services/bus_service.dart';

import '../../models/bus.dart';

class BusBloc extends Bloc<BusEvent, BusState> {
  final BusService busService;
  List<Bus> buses = [];

  BusBloc(this.busService) : super(BusInitial()) {
    on<LoadBuses>(_onLoadBuses);
    on<CreateBus>(_onCreateBus);
    on<UpdateBus>(_onUpdateBus);
    on<DeleteBus>(_onDeleteBus);
    on<LoadBusById>(_onLoadBusById);
    on<SearchBusByImmatriculation>(_onSearchBusByImmatriculation);
    on<FilterBusByLigne>(_onFilterBusByLigne);
  }

  Future<void> _onLoadBuses(LoadBuses event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      buses = await busService.getAllBus();
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(_errorMessage(e, fallback: "Erreur de chargement des bus")));
    }
  }

  Future<void> _onCreateBus(CreateBus event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      final newBus = await busService.createBus(event.bus);
      emit(BusCreated(newBus));
      buses = await busService.getAllBus();
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(_errorMessage(e)));
    }
  }

  Future<void> _onUpdateBus(UpdateBus event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      final updatedBus = await busService.updateBus(event.id, event.bus);
      emit(BusUpdated(event.id, updatedBus));
      buses = await busService.getAllBus();
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(_errorMessage(e, fallback: "Erreur de modification")));
    }
  }

  Future<void> _onDeleteBus(DeleteBus event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      await busService.deleteBus(event.id);
      emit(BusDeleted(event.id));
      buses = await busService.getAllBus();
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(_errorMessage(e, fallback: "Erreur de suppression")));
    }
  }

  Future<void> _onLoadBusById(LoadBusById event, Emitter<BusState> emit) async {
    emit(BusLoading());
    try {
      final bus = await busService.getBusById(event.id);
      emit(BusDetailsLoaded(bus));
    } catch (e) {
      emit(BusError(_errorMessage(e, fallback: "Bus introuvable")));
    }
  }

  Future<void> _onSearchBusByImmatriculation(
    SearchBusByImmatriculation event,
    Emitter<BusState> emit,
  ) async {
    final query = event.immatriculation.trim();
    if (query.isEmpty) {
      add(LoadBuses());
      return;
    }

    emit(BusLoading());
    try {
      final bus = await busService.getBusByImmatriculation(query);
      buses = [bus];
      emit(BusLoaded(buses));
    } catch (e) {
      buses = [];
      emit(BusLoaded(buses));
      emit(BusError(_errorMessage(e, fallback: "Aucun bus trouve")));
    }
  }

  Future<void> _onFilterBusByLigne(
    FilterBusByLigne event,
    Emitter<BusState> emit,
  ) async {
    emit(BusLoading());
    try {
      buses = await busService.getBusesByLigne(event.ligneId);
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(_errorMessage(e, fallback: "Erreur filtrage bus par ligne")));
    }
  }

  String _errorMessage(dynamic error, {String fallback = "Erreur inconnue"}) {
    if (error is DioException && error.response != null) {
      final data = error.response!.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return error.response.toString();
    }
    if (error is Exception) return error.toString();
    return fallback;
  }
}
