class AppConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ebus-backend-ao2u.onrender.com',
  );
  static const String healthPath = String.fromEnvironment(
    'API_HEALTH_PATH',
    defaultValue: '/api/health',
  );
}
