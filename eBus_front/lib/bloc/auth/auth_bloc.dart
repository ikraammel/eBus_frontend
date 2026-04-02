import 'package:bloc/bloc.dart';
import 'package:smart_bus/bloc/auth/auth_event.dart';
import 'package:smart_bus/bloc/auth/auth_state.dart';
import 'package:smart_bus/models/User.dart';
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
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthDeleteUserRequested>(_onDeleteUserRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
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
      final token = await _authService.forgotPassword(event.email);
      emit(ForgotPasswordSuccess(token: token));
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

}