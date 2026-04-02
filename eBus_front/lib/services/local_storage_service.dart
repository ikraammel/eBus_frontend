import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/models/User.dart';

import '../enums/enums.dart';

class LocalStorageService {
  LocalStorageService({required this.prefs});
  final SharedPreferences prefs;

  static const String keyUserId = 'userId';
  static const String keyNom = 'nom';
  static const String keyPrenom = 'prenom';
  static const String keyEmail = 'email';
  static const String keyRole = 'role';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyTel = 'tel';
  static const String keyAdresse = 'adresse';
  static const String keyDateNaissance = 'dateNaissance';
  static const String keyTypeAbonnement = 'typeAbonnement';
  static const String keyPhotoUrl = 'photoUrl';
  static const String keyCinUrl  = 'cinUrl';
  static const String keyCarteScolaireUrl = 'carteScolaireUrl';
  static const String keyCin = 'cin';
  static const String keyCne = 'cne';

  Future<void> saveUser(User user) async{
    await Future.wait([
      prefs.setInt(keyUserId,user.id),
      prefs.setString(keyNom,user.nom),
      prefs.setString(keyPrenom,user.prenom),
      prefs.setString(keyEmail,user.email),
      prefs.setString(keyRole,user.role.name),
      prefs.setString(keyTel,user.tel),
      prefs.setString(keyAdresse,user.adresse),
      prefs.setBool(keyIsLoggedIn,true),
      prefs.setString(keyDateNaissance,user.dateNaissance),
      prefs.setString(
        keyTypeAbonnement,
        user.typeAbonnement ?? '',
      ),
      prefs.setString(
        keyPhotoUrl,
        user.photoUrl ?? '',
      ),
      prefs.setString(
          keyCinUrl,
          user.cinUrl ?? ''
      ),
      prefs.setString(
          keyCarteScolaireUrl,
          user.carteScolaireUrl ?? ''
      ),
      prefs.setString(
          keyCin,
          user.cin
      ),
      prefs.setString(
          keyCne,
          user.cne
      ),
    ]);

  }

  User? getUser(){
    final id = prefs.getInt(keyUserId);
    if(id == null) {
      return null;
    } else{
      return User(
        id: id,
        nom: prefs.getString(keyNom) ?? '',
        prenom: prefs.getString(keyPrenom) ?? '',
        email: prefs.getString(keyEmail) ?? '',
        role: Enums.values.firstWhere(
            (e) => e.name == prefs.getString(keyRole),
            orElse: () => Enums.USER
        ),
        tel: prefs.getString(keyTel) ?? '',
        adresse: prefs.getString(keyAdresse) ?? '',
        dateNaissance: prefs.getString(keyDateNaissance) ?? '',
        typeAbonnement: prefs.getString(keyTypeAbonnement),
        photoUrl: prefs.getString(keyPhotoUrl),
        cinUrl: prefs.getString(keyCinUrl),
        carteScolaireUrl: prefs.getString(keyCarteScolaireUrl),
        cin: prefs.getString(keyCin) ?? '',
        cne: prefs.getString(keyCne) ?? '',
      );
    }
  }
  int? getUserId() {
    return prefs.getInt(keyUserId);
  }

  bool isLoggedIn() => prefs.getBool(keyIsLoggedIn) ?? false;

  Future<void> logout() async => await prefs.clear();

}
