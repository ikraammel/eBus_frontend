class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String tel;
  final String adresse;

  final String dateNaissance;
  final String? typeAbonnement;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.tel,
    required this.adresse,
    required this.dateNaissance,
     this.typeAbonnement,
  });

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      role: json['role'],
      tel: json['tel'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'],
      typeAbonnement: json['typeAbonnement'].toString(),
    );
  }

}

