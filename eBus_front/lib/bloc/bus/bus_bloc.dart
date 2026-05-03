import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_bus/bloc/bus/bus_event.dart';
import 'package:smart_bus/bloc/bus/bus_state.dart';
import 'package:smart_bus/services/bus_service.dart';

import '../../models/bus.dart';

class BusBloc extends Bloc<BusEvent,BusState>{
  final BusService busService;
  List<Bus> buses = [];

  BusBloc(this.busService):super(BusInitial()) {
    on<LoadBuses>((event, emit) async {
      emit(BusLoading());
      try {
        final allBus = await busService.getAllBus();
        buses = allBus;
        emit(BusLoaded(buses));
      } catch (e) {
        emit(BusError("Erreur de chargement des bus"));
      }
    });

    on<CreateBus>((event, emit) async {
      emit(BusLoading());
      try {
        final newBus = await busService.createBus(event.bus);
        emit(BusCreated(newBus));
      } catch (e) {
        String errorMessage = "Erreur inconnue";

        if (e is DioError && e.response != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          } else {
            errorMessage = e.response.toString();
          }
        } else if (e is Exception) {
          errorMessage = e.toString();
        }

        emit(BusError(errorMessage));
      }
    });

    on<UpdateBus>((event, emit) async {
      try {
        await busService.updateBus(event.id, event.bus);
        emit(BusUpdated(event.id, event.bus));
      } catch (e) {
        String errorMessage = "Erreur de modification";
        if (e is DioException && e.response != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          } else {
            errorMessage = e.response.toString();
          }
        }
        emit(BusError(errorMessage));
      }
    });

    on<DeleteBus>((event, emit) async {
      try {
        await busService.deleteBus(event.id);
        buses.removeWhere((bus) => bus.id == event.id);
        emit(BusDeleted(event.id));
      } catch (e) {
        String errorMessage = "Erreur de suppression";
        if (e is DioException && e.response != null) {
          final data = e.response!.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'];
          } else {
            errorMessage = e.response.toString();
          }
        }
        emit(BusError(errorMessage));
      }
    });
  }
}