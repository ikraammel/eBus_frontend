import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/objet_perdu.dart';
import '../models/statut_objet.dart';

class ObjetService {
  final Dio _dio = DioClient.dio;

  // ---------------- GET ALL ----------------
  Future<List<ObjetPerdu>> getAll() async {
    try {
      final response = await _dio.get('/api/objets/admin/all');
      final data = response.data;
      if (data is! List) throw Exception("Format API invalide");
      return data.map((e) => ObjetPerdu.fromJson(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      throw Exception("Erreur réseau: ${e.message}");
    }
  }

  Future<ObjetPerdu> declare(Map<String, dynamic> data, XFile? image) async {
    try {
      FormData formData = FormData();

      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image.path, filename: image.name),
        ));
      }

      final response = await _dio.post(
        '/api/objets/declaration',
        data: formData,
      );

      return ObjetPerdu.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception("Erreur déclaration: ${e.response?.data ?? e.message}");
    }
  }

  // ---------------- UPDATE STATUS ----------------
  Future<ObjetPerdu> updateStatut(int id, StatutObjet statut) async {
    try {
      final response = await _dio.put(
        '/api/objets/$id/statut',
        queryParameters: {'statut': statut.name.toUpperCase()},
      );
      return ObjetPerdu.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception("Erreur update statut: ${e.message}");
    }
  }

  // ---------------- GET BY ID ----------------
  Future<ObjetPerdu> getById(int id) async {
    try {
      final response = await _dio.get('/api/objets/$id');
      return ObjetPerdu.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception("Erreur getById: ${e.message}");
    }
  }

  // ---------------- RECUPERE ----------------
  Future<ObjetPerdu> signalerRecupere(int id) async {
    try {
      final response = await _dio.post('/api/objets/$id/signaler-recupere');
      return ObjetPerdu.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception("Erreur signalerRecupere: ${e.message}");
    }
  }

  // ---------------- DELETE ----------------
  Future<void> deleteObjet(int id) async {
    try {
      await _dio.delete('/api/objets/$id');
    } on DioException catch (e) {
      throw Exception("Erreur delete: ${e.message}");
    }
  }
}
