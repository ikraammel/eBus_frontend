import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/models/User.dart';

class LocalStorageService {
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

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

  Future<void> saveUser(User user) async{
    await prefs.setInt(keyUserId,user.id);
    await prefs.setString(keyNom,user.nom);
    await prefs.setString(keyPrenom,user.prenom);
    await prefs.setString(keyEmail,user.email);
    await prefs.setString(keyRole,user.role);
    await prefs.setString(keyTel,user.tel);
    await prefs.setString(keyAdresse,user.adresse);
    await prefs.setBool(keyIsLoggedIn,true);
    await prefs.setString(keyDateNaissance,user.dateNaissance);
    await prefs.setString(
        keyTypeAbonnement,
        user.typeAbonnement ?? '',
    );
    await prefs.setString(
        keyPhotoUrl,
        user.photoUrl ?? '',
    );
    await prefs.setString(
        keyCinUrl,
        user.cinUrl ?? ''
    );
    await prefs.setString(
        keyCarteScolaireUrl,
        user.carteScolaireUrl ?? ''
    );
  }

  User? getUser(){
    final id = prefs.getInt(keyUserId);
    if(id == null) return null;
    else{
      return User(
        id: id,
        nom: prefs.getString(keyNom) ?? '',
        prenom: prefs.getString(keyPrenom) ?? '',
        email: prefs.getString(keyEmail) ?? '',
        role: prefs.getString(keyRole) ?? '',
        tel: prefs.getString(keyTel) ?? '',
        adresse: prefs.getString(keyAdresse) ?? '',
        dateNaissance: prefs.getString(keyDateNaissance) ?? '',
        typeAbonnement: prefs.getString(keyTypeAbonnement),
        photoUrl: prefs.getString(keyPhotoUrl),
        cinUrl: prefs.getString(keyCinUrl),
        carteScolaireUrl: prefs.getString(keyCarteScolaireUrl),
      );
    }
  }

  bool isLoggedIn() => prefs.getBool(keyIsLoggedIn) ?? false;

  Future<void> logout() async => await prefs.clear();

}