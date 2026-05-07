// lib/services/realtime_bus_service.dart
//
// ✅ Ce fichier est CORRECT - aucune modification nécessaire.
//
// Ce service écoute Firebase Realtime Database directement depuis Flutter.
// Quand Spring Boot écrit une position dans Firebase, ce service la reçoit
// instantanément via un Stream.
//
// Utilisation dans le BusTrackingBloc :
//   _realtimeService.watchSingleBus("bus_1") → Stream<BusPosition?>
//   _realtimeService.watchAllBuses()          → Stream<List<BusPosition>>

import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import '../models/bus_position.dart';

class RealtimeBusService {
  final FirebaseDatabase _db = GetIt.instance<FirebaseDatabase>();

  /// 🗺️ Écoute tous les bus actifs en temps réel
  Stream<List<BusPosition>> watchAllBuses() {
    return _db.ref('buses').onValue.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];
      return data.entries
          .map((e) => BusPosition.fromMap(e.key, e.value as Map))
          .where((b) => b.actif)
          .toList();
    });
  }

  /// 📍 Écoute un bus précis en temps réel (pour la page de suivi)
  Stream<BusPosition?> watchSingleBus(String busKey) {
    return _db.ref('buses/$busKey').onValue.map((event) {
      if (!event.snapshot.exists) return null;
      final data = event.snapshot.value as Map?;
      if (data == null) return null;
      return BusPosition.fromMap(busKey, data);
    });
  }

  /// 🚌 Filtre les bus par ligne
  Stream<List<BusPosition>> watchBusesByLigne(int ligneId) {
    return watchAllBuses()
        .map((buses) => buses.where((b) => b.ligneId == ligneId).toList());
  }

  /// 📡 Envoie la position d'un bus vers Spring Boot (via POST)
  /// → Ce n'est PAS utilisé en temps normal (c'est le bus/chauffeur qui envoie)
  /// → Utile UNIQUEMENT pour le simulateur dans l'app admin
  Future<void> updateBusPosition({
    required String busKey,
    required double latitude,
    required double longitude,
    required int ligneId,
    required String numero,
    String immatriculation = '',
    String statut = 'en_service',
    double? vitesse,
  }) async {
    await _db.ref('buses/$busKey').update({
      'latitude': latitude,
      'longitude': longitude,
      'ligneId': ligneId,
      'numero': numero,
      'immatriculation': immatriculation,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'actif': true,
      'statut': statut,
      if (vitesse != null) 'vitesse': vitesse,
    });
  }

  Future<void> deactivateBus(String busKey) async {
    await _db.ref('buses/$busKey').update({'actif': false, 'statut': 'inactif'});
  }
}