class Dossier {
  final int id;
  final String statusDossier;
  final String nom;
  final String prenom;
  final String? cin;
  final String? cne;

  final String? dateDebutAbonnement;
  final String? dateFinAbonnement;

  final String? photoUrl;
  final String? cinUrl;
  final String? carteScolaireUrl;
  final String? rejectionReason;

  Dossier({
    required this.id,
    required this.statusDossier,
    required this.nom,
    required this.prenom,
    this.cin,
    this.cne,
    this.dateDebutAbonnement,
    this.dateFinAbonnement,
    this.photoUrl,
    this.cinUrl,
    this.carteScolaireUrl,
    this.rejectionReason,
  });

  factory Dossier.fromJson(Map<String, dynamic> json) {
    return Dossier(
      id: json['id'] ?? 0,
      statusDossier: json['statusDossier'] ?? "EN_ATTENTE",
      nom: json['nom'] ?? 'Inconnu',
      prenom: json['prenom'] ?? 'Inconnu',
      cin: json['cin']?.toString(),
      cne: json['cne']?.toString(),
      rejectionReason: json['rejectionReason']?.toString(),

      dateDebutAbonnement: json['dateDebutAbonnement'],
      dateFinAbonnement: json['dateFinAbonnement'],

      photoUrl: json['photoUrl'],
      cinUrl: json['cinUrl'],
      carteScolaireUrl: json['carteScolaireUrl'],
    );
  }
}
