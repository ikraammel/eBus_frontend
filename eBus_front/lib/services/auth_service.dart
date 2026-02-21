import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/models/User.dart';
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
        'cin': await MultipartFile.fromFile(cin.path,
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
    }