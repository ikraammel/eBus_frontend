import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smart_bus/models/User.dart';
import 'package:smart_bus/models/request/register_request.dart';

class AuthService {
  final String base_url = "http://10.0.2.2:8080";

  Future<User> login(String email, String password) async {
    final url = Uri.parse('$base_url/users/login');
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

  Future<User> register(RegisterRequest request) async {
    final url = Uri.parse('$base_url/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if(response.statusCode == 200 || response.statusCode == 201){
       final Map<String, dynamic> data =jsonDecode(response.body);
       return User.fromJson(data);
    }else{
      throw Exception('Erreur lors de l\'inscription: ${response.statusCode}');
    }
  }
}