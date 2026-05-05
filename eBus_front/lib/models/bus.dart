class Bus {
  final int? id;
  final String numero;
  final String etat;
  final String immatriculation;
  final int ligneId;

  Bus({
    this.id,
    required this.numero,
    required this.etat,
    required this.immatriculation,
    required this.ligneId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'numero': numero,
      'etat': etat,
      'immatriculation': immatriculation,
      'ligneId': ligneId
    };
  }

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id']?.toInt(),
      numero: json['numero']?.toString() ?? '',
      etat: json['etat']?.toString() ?? '',
      immatriculation: json['immatriculation']?.toString() ?? '',
      ligneId: json['ligneId']?.toInt() ?? 0,
    );
  }
}
