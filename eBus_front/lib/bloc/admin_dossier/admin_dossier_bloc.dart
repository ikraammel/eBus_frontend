import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_dossier_service.dart';
import 'admin_dossier_event.dart';
import 'admin_dossier_state.dart';

class AdminDossierBloc extends Bloc<AdminDossierEvent, AdminDossierState> {
  final AdminDossierService dossierService;

  AdminDossierBloc({required this.dossierService}) : super(AdminDossierInitial()) {
    
    on<LoadDossiers>((event, emit) async {
      emit(AdminDossierLoading());
      try {
        final dossiers = await dossierService.getAllDossiers();
        emit(AdminDossierLoaded(dossiers));
      } catch (e) {
        emit(AdminDossierError(e.toString()));
      }
    });

    on<ValiderDossierEvent>((event, emit) async {
      try {
        await dossierService.validerDossier(event.id);
        emit(AdminDossierActionSuccess("Dossier validé avec succès"));
        add(LoadDossiers()); 
      } catch (e) {
        emit(AdminDossierError(e.toString()));
      }
    });

    on<RejeterDossierEvent>((event, emit) async {
      try {
        await dossierService.rejeterDossier(event.id);
        emit(AdminDossierActionSuccess("Dossier rejeté"));
        add(LoadDossiers());
      } catch (e) {
        emit(AdminDossierError(e.toString()));
      }
    });
  }
}
