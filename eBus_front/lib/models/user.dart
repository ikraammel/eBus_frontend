import '../enums/enums.dart';

class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final Enum role;
  final String tel;
  final String adresse;
  final String cin;
  final String? cne;
  final String? statusDossier; // Corrigé de statutDossier à statusDossier

  final String dateNaissance;
  final String? typeAbonnement;
  final String? photoUrl;
  final String? carteScolaireUrl;
  final String? cinUrl;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.tel,
    required this.adresse,
    required this.dateNaissance,
    required this.cin,
    this.cne,
    this.statusDossier,
    this.typeAbonnement,
    this.photoUrl,
    this.carteScolaireUrl,
    this.cinUrl,
  });

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: Role.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => Role.USER
      ),
      tel: json['tel'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'],
      statusDossier: json['statusDossier']?.toString() ?? "EN_ATTENTE", // Corrigé ici
      typeAbonnement: json['typeAbonnement']?.toString(),
      photoUrl: json['photoUrl'],
      carteScolaireUrl: json['carteScolaireUrl'],
      cinUrl: json['cinUrl'],
      cin: json['cin'],
      cne: json['cne']?.toString(),
    );
  }
}
