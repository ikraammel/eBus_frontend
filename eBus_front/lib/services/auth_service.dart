import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/constants/constants.dart';
import 'package:smart_bus/models/User.dart';
import 'package:smart_bus/models/request/register_request.dart';
import 'package:http_parser/http_parser.dart';


class AuthService {
  final String baseUrl = "${AppConstants.baseUrl}";
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email,'password':password}),
    );

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    }else{
      throw Exception('Erreur lors de la connexion: ${response.statusCode}');
    }
  }

  Future<User> register(
      RegisterRequest request,
      XFile photo,
      XFile carteScolaire,
      XFile cin
      ) async {
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

    if(response.statusCode == 200 || response.statusCode == 201){
       return User.fromJson(response.data);
    }else{
      throw Exception('Erreur lors de l\'inscription: ${response.statusCode}');
    }
  }
}