import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/models/user.dart';
import 'package:smart_bus/models/request/register_request.dart';
import 'package:http_parser/http_parser.dart';


class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<User> login(String email, String password) async {
    try{
      final response = await _dio.post(
        '/users/login',
        data: {
          'email': email,
          'password': password,
        },
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

  Future<User> register(
      RegisterRequest request,
      XFile photo,
      XFile carteScolaire,
      XFile cin
      ) async {
    try{
      final userJson = jsonEncode(request.toJson());

      FormData formData = FormData.fromMap({
        'user':MultipartFile.fromString(
          userJson,
          filename: 'user.json',
          contentType: MediaType.parse('application/json'),),
        'photo': await MultipartFile.fromFile(photo.path,
            filename: photo.name),
        'carteScolaire': await MultipartFile.fromFile(carteScolaire.path,
            filename: carteScolaire.name),
        'cinPhoto': await MultipartFile.fromFile(cin.path,
            filename: cin.name),
      });

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
    }
