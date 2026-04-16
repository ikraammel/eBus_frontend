import 'package:dio/dio.dart';
import '../constants/constants.dart';
import '../models/objet_perdu.dart';
import '../models/statut_objet.dart';

class ObjetService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // ---------------- GET ALL ----------------
  Future<List<ObjetPerdu>> getAll() async {
    try {
      final response = await _dio.get('/api/objets/admin/all');

      final data = response.data;

      if (data is! List) {
        throw Exception("Format API invalide (expected List)");
      }

      return data
          .map((e) {
            try {
              return ObjetPerdu.fromJson(
                Map<String, dynamic>.from(e),
              );
            } catch (err) {
              print("parsing error objet: $err");
              return null;
            }
          })
          .whereType<ObjetPerdu>()
          .toList();
    } on DioException catch (e) {
      throw Exception("Erreur réseau: ${e.message}");
    }
  }

  // ---------------- DECLARE ----------------
  Future<ObjetPerdu> declare(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/objets/declaration',
        data: data,
      );

      if (response.data == null) {
        throw Exception("Réponse vide backend");
      }

      return ObjetPerdu.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception("Erreur déclaration: ${e.response?.data ?? e.message}");
    }
  }

  // ---------------- UPDATE STATUS ----------------
  Future<ObjetPerdu> updateStatut(int id, StatutObjet statut) async {
    try {
      final response = await _dio.put(
        '/api/objets/$id/statut',
        queryParameters: {
          'statut': statut.name.toUpperCase(),
        },
      );

      return ObjetPerdu.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception("Erreur update statut: ${e.response?.data ?? e.message}");
    }
  }

  // ---------------- GET BY ID ----------------
  Future<ObjetPerdu> getById(int id) async {
    try {
      final response = await _dio.get('/api/objets/$id');

      return ObjetPerdu.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception("Erreur getById: ${e.response?.data ?? e.message}");
    }
  }

  // ---------------- RECUPERE ----------------
  Future<ObjetPerdu> signalerRecupere(int id) async {
    try {
      final response =
          await _dio.post('/api/objets/$id/signaler-recupere');

      return ObjetPerdu.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception("Erreur signalerRecupere: ${e.response?.data ?? e.message}");
    }
  }

  // ---------------- DELETE ----------------
  Future<void> deleteObjet(int id) async {
    try {
      await _dio.delete('/api/objets/$id');
    } on DioException catch (e) {
      throw Exception("Erreur delete: ${e.response?.data ?? e.message}");
    }
  }
}
