class AppConfig {
  // You can override this at build/run time with:
  // flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
