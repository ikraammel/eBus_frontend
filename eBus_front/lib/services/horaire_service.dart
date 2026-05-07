import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../models/horaire.dart';

class HoraireService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  /// Récupère tous les horaires d'une ligne
  Future<List<Horaire>> getHorairesByLigne(int ligneId) async {
    try {
      final response = await _dio.get('/horaires/ligne/$ligneId');
      if (response.statusCode == 200) {
        final data = response.data;
        List raw;
        if (data is List) {
          raw = data;
        } else if (data is Map && data['horaires'] != null) {
          raw = data['horaires'];
        } else {
          raw = [];
        }
        return raw.map((e) => Horaire.fromJson(e)).toList();
      }
      throw Exception("Erreur chargement horaires");
    } catch (e) {
      throw Exception("Erreur chargement horaires: $e");
    }
  }

  /// Crée un nouvel horaire
  Future<Horaire> createHoraire(Horaire horaire) async {
    final response =
    await _dio.post('/horaires/new', data: horaire.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Horaire.fromJson(response.data);
    }
    throw Exception("Erreur création horaire: ${response.data}");
  }

  /// Modifie un horaire existant
  Future<Horaire> updateHoraire(int id, Horaire horaire) async {
    final response =
    await _dio.patch('/horaires/$id', data: horaire.toJson());
    if (response.statusCode == 200) {
      return Horaire.fromJson(response.data);
    }
    throw Exception("Erreur modification horaire: ${response.data}");
  }

  /// Supprime un horaire
  Future<void> deleteHoraire(int id) async {
    final response = await _dio.delete('/horaires/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur suppression horaire");
    }
  }
}