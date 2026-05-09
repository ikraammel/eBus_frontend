import '../enums/reclamation_status.dart';

class Reclamation {
  final int? id;
  final String? titre;
  final String? description;
  final DateTime? date;
  final ReclamationStatus? status;
  final int? userId;
  final int? ligneId;

  Reclamation({
    this.id,
    this.titre,
    this.description,
    this.status,
    this.date,
    this.userId,
    this.ligneId
  });

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    return Reclamation(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      status: json['status'] != null
          ? ReclamationStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'])
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      userId: json['userId'],
      ligneId: json['ligneId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'status': status != null ? status.toString().split('.').last : null,
      'date': date?.toIso8601String(), // yyyy-MM-dd
      'userId': userId,
      'ligneId': ligneId,
    };
  }
}