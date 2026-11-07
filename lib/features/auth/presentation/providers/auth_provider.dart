import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/auth_repository.dart';
import '../../data/models/auth_session.dart';

/// Where the user is in the authentication flow.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Global authentication state (Provider / ChangeNotifier).
///
/// Screens call [login], [register] or [logout]; the root widget listens to
/// [status] to decide between the login flow and the main app.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  AuthSession? _session;
  bool _busy = false;
  String? _error;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  bool get isBusy => _busy;
  String? get error => _error;

  /// Called once at startup to restore a saved session.
  Future<void> bootstrap() async {
    _session = await _repository.restoreSession();
    _status = _session == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login(String emailOrUsername, String password) => _run(() async {
        final session = await _repository.login(emailOrUsername.trim(), password);
        if (!session.isStudent) {
          await _repository.logout();
          throw ApiException('This app is for students. Please use the web portal for ${session.role} accounts.');
        }
        _session = session;
        _status = AuthStatus.authenticated;
      });

  Future<bool> sendOtp(String email) => _run(() => _repository.sendOtp(email.trim()));

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required String otp,
  }) =>
      _run(() async {
        _session = await _repository.register(
          email: email.trim(),
          username: username.trim(),
          password: password,
          otp: otp.trim(),
        );
        _status = AuthStatus.authenticated;
      });

  Future<bool> forgotPassword(String email) => _run(() => _repository.forgotPassword(email.trim()));

  Future<void> logout() async {
    await _repository.logout();
    _session = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Called by the API client when the refresh token is no longer valid.
  void onSessionExpired() {
    _session = null;
    _status = AuthStatus.unauthenticated;
    _error = 'Your session has expired. Please log in again.';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Runs [action] while toggling [isBusy] and capturing the error message.
  /// Returns true on success.
  Future<bool> _run(Future<void> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Unexpected error: $e';
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
