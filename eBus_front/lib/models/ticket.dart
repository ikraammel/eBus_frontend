class Ticket {
  final int id;
  final String typeTicket;
  final double prix;

  Ticket({
    required this.id,
    required this.typeTicket,
    required this.prix,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      typeTicket: json['typeTicket'],
      prix: json['prix'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeTicket': typeTicket,
      'prix': prix,
    };
  }
}