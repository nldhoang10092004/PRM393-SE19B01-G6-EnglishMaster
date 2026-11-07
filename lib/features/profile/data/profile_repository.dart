import '../../../core/network/api_client.dart';
import '../../../core/utils/json_utils.dart';
import 'models/user_profile.dart';

/// Profile and membership endpoints; email is intentionally read-only.
class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  /// Counts dashboard statistics without depending on other feature internals.
  Future<({int streak, int attempts, int words})> stats() async {
    final values = await Future.wait([
      _api.get('/api/student/streak'),
      _api.get('/api/user/quiz/attempts/history'),
      _api.get('/api/user/vocabulary/list'),
    ]);
    return (
      streak: Map<String, dynamic>.from(values[0] as Map)
          .asInt('currentStreak'),
      attempts: asMapList(values[1]).length,
      words: asMapList(values[2]).length,
    );
  }

  /// Retrieves personal details.
  Future<UserProfile> detail() async => UserProfile.fromJson(
    Map<String, dynamic>.from(
      await _api.get('/api/user/profile/detail') as Map,
    ),
  );

  /// Retrieves a nullable avatar URL in its response envelope.
  Future<String?> avatar() async => Map<String, dynamic>.from(
    await _api.get('/api/user/profile/avatar') as Map,
  ).asStringOrNull('avatarUrl');

  /// Retrieves active membership and dates.
  Future<MembershipStatus> membership() async => MembershipStatus.fromJson(
    Map<String, dynamic>.from(
      await _api.get('/api/user/membership/check') as Map,
    ),
  );

  /// Updates only fields supported by the service implementation.
  Future<void> update(UserProfile profile) async {
    await _api.put('/api/user/profile/detail', body: profile.toUpdateJson());
  }

  /// Sends the confirmation field with the exact DTO name.
  Future<void> changePassword(
    String current,
    String password,
    String confirm,
  ) async {
    await _api.put(
      '/api/user/profile/password',
      body: {
        'currentPassword': current,
        'newPassword': password,
        'confirmNewPassword': confirm,
      },
    );
  }
}
