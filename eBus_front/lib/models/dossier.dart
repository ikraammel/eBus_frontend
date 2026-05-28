class Dossier {
  final int id;
  final String statusDossier;
  final String nom;
  final String prenom;
  final String? email;
  final String? tel;
  final String? adresse;
  final String? typeAbonnement;
  final String? cin;
  final String? cne;

  final String? dateDebutAbonnement;
  final String? dateFinAbonnement;

  final String? photoUrl;
  final String? cinUrl;
  final String? carteScolaireUrl;
  final String? attestationScolaireUrl;
  final String? rejectionReason;

  Dossier({
    required this.id,
    required this.statusDossier,
    required this.nom,
    required this.prenom,
    this.email,
    this.tel,
    this.adresse,
    this.typeAbonnement,
    this.cin,
    this.cne,
    this.dateDebutAbonnement,
    this.dateFinAbonnement,
    this.photoUrl,
    this.cinUrl,
    this.carteScolaireUrl,
    this.attestationScolaireUrl,
    this.rejectionReason,
  });

  factory Dossier.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};

    return Dossier(
      id: _asInt(json['id'] ?? user['id']),
      statusDossier: _asString(json['statusDossier'] ?? user['statusDossier']) ??
          "EN_ATTENTE",
      nom: _asString(json['nom'] ?? user['nom']) ?? 'Inconnu',
      prenom: _asString(json['prenom'] ?? user['prenom']) ?? 'Inconnu',
      email: _asString(json['email'] ?? user['email']),
      tel: _asString(json['tel'] ?? user['tel']),
      adresse: _asString(json['adresse'] ?? user['adresse']),
      typeAbonnement: _typeAbonnementFromJson(
        json['typeAbonnement'] ?? user['typeAbonnement'],
      ),
      cin: _asString(json['cin'] ?? user['cin']),
      cne: _asString(json['cne'] ?? user['cne']),
      rejectionReason: _asString(
        json['rejectionReason'] ??
            json['motifRejet'] ??
            json['rejection_reason'] ??
            user['motifRejet'],
      ),
      dateDebutAbonnement: _asString(json['dateDebutAbonnement']),
      dateFinAbonnement: _asString(json['dateFinAbonnement']),
      photoUrl: _firstString([
        json['photoUrl'],
        json['photo'],
        json['photoPath'],
        json['photoProfil'],
        json['profilePhoto'],
        json['avatarUrl'],
        json['imageUrl'],
        json['image'],
        json['imagePath'],
        json['profilePhotoUrl'],
        json['profileImageUrl'],
        json['profileImage'],
        json['profilePicture'],
        json['profilePictureUrl'],
        json['picture'],
        json['pictureUrl'],
        json['urlPhoto'],
        json['photoURL'],
        json['photo_url'],
        user['photoUrl'],
        user['photo'],
        user['photoPath'],
        user['photoProfil'],
        user['profilePhoto'],
        user['avatarUrl'],
        user['imageUrl'],
        user['image'],
        user['imagePath'],
        user['profilePhotoUrl'],
        user['profileImageUrl'],
        user['profileImage'],
        user['profilePicture'],
        user['profilePictureUrl'],
        user['picture'],
        user['pictureUrl'],
        user['urlPhoto'],
        user['photoURL'],
        user['photo_url'],
      ]),
      cinUrl: _asString(json['cinUrl'] ?? user['cinUrl']),
      carteScolaireUrl: _asString(
        json['carteScolaireUrl'] ?? user['carteScolaireUrl'],
      ),
      attestationScolaireUrl: _asString(
        json['attestationScolaireUrl'] ?? user['attestationScolaireUrl'],
      ),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static String? _firstString(List<dynamic> values) {
    for (final value in values) {
      final text = _asString(value);
      if (text != null) return text;
    }
    return null;
  }

  static String? _typeAbonnementFromJson(dynamic value) {
    if (value is Map) {
      return _asString(value['nom'] ?? value['name'] ?? value['type']);
    }
    return _asString(value);
  }
}
