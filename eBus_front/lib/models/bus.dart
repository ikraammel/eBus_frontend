class Bus {
  final int? id;
  final String numero;
  final String etat;
  final String immatriculation;
  final int? capacite;
  final String? marque;
  final String? modele;
  final int ligneId;
  final String? ligneNumero;

  Bus({
    this.id,
    required this.numero,
    required this.etat,
    required this.immatriculation,
    this.capacite,
    this.marque,
    this.modele,
    required this.ligneId,
    this.ligneNumero,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (numero.trim().isNotEmpty) 'numero': numero.trim(),
      if (etat.trim().isNotEmpty) 'etat': etat.trim(),
      if (etat.trim().isNotEmpty) 'statut': etat.trim(),
      'immatriculation': immatriculation,
      if (capacite != null) 'capacite': capacite,
      if (marque != null && marque!.trim().isNotEmpty) 'marque': marque!.trim(),
      if (modele != null && modele!.trim().isNotEmpty) 'modele': modele!.trim(),
      'ligneId': ligneId,
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    final ligne = json['ligne'];
    return Bus(
      id: _asInt(json['id']),
      numero: json['numero']?.toString() ?? '',
      etat: (json['etat'] ?? json['statut'] ?? '').toString(),
      immatriculation: json['immatriculation']?.toString() ?? '',
      capacite: _asInt(json['capacite']),
      marque: json['marque']?.toString(),
      modele: json['modele']?.toString(),
      ligneId: _asInt(json['ligneId']) ?? _asInt(ligne is Map ? ligne['id'] : null) ?? 0,
      ligneNumero: json['ligneNumero']?.toString() ??
          (ligne is Map ? ligne['numero']?.toString() : null),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
