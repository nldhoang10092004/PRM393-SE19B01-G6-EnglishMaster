import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'models/auth_session.dart';

/// Authentication API calls (`/api/auth/*`) plus local session persistence.
class AuthRepository {
  AuthRepository({required ApiClient api, required TokenStorage storage})
    // ignore: prefer_initializing_formals
    : _api = api,
      // ignore: prefer_initializing_formals
      _storage = storage;

  final ApiClient _api;
  final TokenStorage _storage;

  /// Logs in with email or username and stores the returned token securely.
  Future<AuthSession> login(String emailOrUsername, String password) async {
    final json = await _api.post(
      '/api/auth/login',
      body: {'emailOrUsername': emailOrUsername, 'password': password},
    );
    final session = AuthSession.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    await _storage.save(
      accessToken: session.accessToken,
      accountId: session.accountId,
      role: session.role,
    );
    return session;
  }

  /// Asks the API to e-mail a one-time password required for registration.
  Future<void> sendOtp(String email) =>
      _api.post('/api/auth/send-otp', body: {'email': email});

  /// Creates a student account. The API validates the OTP sent by [sendOtp].
  Future<AuthSession> register({
    required String email,
    required String username,
    required String password,
    required String otp,
  }) async {
    final json = await _api.post(
      '/api/auth/register',
      body: {
        'email': email,
        'username': username,
        'password': password,
        'confirmPassword': password,
        'otp': otp,
      },
    );
    final session = AuthSession.fromJson(
      Map<String, dynamic>.from(json as Map),
    );
    await _storage.save(
      accessToken: session.accessToken,
      accountId: session.accountId,
      role: 'STUDENT',
    );
    return session;
  }

  /// Sends a password reset link to [email].
  Future<void> forgotPassword(String email) =>
      _api.post('/api/auth/forgot-password', body: {'email': email});

  /// Restores a previous session from secure storage (null = not logged in).
  Future<AuthSession?> restoreSession() async {
    final token = await _storage.readAccessToken();
    final accountId = await _storage.readAccountId();
    if (token == null || token.isEmpty || accountId == null) return null;
    return AuthSession(
      accountId: accountId,
      accessToken: token,
      role: await _storage.readRole(),
    );
  }

  /// Revokes the refresh token on the server (best effort) and clears local data.
  Future<void> logout() async {
    try {
      await _api.post('/api/auth/logout');
    } catch (_) {
      // Logging out must always succeed locally, even when offline.
    }
    await _storage.clear();
  }
}
