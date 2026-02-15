import 'package:equatable/equatable.dart';

import '../../models/User.dart';

class LoginState extends Equatable{
  LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState{}

class LoginLoading extends LoginState{}

class LoginSuccess extends LoginState{
  final User user;
  LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState{
  final String error;
  LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
