import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/models/user.dart';
import 'package:smart_bus/models/request/register_request.dart';
import 'package:http_parser/http_parser.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../utils/shared_prefs_helper.dart';


class AuthService {
  final Dio _dio = DioClient.dio;

  Future<User> login(String email, String password) async {
    try{
      final response = await _dio.post(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );


      final data = response.data as Map<String, dynamic>;
      final String token = data['token'] as String;
      final Map<String, dynamic> userJson = data['user'] as Map<String, dynamic>;

      await SharedPrefsHelper.saveToken(token);

      userJson['token'] = token;
      return User.fromJson(userJson);
    }on DioException catch(e){
      if(e.response != null && e.response!.data != null){
        final data = e.response!.data;

        if(data is String){
          throw Exception(data);
        }
        if(data is Map){
          if(data.containsKey('message')){
            throw Exception(data['message']);
          }
        }
      }
      throw Exception("Erreur lors de la connexion");
    }
  }

  Future<User> register(
      RegisterRequest request,
      XFile photo,
      XFile? carteScolaire,
      XFile? attestationScolaire,
      XFile cin
      ) async {
    try{
      final userJson = jsonEncode(request.toJson());

      final Map<String, dynamic> formFields = {
        'user':MultipartFile.fromString(
          userJson,
          filename: 'user.json',
          contentType: MediaType.parse('application/json'),),
        'photo': await MultipartFile.fromFile(photo.path,
            filename: photo.name),
        'cinPhoto': await MultipartFile.fromFile(cin.path,
            filename: cin.name),
      };

      if (carteScolaire != null) {
        formFields['carteScolaire'] = await MultipartFile.fromFile(
          carteScolaire.path,
          filename: carteScolaire.name,
        );
      }

      if (attestationScolaire != null) {
        formFields['attestationScolaire'] = await MultipartFile.fromFile(
          attestationScolaire.path,
          filename: attestationScolaire.name,
        );
      }

      FormData formData = FormData.fromMap(formFields);

      final response = await _dio.post(
          '/users/register',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ));
      return User.fromJson(response.data);
    }on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;

        if (data is String) {
          throw Exception(data);
        }

        if (data is Map) {
          if (data.containsKey("message")) {
            throw Exception(data["message"]);
          }

          if (data.containsKey("errors") && data["errors"] is List) {
            final errors = data["errors"] as List;
            if (errors.isNotEmpty) {
              final messages = errors.map((e) => e["message"] ?? "").join("\n");
              throw Exception(messages);
            }
          }
        }
      }

      throw Exception("Erreur serveur, veuillez réessayer");

    } catch (e) {
      throw Exception("Erreur inattendue: ${e.toString()}");
    }
  }

  Future<bool> isLoggedIn() async {
    return true;
  }

  Future<User> updateUser(int id,Map<String,dynamic> user) async{
    try{
      final response = await _dio.patch(
        '/users/update/$id',
        data: user,
      );
      return User.fromJson(response.data);
    }on DioException catch(e){
      if(e.response != null && e.response!.data != null){
        final data = e.response!.data;

        if(data is String){
          throw Exception(data);
        }
        if(data is Map){
          if(data.containsKey('message')){
            throw Exception(data['message']);
          }
        }
      }
      throw Exception("Erreur lors de la connexion");
    }
  }

  Future<User> updateAvatar(int id, XFile photo) async {
    try {
      FormData formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(photo.path, filename: photo.name),
      });

      final response = await _dio.patch(
        '/users/update-avatar/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is String) throw Exception(data);
        if (data is Map && data.containsKey('message')) throw Exception(data['message']);
      }
      throw Exception("Erreur lors de la mise à jour de l'avatar");
    }
  }

  /// Re-soumettre le dossier après rejet.
  /// Envoie les nouvelles photos CIN et/ou carte scolaire si fournies.
  /// Le backend remet le statusDossier à EN_ATTENTE.
  Future<User> resubmitDossier({
    required int userId,
    XFile? newPhotoFile,
    XFile? newCinFile,
    XFile? newCarteScolaireFile,
    XFile? newAttestationScolaireFile,
  }) async {
    try {
      final Map<String, dynamic> fields = {};

      if (newPhotoFile != null) {
        fields['photo'] = await MultipartFile.fromFile(
          newPhotoFile.path,
          filename: newPhotoFile.name,
        );
      }
      if (newCinFile != null) {
        fields['cinPhoto'] = await MultipartFile.fromFile(
          newCinFile.path,
          filename: newCinFile.name,
        );
      }
      if (newCarteScolaireFile != null) {
        fields['carteScolaire'] = await MultipartFile.fromFile(
          newCarteScolaireFile.path,
          filename: newCarteScolaireFile.name,
        );
      }
      if (newAttestationScolaireFile != null) {
        fields['attestationScolaire'] = await MultipartFile.fromFile(
          newAttestationScolaireFile.path,
          filename: newAttestationScolaireFile.name,
        );
      }

      FormData formData = FormData.fromMap(fields);

      final response = await _dio.patch(
        '/users/resubmit-dossier/$userId',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is String) throw Exception(data);
        if (data is Map && data.containsKey('message')) throw Exception(data['message']);
      }
      throw Exception("Erreur lors de la re-soumission du dossier");
    }
  }

  Future<void> deleteUser(int id) async{
    try{
      await _dio.delete(
        '/users/$id',
      );
    }on DioException catch(e){
      if(e.response != null && e.response!.data != null){
        final data = e.response!.data;

        if(data is String){
          throw Exception(data);
        }
      }
    }
  }

  Future<String> verifyResetCode(String email, String code) async {
    try {
      final response = await _dio.post(
        "/users/verify-reset-code",
        data: {
          "email": email,
          "code": code,
        },
      );

      final data = response.data;

      if (data is Map && data["data"] != null) {
        return data["data"]["token"];
      }

      throw Exception("Token invalide ou réponse serveur incorrecte");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        "/users/forgot-password",
        data: {"email": email},
      );

      final data = response.data;

      if (data is Map && data["message"] != null) {
        return data["message"];
      }

      return "Email envoyé avec succès";
    } on DioException catch (e) {
      final msg = e.response?.data?["message"] ?? "Erreur serveur";
      throw Exception(msg);
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _dio.post(
        "/users/reset-password",
        data: {
          "token": token,
          "newPassword": newPassword,
        },
      );
    } on DioException catch (e) {
      final msg = e.response?.data?["message"] ?? "Erreur serveur";
      throw Exception(msg);
    }
  }

  Future<void> changePassword(
      int userId,
      String oldPassword,
      String newPassword
      ) async{
    try{
      await _dio.patch(
        "/users/change-password",
        data: {
          "userId": userId,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }
      );
    }on DioException catch(e){
      final msg = e.response?.data?["message"] ?? "Erreur serveur";
      throw Exception(msg);
    }
  }
}
