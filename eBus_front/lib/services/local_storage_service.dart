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


  Future<void> saveUser(User user) async{
    await prefs.setInt(keyUserId,user.id);
    await prefs.setString(keyNom,user.nom);
    await prefs.setString(keyPrenom,user.prenom);
    await prefs.setString(keyEmail,user.email);
    await prefs.setString(keyRole,user.role);
    await prefs.setString(keyTel,user.tel);
    await prefs.setString(keyAdresse,user.adresse);
    await prefs.setBool(keyIsLoggedIn,true);
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
      );
    }
  }

  bool isLoggedIn() => prefs.getBool(keyIsLoggedIn) ?? false;

  Future<void> logout() async => await prefs.clear();

}