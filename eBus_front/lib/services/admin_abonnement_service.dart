import 'package:dio/dio.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/abonnement.dart';

class AdminAbonnementService {
  final Dio _dio = DioClient.dio;

  // Récupérer tous les abonnements pour le monitoring admin
  Future<List<Abonnement>> getAllAbonnements() async {
    try {
      final response = await _dio.get('/abonnements');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Abonnement.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Erreur lors du chargement des abonnements: $e");
    }
  }
}
