class Abonnement {
  final int id;
  final int userId;
  final String nom;
  final String prenom;
  final String email;
  final String dateDebut;
  final String dateFin;
  final String status; // ACTIF / EN_ATTENTE / EXPIRE / REFUSE
  final String typeNom;
  final double prix;

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
    required this.prix,
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
      prix: (json['prix'] ?? 0).toDouble(),
    );
  }


  int get joursRestants {
    if (dateFin.isEmpty) return 0;
    try {
      final fin = DateTime.parse(dateFin);
      final diff = fin.difference(DateTime.now()).inDays;
      return diff < 0 ? 0 : diff;
    } catch (_) {
      return 0;
    }
  }

  bool get isActif => status == 'ACTIF' && joursRestants > 0;
  bool get isEnAttente => status == 'EN_ATTENTE';
  bool get isExpire => status == 'EXPIRE' || (status == 'ACTIF' && joursRestants == 0);
  bool get isRefuse => status == 'REFUSE';
}
