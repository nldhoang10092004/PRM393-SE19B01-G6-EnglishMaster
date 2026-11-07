import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the login session (access token, account id, role).
///
/// Declared as an abstract class so tests can swap in [InMemoryTokenStorage]
/// instead of the platform keystore.
abstract class TokenStorage {
  /// Reads the stored access token, or null when none is saved.
  Future<String?> readAccessToken();

  /// Reads the stored account id, or null when none is saved.
  Future<int?> readAccountId();

  /// Reads the stored account role, or null when none is saved.
  Future<String?> readRole();

  /// Persists the session credentials and the optional role.
  Future<void> save({
    required String accessToken,
    required int accountId,
    String? role,
  });

  /// Removes all stored session credentials.
  Future<void> clear();
}

/// Production implementation backed by Android Keystore (encrypted storage).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kToken = 'access_token';
  static const _kAccountId = 'account_id';
  static const _kRole = 'role';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _kToken);

  @override
  Future<int?> readAccountId() async =>
      int.tryParse(await _storage.read(key: _kAccountId) ?? '');

  @override
  Future<String?> readRole() => _storage.read(key: _kRole);

  @override
  Future<void> save({
    required String accessToken,
    required int accountId,
    String? role,
  }) async {
    await _storage.write(key: _kToken, value: accessToken);
    await _storage.write(key: _kAccountId, value: accountId.toString());
    if (role != null) await _storage.write(key: _kRole, value: role);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kAccountId);
    await _storage.delete(key: _kRole);
  }
}

/// Simple in-memory storage used by unit and widget tests.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  int? _accountId;
  String? _role;

  @override
  Future<String?> readAccessToken() async => _token;

  @override
  Future<int?> readAccountId() async => _accountId;

  @override
  Future<String?> readRole() async => _role;

  @override
  Future<void> save({
    required String accessToken,
    required int accountId,
    String? role,
  }) async {
    _token = accessToken;
    _accountId = accountId;
    _role = role;
  }

  @override
  Future<void> clear() async {
    _token = null;
    _accountId = null;
    _role = null;
  }
}
