import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_abonnement_service.dart';
import 'admin_abonnement_event.dart';
import 'admin_abonnement_state.dart';

class AdminAbonnementBloc extends Bloc<AdminAbonnementEvent, AdminAbonnementState> {
  final AdminAbonnementService abonnementService;

  AdminAbonnementBloc({required this.abonnementService}) : super(AdminAbonnementInitial()) {
    on<LoadAbonnements>((event, emit) async {
      emit(AdminAbonnementLoading());
      try {
        final abonnements = await abonnementService.getAllAbonnements();
        emit(AdminAbonnementLoaded(
          abonnements: abonnements,
          filteredAbonnements: abonnements,
          currentFilter: 'TOUS',
        ));
      } catch (e) {
        emit(AdminAbonnementError(e.toString()));
      }
    });

    on<FilterAbonnementEvent>((event, emit) {
      if (state is AdminAbonnementLoaded) {
        final currentState = state as AdminAbonnementLoaded;
        final filtered = event.status == 'TOUS'
            ? currentState.abonnements
            : currentState.abonnements.where((a) => a.status == event.status).toList();
        
        emit(AdminAbonnementLoaded(
          abonnements: currentState.abonnements,
          filteredAbonnements: filtered,
          currentFilter: event.status,
        ));
      }
    });
  }
}
