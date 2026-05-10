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
    // Parsing robuste des IDs (supporte int ou String)
    int? parsedId = json['id'] != null ? int.tryParse(json['id'].toString()) : null;
    
    int? parsedUserId;
    if (json['userId'] != null) {
      parsedUserId = int.tryParse(json['userId'].toString());
    } else if (json['user_id'] != null) {
      parsedUserId = int.tryParse(json['user_id'].toString());
    } else if (json['user'] != null && json['user'] is Map) {
      parsedUserId = int.tryParse(json['user']['id'].toString());
    }

    return ObjetPerdu(
      id: parsedId,
      nom: json['nom'] ?? 'Sans nom',
      busImmatriculation: json['busImmatriculation'] as String?,
      description: json['description'] ?? '',
      ligneId: json['ligneId'] != null ? int.tryParse(json['ligneId'].toString()) : null, 
      ligneNom: json['ligneNom'] as String?,
      contact: json['contact'],
      dateDeclaration: json['dateDeclaration'] != null
          ? DateTime.parse(json['dateDeclaration'])
          : DateTime.now(),
      statut: _parseStatut(json['statut']),
      type: _parseType(json['type']),
      userNom: json['userNom'] as String?,
      userId: parsedUserId,
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
