class Station {
  final int? id;
  final String nom;
  final int ordre;
  final String direction;

  Station({
    this.id,
    required this.nom,
    required this.ordre,
    required this.direction,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      nom: json['nom'],
      ordre: json['ordre'],
      direction: json['direction'] ?? "",
    );
  }
  
  Map<String, dynamic> toJson() {
    return{
      'id': id,
      'nom': nom,
      'ordre': ordre,
      'direction': direction,
    };
  }
}