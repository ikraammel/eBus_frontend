class Station {
  final int? id;
  final String nom;
  final int ordre;
  final String direction;
  final double? latitude;
  final double? longitude;

  Station({
    this.id,
    required this.nom,
    required this.ordre,
    required this.direction,
    this.latitude,
    this.longitude,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as Map<String, dynamic>?;
    return Station(
      id: _asInt(json['id'] ?? json['stationId']),
      nom: (json['nom'] ?? json['name'] ?? json['stationNom'] ?? '').toString(),
      ordre: _asInt(json['ordre'] ?? json['order'] ?? json['rang']) ?? 0,
      direction: (json['direction'] ?? "").toString(),
      latitude: _asDouble(json['latitude'] ?? pos?['latitude']),
      longitude: _asDouble(json['longitude'] ?? pos?['longitude']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return{
      'id': id,
      'nom': nom,
      'ordre': ordre,
      'direction': direction,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
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
}
