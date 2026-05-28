import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_bus/utils/dio_interceptor.dart';

import '../models/dossier.dart';
import 'local_storage_service.dart';

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
        await _syncDossierUrls(dossier);
        print("DossierService: Statut recupere = ${dossier.statusDossier}");
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

  Future<void> _syncDossierUrls(Dossier dossier) async {
    final prefs = await SharedPreferences.getInstance();

    if (dossier.photoUrl != null && dossier.photoUrl!.isNotEmpty) {
      await prefs.setString(LocalStorageService.keyPhotoUrl, dossier.photoUrl!);
    }
    if (dossier.cinUrl != null && dossier.cinUrl!.isNotEmpty) {
      await prefs.setString(LocalStorageService.keyCinUrl, dossier.cinUrl!);
    }
    if (dossier.carteScolaireUrl != null &&
        dossier.carteScolaireUrl!.isNotEmpty) {
      await prefs.setString(
        LocalStorageService.keyCarteScolaireUrl,
        dossier.carteScolaireUrl!,
      );
    }
  }
}
