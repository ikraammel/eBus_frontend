import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/dossier.dart';

class AdminDossierService {
  final Dio _dio = DioClient.dio;

  // Récupérer TOUS les dossiers (en attente ou déjà traités)
  Future<List<Dossier>> getAllDossiers() async {
    try {
      final response = await _dio.get(
        '/admin/dossiers',
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      if (kDebugMode) {
        print("ADMIN ALL DOSSIERS (GET): ${response.data}");
      }
      if (response.statusCode == 200) {
        final data = _extractDossierList(response.data);
        return data
            .whereType<Map>()
            .map((e) => Dossier.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          "Le chargement des dossiers prend trop de temps. Veuillez reessayer.",
        );
      }
      throw Exception("Erreur lors du chargement des dossiers: ${e.message}");
    } catch (e) {
      throw Exception("Erreur lors du chargement des dossiers: $e");
    }
  }

  Future<Dossier?> getDossierById(int id) async {
    try {
      final response = await _dio.get(
        '/admin/dossiers/$id',
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        return Dossier.fromJson(Map<String, dynamic>.from(response.data));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractDossierList(dynamic payload) {
    if (payload is List) return payload;

    if (payload is Map) {
      for (final key in ['data', 'dossiers', 'content', 'items', 'results']) {
        final value = payload[key];
        if (value is List) return value;
      }
    }

    return [];
  }

  // Valider un dossier
  Future<void> validerDossier(int id) async {
    try {
      await _dio.patch('/admin/dossiers/$id/valider');
    } catch (e) {
      throw Exception("Erreur lors de la validation: $e");
    }
  }

  // Rejeter un dossier
  Future<void> rejeterDossier(int id,String reason) async {
    try {
      await _dio.post(
          '/admin/dossiers/$id/rejeter',
        data: {
          "rejectionReason": reason,
        },
      );
    } catch (e) {
      throw Exception("Erreur lors du rejet: $e");
    }
  }
}
