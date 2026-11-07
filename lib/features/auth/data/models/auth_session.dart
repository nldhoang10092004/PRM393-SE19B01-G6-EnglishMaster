import '../../../../core/utils/json_utils.dart';

/// Result of a successful login: who the user is and the JWT access token.
class AuthSession {
  const AuthSession({
    required this.accountId,
    required this.accessToken,
    this.role,
    this.expiresIn,
  });

  final int accountId;
  final String accessToken;

  /// `STUDENT`, `TEACHER` or `ADMIN` (the mobile app is for students).
  final String? role;

  /// Access token lifetime in seconds.
  final int? expiresIn;

  /// Whether the session belongs to a student account.
  bool get isStudent => (role ?? 'STUDENT').toUpperCase() == 'STUDENT';

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    accountId: json.asInt('accountID'),
    accessToken: json.asString('accessToken'),
    role: json.asStringOrNull('role'),
    expiresIn: json.asIntOrNull('expiresIn'),
  );
}
