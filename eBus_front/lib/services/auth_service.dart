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
      // 🔥 Gestion complète des erreurs du backend
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;

        // 1️⃣ Si le backend renvoie juste un message string
        if (data is String) {
          throw Exception(data);
        }

        // 2️⃣ Si le backend renvoie un objet avec un champ "message"
        if (data is Map) {
          if (data.containsKey("message")) {
            throw Exception(data["message"]);
          }

          // 3️⃣ Si le backend renvoie un objet avec une liste d'erreurs de validation
          if (data.containsKey("errors") && data["errors"] is List) {
            final errors = data["errors"] as List;
            if (errors.isNotEmpty) {
              final messages = errors.map((e) => e["message"] ?? "").join("\n");
              throw Exception(messages);
            }
          }
        }
      }

      // 4️⃣ Si aucun format attendu n'a été trouvé
      throw Exception("Erreur serveur, veuillez réessayer");

    } catch (e) {
      // Erreur inattendue côté Flutter
      throw Exception("Erreur inattendue: ${e.toString()}");
    }

  }
}