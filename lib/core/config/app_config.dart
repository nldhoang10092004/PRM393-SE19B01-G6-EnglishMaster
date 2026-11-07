/// Build-time configuration.
///
/// The API base URL can be switched without code changes:
/// `flutter run --dart-define=API_BASE_URL=https://em-api.example.com`
/// The default is the deployed HTTPS API. For a local API seen from the
/// Android emulator use `--dart-define=API_BASE_URL=http://10.0.2.2:5213`.
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://em-api.ondevora.shop',
  );

  /// Network timeout applied to every request.
  static const Duration requestTimeout = Duration(seconds: 20);
}
