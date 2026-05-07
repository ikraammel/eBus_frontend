class Horaire {
  final int? id;
  final int ligneId;
  final String heureDepart;
  final String heureArrivee;
  final String jours;

  Horaire({
    this.id,
    required this.ligneId,
    required this.heureDepart,
    required this.heureArrivee,
    required this.jours,
  });

  factory Horaire.fromJson(Map<String, dynamic> json) {
    return Horaire(
      id: json['id']?.toInt(),
      ligneId: json['ligneId']?.toInt() ?? 0,
      heureDepart: json['heureDepart'] ?? '',
      heureArrivee: json['heureArrivee'] ?? '',
      jours: json['jours'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'ligneId': ligneId,
    'heureDepart': heureDepart,
    'heureArrivee': heureArrivee,
    'jours': jours,
  };

  Horaire copyWith({
    int? id,
    int? ligneId,
    String? heureDepart,
    String? heureArrivee,
    String? jours,
  }) {
    return Horaire(
      id: id ?? this.id,
      ligneId: ligneId ?? this.ligneId,
      heureDepart: heureDepart ?? this.heureDepart,
      heureArrivee: heureArrivee ?? this.heureArrivee,
      jours: jours ?? this.jours,
    );
  }
}