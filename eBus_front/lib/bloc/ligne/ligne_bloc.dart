import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_bus/bloc/ligne/ligne_event.dart';
import 'package:smart_bus/bloc/ligne/ligne_state.dart';
import 'package:smart_bus/services/ligne_service.dart';

import '../../models/Ligne.dart';

class LigneBloc extends Bloc<LigneEvent,LigneState>{
  final LigneService ligneService;
  List<Ligne> lignes=[];

  LigneBloc(this.ligneService):super(LigneInitial()){
    on<LoadLignes>((event,emit) async{
      emit(LigneLoading());
      try{
        final allLignes = await ligneService.getLignes();
        lignes = allLignes;

        emit(LigneLoaded(lignes));
      }catch(e){
        emit(LigneError("Erreur de chargement des lignes"));
      }
    });

    on<SearchLignes>((event,emit) async{
      emit(LigneLoading());
      final filteredLignes = lignes.where((ligne){
        return ligne.numero
            .toLowerCase()
            .contains(event.query.toLowerCase())
            || ligne.startPoint
                .toLowerCase()
                .contains(event.query.toLowerCase())
            || ligne.endPoint
                .toLowerCase()
                .contains(event.query.toLowerCase());
      }).toList();
      emit(LigneLoaded(filteredLignes));
    });

    on<CreateLigne>((event, emit) async {
      emit(LigneLoading());
      try {
        final newLigne = await ligneService.createLine(event.ligne);
        emit(LigneCreated(newLigne));
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

        emit(LigneError(errorMessage));
      }
    });

    on<DeleteLine>((event, emit) async {
      try {
        await ligneService.deleteLine(event.id);
        lignes.removeWhere((ligne) => ligne.id == event.id);
        emit(LigneDeleted(event.id));
      }catch(e){
        String errorMessage = "Erreur de suppression";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(LigneError(errorMessage));
      }
    });

    on<UpdateLine>((event, emit) async {
      try {
        final patchData = event.patch.toJson();
        await ligneService.updateLine(event.id,patchData);
        emit(LigneUpdated(event.id,event.patch.toJson()));
      }catch(e){
        String errorMessage = "Erreur de modification";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(LigneError(errorMessage));
      }
    });

    on<DeleteStation>((event, emit) async {
      try {
        await ligneService.deleteStation(event.ligneId,event.stationId);
        final ligneIndex = lignes.indexWhere((l) => l.id == event.ligneId);
        if (ligneIndex != -1) {
          lignes[ligneIndex].stations.removeWhere((s) => s.id == event.stationId);
        }
        emit(StationDeleted(event.ligneId, event.stationId));
      }catch(e){
        String errorMessage = "Erreur de suppression de la station";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(LigneError(errorMessage));
      }
    });

    on<UpdateStation>((event, emit) async {
      try {
        await ligneService.updateStation(event.station,event.ligneId,event.stationId);
        final ligneIndex = lignes.indexWhere((l) => l.id == event.ligneId);
        if (ligneIndex != -1) {
          final stationIndex = lignes[ligneIndex].stations.indexWhere((s) => s.id == event.stationId);
          if (stationIndex != -1) {
            lignes[ligneIndex].stations[stationIndex] = event.station;
          }
        }
        emit(StationUpdated(event.station,event.ligneId,event.stationId));
      }catch(e){
        String errorMessage = "Erreur de modification de station";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(LigneError(errorMessage));
      }
    });

    on<CreateStation>((event, emit) async {
      try {
        final newStation = await ligneService.addStation(event.station,event.ligneId);
        final ligneIndex = lignes.indexWhere((l) => l.id == event.ligneId);
        if (ligneIndex != -1) {
          lignes[ligneIndex].stations.add(newStation);
        }
        emit(StationCreated(event.ligneId,event.station));
      }catch(e){
        String errorMessage = "Erreur d'ajout de station";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(LigneError(errorMessage));
      }
    });
    }
}