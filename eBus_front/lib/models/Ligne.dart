class Ligne {
  final int id;
  final String numero;
  final double distance;
  final String startPoint;
  final String endPoint;

Ligne({
  required this.id,
  required this.numero,
  required this.distance,
  required this.startPoint,
  required this.endPoint,
});

factory Ligne.fromJson(Map<String, dynamic> json) {
  return Ligne(
    id: json['id'],
    numero: json['numero'],
    distance: json['distance'],
    startPoint: json['startPoint'],
    endPoint: json['endPoint'],
  );
}
}