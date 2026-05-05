class Activity {
  final String type;
  final String description;
  final DateTime date;
  final int userId;
  final String userNom;
  final String userPrenom;

  Activity({
    required this.type,
    required this.description,
    required this.date,
    required this.userId,
    required this.userNom,
    required this.userPrenom,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'userId': userId,
      'userNom': userNom,
      'userPrenom': userPrenom,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
        type: json['type'],
        description: json['description'],
        date: DateTime.parse(json['date']),
        userId: json['userId'],
        userNom: json['userNom'],
        userPrenom: json['userPrenom'],
    );
  }
}