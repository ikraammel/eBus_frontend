class StationModel {
  final String nom;
  final int ordre;
  final String direction;

  StationModel({
    required this.nom,
    required this.ordre,
    required this.direction,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      nom: json['nom'],
      ordre: json['ordre'],
      direction: json['direction'] ?? "",
    );
  }
}