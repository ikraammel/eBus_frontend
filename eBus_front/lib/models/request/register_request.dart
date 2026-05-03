class RegisterRequest {
  final String nom;
  final String prenom;
  final String email;
  final String tel;
  final String password;
  final String adresse;
  final String dateNaissance;
  final int abonnementId;
  final String cin;
  final String? cne;

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.tel,
    required this.password,
    required this.adresse,
    required this.dateNaissance,
    required this.abonnementId,
    required this.cin,
    this.cne,
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
      'abonnementId': abonnementId,
      'cin': cin,
      'cne': cne,
    };
  }
}
