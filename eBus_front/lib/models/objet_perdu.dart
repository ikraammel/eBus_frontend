class ObjetPerdu {
  final int? id;
  final String name;
  final String? description;
  final String location;
  final String? dateDeclaration;
  final String status;
  final int userId;

  ObjetPerdu({
    this.id,
    required this.name,
    this.description,
    required this.location,
    this.dateDeclaration,
    required this.status,
    required this.userId,
  });

  factory ObjetPerdu.fromJson(Map<String, dynamic> json) {
    return ObjetPerdu(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      location: json['location'] ?? '',
      dateDeclaration: json['dateDeclaration'],
      status: json['status'] ?? 'LOST',
      userId: json['user']?['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'dateDeclaration': dateDeclaration,
      'status': status,
      'userId': userId, // ← directement l'ID, pas user: {id: ...}
    };
  }
}
