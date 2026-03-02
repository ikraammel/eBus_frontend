import 'StationModel.dart';

class Ligne {
  final int id;
  final String numero;
  final double distance;
  final String startPoint;
  final String endPoint;
  final List<StationModel> stations;


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
    id: json['id'],
    numero: json['numero'],
    distance: json['distance'],
    startPoint: json['startPoint'],
    endPoint: json['endPoint'],
    stations: (json['stations'] as List)
      .map((e) => StationModel.fromJson(e))
      .toList(),
  );
}
}