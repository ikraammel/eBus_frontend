class TypeAbonnement {
  final int? id;
  final String nom;
  final double prix;
  final int dureeMois;
  final bool actif;

  TypeAbonnement({
    this.id,
    required this.nom,
    required this.prix,
    required this.dureeMois,
    required this.actif,
  });

  factory TypeAbonnement.fromJson(Map<String, dynamic> json) {
    return TypeAbonnement(
      id: json['id'],
      nom: json['nom'],
      prix: json['prix'].toDouble(),
      dureeMois: json['dureeMois'],
      actif: json['actif'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prix': prix,
      'dureeMois': dureeMois,
      'actif': actif,
    };
  }
}