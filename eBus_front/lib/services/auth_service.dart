import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  final String base_url = "http://10.0.2.2:8080";

  Future<Map<String,dynamic>> login(String email, String password) async {
    final url = Uri.parse('$base_url/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email,'password':password}),
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      throw Exception('Erreur lors de la connexion: ${response.statusCode}');
    }
  }

}