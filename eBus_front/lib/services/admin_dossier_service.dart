import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/dossier.dart';

class AdminDossierService {
  final Dio _dio = DioClient.dio;

  // Récupérer TOUS les dossiers (en attente ou déjà traités)
  Future<List<Dossier>> getAllDossiers() async {
    try {
      final response = await _dio.get('/admin/dossiers'); 
      if (kDebugMode) {
        print("ADMIN ALL DOSSIERS (GET): ${response.data}");
      }
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Dossier.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Erreur lors du chargement des dossiers: $e");
    }
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
