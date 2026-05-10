import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import '../models/ligne.dart';
import '../models/station.dart';
import '../services/bus_service.dart';

// ─── Coordonnées GPS réelles des stations de Safi ────────────────────────────
// Clé = id de la station, valeur = [latitude, longitude]
const Map<int, List<double>> _stationCoords = {
  1:  [32.3004,  -9.2362], // Terminus EL COURSE
  2:  [32.2991,  -9.2378], // Quartier OURIDA A
  3:  [32.2980,  -9.2390], // Quartier Anas A
  4:  [32.2968,  -9.2401], // Quartier Sania A
  5:  [32.2955,  -9.2415], // Quartier Jnane El Mestari A
  6:  [32.2942,  -9.2428], // Pd point Jerifat R
  7:  [32.2930,  -9.2440], // Rd point Jerifat A
  8:  [32.2918,  -9.2455], // Quartier Safi 2
  9:  [32.2906,  -9.2467], // Quartier Azib Derai A
  10: [32.2893,  -9.2480], // Cour d'appel A
  11: [32.2880,  -9.2493], // Lycée Khawarizmi A
  12: [32.2866,  -9.2507], // Quartier Moulay El Hassan A
  13: [32.2852,  -9.2520], // Quartier Oued El Bacha A
  14: [32.2838,  -9.2532], // Quartier Errahma A
  15: [32.2824,  -9.2544], // Mosqué Al Hikma A
  16: [32.2810,  -9.2556], // av belkhadir Panorama A
  17: [32.2796,  -9.2568], // av belkhadir a coté ENSA A
  18: [32.2781,  -9.2580], // Terminus faculté
  19: [32.2950,  -9.2700], // Terminus LO1 Plage
  20: [32.2960,  -9.2680], // arret a coté port R
  21: [32.2870,  -9.2510], // Quartier Oued El Bacha R
  22: [32.2855,  -9.2495], // Quartier Moulay El Hassan R
  23: [32.2872,  -9.2488], // Lycée Khawarizmi R
  24: [32.2885,  -9.2476], // Cour d'appel R
  25: [32.2897,  -9.2463], // Quartier Azib Derai R
  26: [32.2910,  -9.2450], // av hassan II en face Acima
  27: [32.2922,  -9.2437], // Rd point Jerifat R
  28: [32.2935,  -9.2422], // av kennedy R
  29: [32.2948,  -9.2408], // av kennedy a coté de la gare routiere R
  30: [32.2960,  -9.2395], // Quartier Sania R
  31: [32.2973,  -9.2382], // Quartier Anas R
  32: [32.2986,  -9.2368], // Quartier OURIDA R
  33: [32.3120,  -9.2280], // Terminus Moulay Youssef
  34: [32.3105,  -9.2295], // Dar moharib A
  35: [32.3090,  -9.2310], // arret en face gare routiere
  36: [32.2960,  -9.2420], // Quartier Janane El Mestari R
  37: [32.2870,  -9.2600], // Quartier Corse
  38: [32.2855,  -9.2615], // Quartier Labiar A
  39: [32.2840,  -9.2630], // Quartier Sidi Mbarek A
  40: [32.2826,  -9.2645], // Souk Nsa A
  41: [32.2812,  -9.2660], // Dar Bouaouda A
  42: [32.2798,  -9.2675], // Quartier Kolea A
  43: [32.2784,  -9.2690], // rue chaimi avant lycée zarktouni
  44: [32.2770,  -9.2705], // Quartier 108 A
  45: [32.2756,  -9.2720], // Quartier Kawki Sud A
  46: [32.2742,  -9.2735], // Terminus Amouni
  47: [32.3075,  -9.2325], // Terminus Place Idriss II
  48: [32.3060,  -9.2340], // Terminus IDRISS II
  49: [32.2918,  -9.2432], // Quartier Saida 1 A
  50: [32.2905,  -9.2445], // Maison des jeunes Jerifa A
  51: [32.2892,  -9.2458], // Collège Ahmed Taib Benhima A
  52: [32.2879,  -9.2471], // Quartier Wiam A
  53: [32.2866,  -9.2484], // Quartier Hana 1 A
  54: [32.2853,  -9.2497], // quariat chemss avant ph mestari A
  55: [32.2840,  -9.2510], // Quartier Kariat Chems A
  56: [32.2827,  -9.2523], // Terminus Kariat chems
  57: [32.3050,  -9.2355], // AV sidi Ouassel Quartier Industriel A
  58: [32.3035,  -9.2370], // av sidi ouassel Gare ferroviaire A
  60: [32.3020,  -9.2385], // Av Kennedy A
  61: [32.2815,  -9.2555], // Lycée Moulay Abdallah A
  62: [32.2800,  -9.2568], // Lycée Al-Faqih Al-Kanuni A
  63: [32.2786,  -9.2581], // Quartier Sidi Abdelkrim nord A
  65: [32.2600,  -9.2750], // Terminus Borj Nador
  66: [32.2620,  -9.2720], // Caserne Sidi Bouzid R
  67: [32.2640,  -9.2695], // OFPPT Hotellerie
  68: [32.2660,  -9.2670], // ENSA Safi R
  69: [32.2680,  -9.2645], // Corniche Sidi Bouzid R
  70: [32.2700,  -9.2620], // Plage Ras Lafaa R
  71: [32.2720,  -9.2595], // Mosqué Al Hikma R
  72: [32.2740,  -9.2570], // Quartier Errahma R
  73: [32.2760,  -9.2545], // Quartier Oued Al Bacha R
  74: [32.2780,  -9.2520], // rue arsalan au niveau quartier chkkouri R
  75: [32.2800,  -9.2495], // route benslimane BAB CHAABAA A
  76: [32.2820,  -9.2470], // Sidi boudhab R
  77: [32.3085,  -9.2318], // Gare Routière R
  78: [32.3040,  -9.2363], // AV sidi Ouassel Gare ferroviaire R
  79: [32.3025,  -9.2378], // Avenue Sidi Ouassel
  80: [32.3070,  -9.2332], // Place Idriss II L O1-O2-O9-25
};

class BusSimulator {
  final FirebaseDatabase _db = GetIt.instance<FirebaseDatabase>();
  final BusService _busService = BusService();
  final Map<String, Timer> _timers = {};
  final Map<String, _BusState> _states = {};

  Future<void> startAll(List<Ligne> lignes) async {
    stopAll(); // Arrête proprement avant de redémarrer

    for (final ligne in lignes) {
      // Enrichit les stations avec les coordonnées GPS si elles sont nulles
      final enrichedStations = _enrichStations(ligne.stations);

      final stations = enrichedStations
          .where((s) => s.latitude != null && s.longitude != null)
          .toList()
        ..sort((a, b) => a.ordre.compareTo(b.ordre));

      if (stations.length < 2) continue;

      final busKey = 'bus_${ligne.id}';

      // Récupère l'immatriculation depuis l'API
      String immatriculation = 'BUS-L${ligne.numero}';
      try {
        final buses = await _busService.getBusesByLigne(ligne.id!);
        if (buses.isNotEmpty) {
          immatriculation = buses.first.immatriculation;
        }
      } catch (_) {
        // Garde la valeur par défaut
      }

      // Décalage aléatoire pour que les bus soient à des endroits différents
      final initialProgress = (ligne.id! % (stations.length > 1 ? stations.length : 1)) /
          (stations.length > 1 ? stations.length : 1).toDouble();

      _states[busKey] = _BusState(
        stations: stations,
        immatriculation: immatriculation,
        initialProgress: initialProgress,
      );
      _startBus(busKey, ligne, immatriculation);
    }
  }

  /// Enrichit les stations avec des coordonnées GPS depuis la table locale
  List<Station> _enrichStations(List<Station> stations) {
    return stations.map((s) {
      if (s.latitude != null && s.longitude != null) return s;
      final coords = s.id != null ? _stationCoords[s.id] : null;
      if (coords == null) return s;
      return Station(
        id: s.id,
        nom: s.nom,
        ordre: s.ordre,
        direction: s.direction,
        latitude: coords[0],
        longitude: coords[1],
      );
    }).toList();
  }

  void _startBus(String busKey, Ligne ligne, String immatriculation) {
    _timers[busKey] = Timer.periodic(const Duration(seconds: 2), (_) async {
      final state = _states[busKey];
      if (state == null) return;

      final pos = state.nextPosition();
      final vitesse = state.estimatedSpeed;

      await _db.ref('buses/$busKey').update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'ligneId': ligne.id,
        'numero': ligne.numero,
        'immatriculation': immatriculation,
        'actif': true,
        'statut': 'en_service',
        'vitesse': vitesse,
        'prochainArretIndex': state.nextStationIndex,
      });
    });
  }

  void stop(String busKey) {
    _timers[busKey]?.cancel();
    _timers.remove(busKey);
  }

  void stopAll() {
    for (final t in _timers.values) t.cancel();
    _timers.clear();
    _states.clear();
  }
}

// ─── État interne d'un bus ────────────────────────────────────────────────────

class _BusState {
  final List<Station> stations;
  final String immatriculation;

  int _segmentIndex = 0;
  double _progress = 0.0;
  bool _forward = true;
  _LatLng? _lastPos;
  int _lastTime = 0;
  double _estimatedSpeed = 30.0;

  _BusState({
    required this.stations,
    required this.immatriculation,
    double initialProgress = 0.0,
  }) {
    // Positionne le bus à un endroit différent sur la ligne au démarrage
    if (initialProgress > 0 && stations.length > 1) {
      final totalSegments = stations.length - 1;
      final targetSegment = (initialProgress * totalSegments).floor()
          .clamp(0, totalSegments - 1);
      _segmentIndex = targetSegment;
      _progress = (initialProgress * totalSegments) - targetSegment;
    }
  }

  double get estimatedSpeed => _estimatedSpeed;

  int get nextStationIndex {
    if (_forward) {
      return (_segmentIndex + 1).clamp(0, stations.length - 1);
    } else {
      return _segmentIndex.clamp(0, stations.length - 1);
    }
  }

  _LatLng nextPosition() {
    if (_segmentIndex < 0 || _segmentIndex >= stations.length - 1) {
      _segmentIndex = 0;
      _forward = true;
      _progress = 0.0;
    }

    final from = stations[_segmentIndex];
    final toIndex = _forward ? _segmentIndex + 1 : _segmentIndex - 1;

    if (toIndex < 0 || toIndex >= stations.length) {
      _forward = !_forward;
      return _LatLng(from.latitude!, from.longitude!);
    }

    final to = stations[toIndex];

    final lat = from.latitude! + (to.latitude! - from.latitude!) * _progress;
    final lng = from.longitude! + (to.longitude! - from.longitude!) * _progress;

    // Calcul vitesse estimée
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastPos != null && _lastTime > 0) {
      final dt = (now - _lastTime) / 3600000;
      final dist = _haversine(_lastPos!.latitude, _lastPos!.longitude, lat, lng);
      if (dt > 0 && dist > 0) {
        _estimatedSpeed = (dist / dt).clamp(0.0, 90.0);
      }
    }
    _lastPos = _LatLng(lat, lng);
    _lastTime = now;

    _progress += 0.04;
    if (_progress >= 1.0) {
      _progress = 0.0;
      if (_forward) {
        _segmentIndex++;
        if (_segmentIndex >= stations.length - 1) {
          _forward = false;
          _segmentIndex = stations.length - 2;
        }
      } else {
        _segmentIndex--;
        if (_segmentIndex < 0) {
          _forward = true;
          _segmentIndex = 0;
        }
      }
    }
    return _LatLng(lat, lng);
  }

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) *
            cos(_toRad(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;
}

class _LatLng {
  final double latitude;
  final double longitude;
  _LatLng(this.latitude, this.longitude);
}