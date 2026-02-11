class RegisterRequest {
  final String nom;
  final String prenom;
  final String email;
  final String tel;
  final String password;
  final String adresse;
  final String dateNaissance;
  final String typeAbonnement;
  final String CIN;
  final String CNE;

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.tel,
    required this.password,
    required this.adresse,
    required this.dateNaissance,
    required this.typeAbonnement,
    required this.CIN,
    required this.CNE,
});

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'tel': tel,
      'password': password,
      'adresse': adresse,
      'dateNaissance': dateNaissance,
      'abonnement': typeAbonnement,
      'CIN': CIN,
      'CNE': CNE,
    };
  }
}