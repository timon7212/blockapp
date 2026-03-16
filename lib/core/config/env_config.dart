/// Environment configuration.
///
/// Override at build time:
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.doomscroll.app
/// ```
class EnvConfig {
  EnvConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://159.89.20.15:3000/api',
  );

  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
  static const int sendTimeoutMs = 10000;

  /// Max retries for failed requests (5xx)
  static const int maxRetries = 3;
}
