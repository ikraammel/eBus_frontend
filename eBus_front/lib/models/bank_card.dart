class BankCard {
  final int? id;
  final String last4;
  final String holder;
  final String expiry;
  final int colorIndex;
  final bool isMain;
  final int userId;

  BankCard({
    this.id,
    required this.last4,
    required this.holder,
    required this.expiry,
    required this.colorIndex,
    required this.isMain,
    required this.userId,
  });

  factory BankCard.fromJson(Map<String, dynamic> json) {
    return BankCard(
      id: json['id'],
      last4: json['last4'] ?? '',
      holder: json['holder'] ?? '',
      expiry: json['expiry'] ?? '',
      colorIndex: json['colorIndex'] ?? 0,
      isMain: json['main'] ?? json['isMain'] ?? false,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'last4': last4,
      'holder': holder,
      'expiry': expiry,
      'colorIndex': colorIndex,
      'main': isMain,
      'userId': userId,
    };
  }

  BankCard copyWith({
    int? id,
    String? last4,
    String? holder,
    String? expiry,
    int? colorIndex,
    bool? isMain,
    int? userId,
  }) {
    return BankCard(
      id: id ?? this.id,
      last4: last4 ?? this.last4,
      holder: holder ?? this.holder,
      expiry: expiry ?? this.expiry,
      colorIndex: colorIndex ?? this.colorIndex,
      isMain: isMain ?? this.isMain,
      userId: userId ?? this.userId,
    );
  }
}
