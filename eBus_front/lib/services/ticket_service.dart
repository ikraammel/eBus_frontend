import 'package:dio/dio.dart';
import '../models/abonnement.dart';
import '../models/ticket.dart';
import '../models/type_abonnement.dart';
import '../utils/dio_interceptor.dart';

class TicketService {
  final Dio _dio = DioClient.dio;

  // ─────────────────────────────────────────────────────────────────────────
  // Tickets
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<Ticket>> getTickets() async {
    try {
      final res = await _dio.get('/tickets');
      if (res.statusCode == 200) {
        // Gestion robuste si les données sont dans un champ 'data' ou directes
        final List rawData = (res.data is List)
            ? res.data
            : (res.data is Map && res.data.containsKey('data'))
                ? res.data['data']
                : [];
        return rawData.map((e) => Ticket.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur getTickets: $e");
      return [];
    }
  }

  Future<void> createTicket(Ticket t) async {
    try {
      final data = t.toJson();
      data.remove('id');
      await _dio.post('/tickets', data: data);
    } catch (e) {
      throw Exception("Erreur lors de la création du ticket");
    }
  }

  Future<void> updateTicket(int id, Ticket t) async {
    try {
      await _dio.put('/tickets/$id', data: t.toJson());
    } catch (e) {
      throw Exception("Erreur lors de la modification du ticket");
    }
  }

  Future<void> deleteTicket(int id) async {
    try {
      await _dio.delete('/tickets/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression du ticket");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Admin : CRUD TypeAbonnement (offres)
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<TypeAbonnement>> getTypeAbonnements() async {
    try {
      final res = await _dio.get('/types-abonnement');
      if (res.statusCode == 200) {
        final List rawData = (res.data is List)
            ? res.data
            : (res.data is Map && res.data.containsKey('data'))
                ? res.data['data']
                : [];
        return rawData.map((e) => TypeAbonnement.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur getTypeAbonnements: $e");
      return [];
    }
  }

  Future<void> createAbonnement(TypeAbonnement t) async {
    try {
      await _dio.post('/types-abonnement', data: t.toJson());
    } catch (e) {
      throw Exception("Erreur lors de la création de l'abonnement");
    }
  }

  Future<void> updateAbonnement(int id, TypeAbonnement t) async {
    try {
      await _dio.put('/types-abonnement/$id', data: t.toJson());
    } catch (e) {
      throw Exception("Erreur lors de la modification de l'abonnement");
    }
  }

  Future<void> deleteAbonnement(int id) async {
    try {
      await _dio.delete('/types-abonnement/$id');
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'abonnement");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Abonnement utilisateur
  // ─────────────────────────────────────────────────────────────────────────

  /// Souscrit à un abonnement. Retourne l'URL Stripe ou lance une exception.
  Future<String?> subscribe(int userId, int typeId) async {
    try {
      final res = await _dio.post(
        '/abonnements/subscribe',
        queryParameters: {'userId': userId, 'typeId': typeId},
      );
      if (res.statusCode == 400) {
        throw Exception(res.data.toString());
      }
      final url = res.data.toString();
      return url.startsWith('http') ? url : null;
    } on DioException catch (e) {

        final msg = e.response?.data?.toString() ?? "Erreur réseau";

        // dossier rejeté
        if(msg.contains("rejeté")){
          throw Exception("DOSSIER_REJETE");
        }

        // dossier attente
        if(msg.contains("attente")){
          throw Exception("DOSSIER_EN_ATTENTE");
        }

        throw Exception(msg);

    } catch (e) {
      rethrow;
    }
  }

  /// Confirme le paiement en envoyant le session_id au backend.
  Future<String> confirmPayment(int abonnementId, String sessionId) async {
    try {
      final res = await _dio.post(
        '/abonnements/$abonnementId/confirm',
        queryParameters: {'sessionId': sessionId},
      );
      return res.data.toString(); // "ACTIF" ou "EN_ATTENTE"
    } catch (e) {
      print("Erreur confirmPayment: $e");
      return 'EN_ATTENTE';
    }
  }

  /// Poll simple du statut (backup si confirmPayment échoue).
  Future<String> getAbonnementStatus(int abonnementId) async {
    try {
      final res = await _dio.get('/abonnements/$abonnementId/status');
      return res.data.toString();
    } catch (e) {
      print("Erreur getAbonnementStatus: $e");
      return 'EN_ATTENTE';
    }
  }

  /// Abonnement courant de l'utilisateur (peut être null si aucun).
  Future<Abonnement?> getCurrentAbonnement(int userId) async {
    try {
      final res = await _dio.get('/abonnements/user/$userId');
      if (res.statusCode == 204 || res.data == null) return null;
      return Abonnement.fromJson(res.data);
    } catch (e) {
      print("Erreur getCurrentAbonnement: $e");
      return null;
    }
  }

  /// Historique de tous les abonnements de l'utilisateur.
  Future<List<Abonnement>> getHistoriqueAbonnements(int userId) async {
    try {
      final res = await _dio.get('/abonnements/user/$userId/historique');
      if (res.statusCode == 200) {
        final List rawData = (res.data is List) ? res.data : (res.data['data'] ?? []);
        return rawData.map((e) => Abonnement.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur getHistoriqueAbonnements: $e");
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Chargement combiné
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getAllOffers() async {
    final results = await Future.wait([getTickets(), getTypeAbonnements()]);
    return [...results[0], ...results[1]];
  }
}
