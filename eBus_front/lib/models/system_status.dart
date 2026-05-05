class SystemStatus {
  final String status;
  final DateTime lastUpdate;

  SystemStatus({
    required this.status,
    required this.lastUpdate,
  });

  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      status: json['status'],
      lastUpdate: DateTime.parse(json['lastUpdate']),
    );
  }
}