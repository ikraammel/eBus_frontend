class BusPosition {
  final String busKey;
  final int ligneId;
  final String numero;
  final String immatriculation; // NOUVEAU
  final double latitude;
  final double longitude;
  final bool actif;
  final int? updatedAt;
  final String statut;
  final double? vitesse;

  BusPosition({
    required this.busKey,
    required this.ligneId,
    required this.numero,
    this.immatriculation = '',
    required this.latitude,
    required this.longitude,
    required this.actif,
    this.updatedAt,
    this.statut = 'en_service',
    this.vitesse,
  });

  factory BusPosition.fromMap(String key, Map map) {
    return BusPosition(
      busKey: key,
      ligneId: (map['ligneId'] as num?)?.toInt() ?? 0,
      numero: map['numero']?.toString() ?? key,
      immatriculation: map['immatriculation']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      actif: map['actif'] as bool? ?? true,
      updatedAt: (map['updatedAt'] as num?)?.toInt(),
      statut: map['statut']?.toString() ?? 'en_service',
      vitesse: (map['vitesse'] as num?)?.toDouble(),
    );
  }

  bool get isRecent {
    if (updatedAt == null) return false;
    final diff = DateTime.now().millisecondsSinceEpoch - updatedAt!;
    return diff < 30000;
  }

  String get displayLabel =>
      immatriculation.isNotEmpty ? immatriculation : numero;
}