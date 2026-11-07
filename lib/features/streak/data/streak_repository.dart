import '../../../core/network/api_client.dart';
import 'models/streak_status.dart';

/// Streak API call (`/api/student/streak`).
class StreakRepository {
  StreakRepository(this._api);

  final ApiClient _api;

  /// Current streak of the signed-in student.
  Future<StreakStatus> fetchStreak() async {
    final json = await _api.get('/api/student/streak');
    if (json is! Map) return StreakStatus.empty;
    return StreakStatus.fromJson(Map<String, dynamic>.from(json));
  }
}
