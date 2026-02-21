import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/request/register_request.dart';

abstract class AuthEvent extends Equatable{
  AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent{} //vérifier si un user est connected

class AuthLoginRequested extends AuthEvent{
  final String email;
  final String password;
  AuthLoginRequested({required this.email,required this.password});

  @override
  List<Object?> get props => [email,password];
}

class AuthRegisterRequested extends AuthEvent{
  final RegisterRequest request;
  final XFile photo;
  final XFile carteScolaire;
  final XFile cin;
  AuthRegisterRequested({
    required this.request,
    required this.photo,
    required this.carteScolaire,
    required this.cin,
  });

  @override
  List<Object?> get props => [request,photo,carteScolaire,cin];
}

class AuthUpdateUserRequested extends AuthEvent{
  final int id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? tel;
  final String? adresse;
  final String? dateNaissance;
  AuthUpdateUserRequested({
     required this.id,
     this.nom,
     this.prenom,
     this.email,
     this.tel,
     this.adresse,
     this.dateNaissance,
  });

  @override
  List<Object?> get props => [id,nom,prenom,email,tel,adresse,dateNaissance];
}

class AuthLogoutRequested extends AuthEvent{}

class AuthDeleteUserRequested extends AuthEvent{
  final int id;
  AuthDeleteUserRequested({required this.id});
}


