import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_bus/constants/constants.dart';

class BusPositionApiService {
  static final String _baseUrl = AppConstants.baseUrl;

  /// Envoie la position GPS d'un bus au backend Spring Boot.
  ///
  /// [busId]    : ID du bus dans ta base de données MySQL
  /// [latitude] : Latitude GPS
  /// [longitude]: Longitude GPS
  /// [vitesse]  : Vitesse en km/h (0.0 si inconnue)
  /// [statut]   : "en_service" | "en_retard" | "inactif"
  Future<bool> sendPosition({
    required int busId,
    required double latitude,
    required double longitude,
    double vitesse = 0.0,
    String statut = 'en_service',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/bus/$busId/position'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'vitesse': vitesse,
          'statut': statut,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Position envoyée - Bus $busId ($latitude, $longitude)');
        return true;
      } else {
        print('❌ Erreur backend ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Connexion impossible au backend: $e');
      return false;
    }
  }
}