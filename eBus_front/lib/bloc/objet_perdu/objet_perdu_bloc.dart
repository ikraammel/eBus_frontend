import 'package:bloc/bloc.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_event.dart';
import 'package:smart_bus/bloc/objet_perdu/objet_perdu_state.dart';
import 'package:smart_bus/services/objet_service.dart';
import 'package:smart_bus/models/statut_objet.dart';

class ObjetPerduBloc extends Bloc<ObjetPerduEvent, ObjetPerduState> {
  final ObjetService _objetService = ObjetService();

  ObjetPerduBloc() : super(const ObjetPerduInitial()) {
    on<LoadObjetsPerdus>(_onLoad);
    on<AddObjetPerdu>(_onAdd);
    on<UpdateObjetPerduStatus>(_onUpdateStatus);
    on<DeleteObjetPerdu>(_onDelete);
  }

  // ---------------- LOAD ----------------
  Future<void> _onLoad(
    LoadObjetsPerdus event,
    Emitter<ObjetPerduState> emit,
  ) async {
    emit(const ObjetPerduLoading());
    try {
      final objets = await _objetService.getAll();
      emit(ObjetPerduLoadSuccess(objets: objets));
    } catch (e) {
      emit(ObjetPerduFailure(error: e.toString()));
    }
  }

  // ---------------- ADD ----------------
  Future<void> _onAdd(
    AddObjetPerdu event,
    Emitter<ObjetPerduState> emit,
  ) async {
    emit(const ObjetPerduLoading()); // Optionnel: afficher loading pendant l'ajout
    try {
      // On passe maintenant l'image au service
      await _objetService.declare(event.objetData, event.image);

      final objets = await _objetService.getAll();
      emit(ObjetPerduLoadSuccess(objets: objets));
    } catch (e) {
      emit(ObjetPerduFailure(error: e.toString()));
    }
  }

  // ---------------- UPDATE STATUS ----------------
  Future<void> _onUpdateStatus(
    UpdateObjetPerduStatus event,
    Emitter<ObjetPerduState> emit,
  ) async {
    try {
      final statut = StatutObjet.values.firstWhere(
        (e) => e.name.toUpperCase() == event.newStatus.toUpperCase(),
        orElse: () => StatutObjet.EN_ATTENTE,
      );

      await _objetService.updateStatut(event.id, statut);

      final objets = await _objetService.getAll();
      emit(ObjetPerduLoadSuccess(objets: objets));
    } catch (e) {
      emit(ObjetPerduFailure(error: e.toString()));
    }
  }

  // ---------------- DELETE ----------------
  Future<void> _onDelete(
    DeleteObjetPerdu event,
    Emitter<ObjetPerduState> emit,
  ) async {
    try {
      await _objetService.deleteObjet(event.id);
      final objets = await _objetService.getAll();
      emit(ObjetPerduLoadSuccess(objets: objets));
    } catch (e) {
      emit(ObjetPerduFailure(error: e.toString()));
    }
  }
}
