import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../../models/horaire.dart';
import '../../services/horaire_service.dart';
import 'horaire_event.dart';
import 'horaire_state.dart';

class HoraireBloc extends Bloc<HoraireEvent, HoraireState> {
  final HoraireService horaireService;
  List<Horaire> horaires = [];
  int? currentLigneId;

  HoraireBloc(this.horaireService) : super(HoraireInitial()) {
    on<LoadHoraires>((event, emit) async {
      emit(HoraireLoading());
      try {
        final result = await horaireService.getHorairesByLigne(event.ligneId);
        horaires = result;
        currentLigneId = event.ligneId;
        emit(HoraireLoaded(horaires, event.ligneId));
      } catch (e) {
        emit(HoraireError("Erreur de chargement des horaires"));
      }
    });

    on<CreateHoraire>((event, emit) async {
      emit(HoraireLoading());
      try {
        final newHoraire = await horaireService.createHoraire(event.horaire);
        horaires.add(newHoraire);
        emit(HoraireCreated(newHoraire));
      } catch (e) {
        emit(HoraireError(_extractError(e, "Erreur création horaire")));
      }
    });

    on<UpdateHoraire>((event, emit) async {
      try {
        final updated =
        await horaireService.updateHoraire(event.id, event.horaire);
        final idx = horaires.indexWhere((h) => h.id == event.id);
        if (idx != -1) horaires[idx] = updated;
        emit(HoraireUpdated(updated));
      } catch (e) {
        emit(HoraireError(_extractError(e, "Erreur modification horaire")));
      }
    });

    on<DeleteHoraire>((event, emit) async {
      try {
        await horaireService.deleteHoraire(event.id);
        horaires.removeWhere((h) => h.id == event.id);
        emit(HoraireDeleted(event.id));
      } catch (e) {
        emit(HoraireError(_extractError(e, "Erreur suppression horaire")));
      }
    });
  }

  String _extractError(Object e, String fallback) {
    if (e is DioException && e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) return data['message'];
      return e.response.toString();
    }
    return fallback;
  }
}