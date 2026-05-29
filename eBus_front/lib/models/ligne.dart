import 'station.dart';

class Ligne {
  final int? id;
  final String numero;
  final double? distance;
  final String startPoint;
  final String endPoint;
  final List<Station> stations;


  Ligne({
  required this.id,
  required this.numero,
  required this.distance,
  required this.startPoint,
  required this.endPoint,
  required this.stations,
  });

  factory Ligne.fromJson(Map<String, dynamic> json) {
    return Ligne(
      id: _asInt(json['id']),
      numero: json['numero']?.toString() ?? '',
      distance: _asDouble(json['distance']),
      startPoint: (json['startPoint'] ?? json['depart'] ?? json['pointDepart'] ?? '').toString(),
      endPoint: (json['endPoint'] ?? json['arrivee'] ?? json['pointArrivee'] ?? '').toString(),
      stations: _stationList(json)
          .whereType<Map>()
          .map((e) => Station.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'id': id,
      'numero': numero,
      'distance': distance,
      'startPoint': startPoint,
      'endPoint': endPoint,
      "stations": stations.map((e) => e.toJson()).toList(),
    };
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static List _stationList(Map<String, dynamic> json) {
    final value = json['stations'] ??
        json['stationOrdres'] ??
        json['stationOrdreDtos'] ??
        json['stationOrdreList'];
    return value is List ? value : const [];
  }
}
