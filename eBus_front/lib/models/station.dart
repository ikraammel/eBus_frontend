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
      id: json['id'],
      nom: json['nom'],
      ordre: json['ordre'],
      direction: json['direction'] ?? "",
      latitude: (pos?['latitude'] as num?)?.toDouble(),
      longitude: (pos?['longitude'] as num?)?.toDouble(),
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
}