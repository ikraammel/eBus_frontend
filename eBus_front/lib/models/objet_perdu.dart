import 'statut_objet.dart';
import 'package:smart_bus/enums/enums.dart';

class ObjetPerdu {
  final int? id;
  final String description;
  final DateTime dateDeclaration;
  final String? nom;
  final int? ligneId; 
  final String? ligneNom;
  final String? contact;
  final StatutObjet statut;
  final TypeAnnonce type;
  final String? userNom;
  final int? userId;
  final String? imageUrl;
  final String? busImmatriculation;

  ObjetPerdu({
    this.id,
    required this.description,
    required this.dateDeclaration,
    this.busImmatriculation,
    this.nom,
    this.ligneId,
    this.ligneNom,
    this.contact,
    required this.statut,
    required this.type,
    this.userNom,
    this.userId,
    this.imageUrl,
  });

  factory ObjetPerdu.fromJson(Map<String, dynamic> json) {
    return ObjetPerdu(
      id: json['id'] as int?,
      nom: json['nom'] ?? 'Sans nom',
      busImmatriculation: json['busImmatriculation'] as String?,
      description: json['description'] ?? '',
      ligneId: json['ligneId'] as int?, 
      ligneNom: json['ligneNom'] as String?, // Alignement avec le Response DTO
      contact: json['contact'],
      dateDeclaration: json['dateDeclaration'] != null
          ? DateTime.parse(json['dateDeclaration'])
          : DateTime.now(),
      statut: _parseStatut(json['statut']),
      type: _parseType(json['type']),
      userNom: json['userNom'] as String?,
      userId: json['userId'] as int?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  static StatutObjet _parseStatut(String? statusName) {
    if (statusName == null) return StatutObjet.EN_ATTENTE;
    return StatutObjet.values.firstWhere(
      (e) => e.name.toUpperCase() == statusName.toUpperCase(),
      orElse: () => StatutObjet.EN_ATTENTE,
    );
  }

  static TypeAnnonce _parseType(String? typeName) {
    if (typeName == null) return TypeAnnonce.PERTE;
    return TypeAnnonce.values.firstWhere(
      (e) => e.name.toUpperCase() == typeName.toUpperCase(),
      orElse: () => TypeAnnonce.PERTE,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'description': description,
        'ligneId': ligneId, 
        'contact': contact,
        'type': type.name,
        'statut': statut.name,
        'dateDeclaration': dateDeclaration.toIso8601String(),
        'busImmatriculation': busImmatriculation,
        'userId': userId,
        'imageUrl': imageUrl,
      };
}
