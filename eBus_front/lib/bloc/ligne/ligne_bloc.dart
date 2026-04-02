import 'package:bloc/bloc.dart';
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

  }
}