import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:smart_bus/services/reclamation_service.dart';

import '../../models/Reclamation.dart';
import 'claims_event.dart';
import 'claims_state.dart';

class ClaimsBloc extends Bloc<ClaimsEvent,ClaimsState>{
  final ReclamationService reclamationService;
  List<Reclamation> claims=[];

  ClaimsBloc(this.reclamationService):super(ClaimsInitial()) {
    on<LoadClaims>((event, emit) async {
      emit(ClaimsLoading());
      try {
        final allClaims = await reclamationService.getReclamations();
        claims = allClaims;
        emit(ClaimsLoaded(claims));
      } catch (e) {
        emit(ClaimsError("Erreur de chargement des réclamations"));
      }
    });

    on<CreateClaim>((event, emit) async {
      emit(ClaimsLoading());
      try {
        final newClaim = await reclamationService.createReclamation(event.reclamation);
        claims.add(newClaim);
        emit(ClaimsLoaded(List.from(claims)));
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

        emit(ClaimsError(errorMessage));
      }
    });

    on<UpdateClaim>((event, emit) async {
      try {
        final patchData = event.patch;
        await reclamationService.updateReclamation(event.id, patchData);
        emit(ClaimsUpdated(event.id, patchData));
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
        emit(ClaimsError(errorMessage));
      }
    });

    on<DeleteClaim>((event, emit) async {
      try {
        await reclamationService.deleteReclamation(event.id);
        claims.removeWhere((c) => c.id == event.id);
        emit(ClaimsDeleted(event.id));
      }catch(e){
        String errorMessage = "Erreur de suppression de la réclamation";
        if(e is DioException && e.response!=null){
          final data = e.response!.data;
          if(data is Map && data['message']!=null){
            errorMessage = data['message'];
          }else{
            errorMessage = e.response.toString();
          }
        }
        emit(ClaimsError(errorMessage));
      }
    });
  }
}