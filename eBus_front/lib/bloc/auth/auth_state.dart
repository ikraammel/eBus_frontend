import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class AuthState extends Equatable {
  AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({required this.user});
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthProfileUpdated extends AuthState {
  final User user;

  AuthProfileUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
  @override
  List<Object> get props => [error];
}

class ForgotPasswordSuccess extends AuthState {
  final String token;

  ForgotPasswordSuccess({required this.token});

  @override
  List<Object> get props => [token];
}

class ResetPasswordSuccess extends AuthState {}

