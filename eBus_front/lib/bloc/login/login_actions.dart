import 'package:equatable/equatable.dart';

abstract class LoginActions extends Equatable{
  LoginActions();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends LoginActions{
  final String email;
  final String password;

  LoginSubmitted({required this.email,required this.password});

  @override
  List<Object?> get props => [email,password];

}