import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../models/reclamation.dart';

class ReclamationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  Future<List<Reclamation>> getReclamations() async {
    final response = await _dio.get('/reclamations/all');
    print("Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      List data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map && response.data['reclamations'] != null) {
        data = response.data['reclamations'];
      } else {
        data = [];
      }
      return data.map((e) => Reclamation.fromJson(e)).toList();
    } else {
      throw Exception("Erreur chargement réclamations");
    }
  }

  Future<Reclamation> getReclamationById(int id) async {
    final response = await _dio.get('/reclamations/$id');
    if (response.statusCode == 200) {
      return Reclamation.fromJson(response.data);
    } else {
      throw Exception("Erreur récupération réclamation");
    }
  }

  Future<Reclamation> createReclamation(Reclamation reclamation) async {
    final response = await _dio.post('/reclamations/new', data: reclamation.toJson());
    if (response.statusCode == 200) {
      return Reclamation.fromJson(response.data);
    } else {
      throw Exception("Erreur création réclamation: ${response.data}");
    }
  }

  Future<Reclamation> updateReclamation(int id, Map<String, dynamic> patch) async {
    final response = await _dio.patch('/reclamations/$id', data: patch);
    if (response.statusCode == 200) {
      return Reclamation.fromJson(response.data);
    } else {
      throw Exception("Erreur modification réclamation: ${response.data}");
    }
  }

  Future<void> deleteReclamation(int id) async {
    final response = await _dio.delete('/reclamations/$id');
    if (response.statusCode == 200 || response.statusCode == 204) {
      print("Réclamation supprimée avec succès");
    } else {
      throw Exception("Erreur suppression réclamation");
    }
  }

  Future<List<Reclamation>> getReclamationsByDate(String date) async {
    final response = await _dio.get('/reclamations/date/$date');
    if (response.statusCode == 200) {
      List data = response.data;
      return data.map((e) => Reclamation.fromJson(e)).toList();
    } else {
      throw Exception("Erreur récupération réclamations par date");
    }
  }

  Future<List<Reclamation>> getReclamationsByStatus(String status) async {
    final response = await _dio.get('/reclamations/status/$status');
    if (response.statusCode == 200) {
      List data = response.data;
      return data.map((e) => Reclamation.fromJson(e)).toList();
    } else {
      throw Exception("Erreur récupération réclamations par status");
    }
  }
}