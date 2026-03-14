import 'Station.dart';

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
      id: json['id']?.toInt(),
      numero: json['numero']?.toString() ?? '',
      distance: (json['distance'] ?? 0).toDouble(),
      startPoint: json['startPoint'] ?? '',
      endPoint: json['endPoint'] ?? '',
      stations: (json['stations'] as List? ?? [])
          .map((e) => Station.fromJson(e))
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
}