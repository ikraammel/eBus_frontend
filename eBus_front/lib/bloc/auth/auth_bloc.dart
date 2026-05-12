import 'package:bloc/bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/models/user.dart';
import 'package:smart_bus/services/local_storage_service.dart';

import '../../main.dart';
import '../../services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent,AuthState> {
  final AuthService _authService = getIt<AuthService>();
  final LocalStorageService _localStorageService = getIt<LocalStorageService>();

  AuthBloc() :super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthUpdateUserRequested>(_onUpdateUserRequested);
    on<AuthUpdateAvatarRequested>(_onUpdateAvatarRequested);
    on<AuthResubmitDossierRequested>(_onResubmitDossierRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteUserRequested>(_onDeleteUserRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
    on<AuthVerifyResetCodeRequested>(_onVerifyResetCode);
    on<AuthChangePasswordRequested>(_onChangePassword);
    on<AuthGuestRequested>(_onGuestRequested);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());

    final user = await _localStorageService.getUser();
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(AuthLoginRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    try {
      final User user = await _authService.login(event.email, event.password);
      await _localStorageService.saveUser(user);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(AuthRegisterRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    try {
      final User user = await _authService.register(
          event.request,
          event.photo,
          event.carteScolaire,
          event.cin
      );
      await _localStorageService.saveUser(user);
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateUserRequested(AuthUpdateUserRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    try {
      final Map<String, dynamic> data = {};
      if (event.nom != null) {
        data['nom'] = event.nom;
      }
      if (event.prenom != null) {
        data['prenom'] = event.prenom;
      }
      if (event.email != null) {
        data['email'] = event.email;
      }
      if (event.tel != null) {
        data['tel'] = event.tel;
      }
      if (event.adresse != null) {
        data['adresse'] = event.adresse;
      }
      if (event.dateNaissance != null) {
        data['dateNaissance'] = event.dateNaissance;
      }
      final User updatedUser = await _authService.updateUser(event.id, data);
      await _localStorageService.saveUser(updatedUser);
      emit(AuthProfileUpdated(user: updatedUser));
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onUpdateAvatarRequested(AuthUpdateAvatarRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User updatedUser = await _authService.updateAvatar(event.id, event.photo);
      await _localStorageService.saveUser(updatedUser);
      emit(AuthProfileUpdated(user: updatedUser));
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  /// Re-soumettre le dossier après rejet :
  /// 1. Met à jour les infos perso (nom, prenom, email, tel, adresse, dateNaissance)
  /// 2. Upload la nouvelle photo CIN si fournie
  /// 3. Upload la nouvelle carte scolaire si fournie
  /// 4. Remet le statut du dossier à EN_ATTENTE via resubmitDossier
  Future<void> _onResubmitDossierRequested(
      AuthResubmitDossierRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      // 1. Mettre à jour les infos perso si changées
      final Map<String, dynamic> data = {};
      if (event.nom != null) data['nom'] = event.nom;
      if (event.prenom != null) data['prenom'] = event.prenom;
      if (event.email != null) data['email'] = event.email;
      if (event.tel != null) data['tel'] = event.tel;
      if (event.adresse != null) data['adresse'] = event.adresse;
      if (event.dateNaissance != null) data['dateNaissance'] = event.dateNaissance;

      User updatedUser;
      if (data.isNotEmpty) {
        updatedUser = await _authService.updateUser(event.userId, data);
      } else {
        updatedUser = (await _localStorageService.getUser())!;
      }

      // 2. Re-soumettre le dossier (CIN + carte scolaire optionnels)
      updatedUser = await _authService.resubmitDossier(
        userId: event.userId,
        newCinFile: event.newCinFile,
        newCarteScolaireFile: event.newCarteScolaireFile,
      );

      await _localStorageService.saveUser(updatedUser);
      emit(AuthDossierResubmitted(user: updatedUser));
      emit(AuthAuthenticated(user: updatedUser));
    } catch (e) {
      final currentUser = await _localStorageService.getUser();
      emit(AuthFailure(error: e.toString()));
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      }
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event,
      Emitter<AuthState> emit,) async {
    await _localStorageService.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onDeleteUserRequested(AuthDeleteUserRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    try {
      await _authService.deleteUser(event.id);
      await _localStorageService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
      AuthForgotPasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final message = await _authService.forgotPassword(event.email);
      emit(ForgotPasswordSuccess(token: message));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
      AuthResetPasswordRequested event,
      Emitter<AuthState> emit,) async {
    emit(AuthLoading());
    try {
      await _authService.resetPassword(event.token,event.newPassword);
      emit(ResetPasswordSuccess());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onVerifyResetCode(
      AuthVerifyResetCodeRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final token = await _authService.verifyResetCode(
        event.email,
        event.code,
      );

      emit(AuthCodeVerified(token));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onChangePassword(
      AuthChangePasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    final currentUser = await _localStorageService.getUser();

    emit(AuthLoading());
    try {
      await _authService.changePassword(
        event.userId,
        event.oldPassword,
        event.newPassword,
      );
      emit(AuthPasswordChanged(message: "Mot de passe changé avec succès"));
      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      }
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst("Exception: ", "")));

      if (currentUser != null) {
        emit(AuthAuthenticated(user: currentUser));
      }
    }
  }

  Future<void> _onGuestRequested(
      AuthGuestRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _localStorageService.logout();
    emit(AuthGuest());
  }
}
