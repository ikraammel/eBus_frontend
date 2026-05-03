import 'package:dio/dio.dart';
import 'package:smart_bus/constants/constants.dart';
import '../models/ticket.dart';
import '../models/type_abonnement.dart';

class TicketService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
  ));

  // --- GESTION DES TICKETS (ADMIN) ---
  Future<List<Ticket>> getTickets() async {
    try {
      final res = await _dio.get('/tickets');
      if (res.statusCode == 200) {
        return (res.data as List).map((e) => Ticket.fromJson(e)).toList();
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
      data.remove('id'); // L'ID est généré par le backend
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

  // --- GESTION DES ABONNEMENTS (ADMIN) ---
  Future<List<TypeAbonnement>> getTypeAbonnements() async {
    try {
      final res = await _dio.get('/types-abonnement');
      if (res.statusCode == 200) {
        return (res.data as List).map((e) => TypeAbonnement.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur getTypeAbonnements: $e");
      return [];
    }
  }

  Future<void> createAbonnement(TypeAbonnement t) async {
    try {
      final data = t.toJson();
      // L'ID ne doit pas être envoyé pour une création
      await _dio.post('/types-abonnement', data: data);
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

  // --- ACTIONS UTILISATEUR ---
  Future<bool> subscribe(int userId, int typeId) async {
    try {
      final res = await _dio.post(
        '/abonnements',
        queryParameters: {
          'userId': userId,
          'typeId': typeId,
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getAllOffers() async {
    final results = await Future.wait([
      getTickets(),
      getTypeAbonnements(),
    ]);
    return [...results[0], ...results[1]];
  }
}
