import 'package:dio/dio.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';
import '../models/dossier.dart';

class DossierService {
  final Dio _dio = DioClient.dio;

  Future<Dossier?> getMyDossier(int? userId) async {
    try {
      if (userId == null) {
        print("DossierService: userId est null, annulation de l'appel");
        return null;
      }

      print("DossierService: Chargement du dossier pour l'utilisateur $userId...");
      final response = await _dio.get(
        '/users/me/dossier',
        queryParameters: {
          "id": userId,
        },
      );
      print("RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final dossier = Dossier.fromJson(response.data);
        print("DossierService: Statut récupéré = ${dossier.statusDossier}");
        return dossier;
      }
      return null;
    } on DioException catch (e) {
      print("Erreur Dio DossierService: ${e.message}");
      return null;
    } catch (e) {
      print("Erreur inattendue DossierService: $e");
      return null;
    }
  }
}
