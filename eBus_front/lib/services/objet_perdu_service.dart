import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_bus/models/objet_perdu.dart';

class ObjetPerduService {

 static const String _baseUrl = 'http://localhost:8080';


  Future<List<ObjetPerdu>> getAll() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/objets-perdus'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ObjetPerdu.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement objets');
    }
  }
 Future<void> updateStatus(int id, String status) async {
   final response = await http.patch(
     Uri.parse('$_baseUrl/objets-perdus/$id/status?status=$status'),
     headers: {'Content-Type': 'application/json'},
   );
   if (response.statusCode != 200) {
     throw Exception('Erreur mise à jour statut');
   }
 }

  Future<ObjetPerdu> create(ObjetPerdu objet) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/objets-perdus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(objet.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ObjetPerdu.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur soumission');
    }
  }
}
