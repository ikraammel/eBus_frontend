class Abonnement {
  final int id;

  final int userId;
  final String nom;
  final String prenom;
  final String email;

  final String dateDebut;
  final String dateFin;

  final String status; // ACTIF / EN_ATTENTE / EXPIRE
  final String typeNom;

  Abonnement({
    required this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.dateDebut,
    required this.dateFin,
    required this.status,
    required this.typeNom,
  });

  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      id: json['id'] ?? 0,

      userId: json['userId'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',

      dateDebut: json['dateDebut'] ?? '',
      dateFin: json['dateFin'] ?? '',

      status: json['status'] ?? 'EN_ATTENTE',
      typeNom: json['typeNom'] ?? '',
    );
  }
}