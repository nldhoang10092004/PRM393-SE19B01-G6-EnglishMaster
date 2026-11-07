/// Build-time configuration.
///
/// The API base URL can be switched without code changes:
/// `flutter run --dart-define=API_BASE_URL=https://em-api.example.com`
/// The default targets an API running on the host machine as seen from the
/// Android emulator (10.0.2.2 is the emulator's alias for the host).
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5213',
  );

  /// Network timeout applied to every request.
  static const Duration requestTimeout = Duration(seconds: 20);
}
