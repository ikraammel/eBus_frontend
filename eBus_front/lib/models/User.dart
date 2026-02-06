class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final String tel;
  final String adresse;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.tel,
    required this.adresse,
  });

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'nom':nom,
      'prenom':prenom,
      'email':email,
      'role':role,
      'tel':tel,
      'adresse':adresse,
    };
  }
}

