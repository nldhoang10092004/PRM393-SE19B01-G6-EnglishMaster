import '../../../../core/utils/json_utils.dart';

/// Daily learning streak (`GET /api/student/streak` -> `StreakResponse`).
class StreakStatus {
  const StreakStatus({
    required this.currentStreak,
    required this.needsActivityToday,
    required this.message,
    this.lastActivityDate,
  });

  /// Streak shown before data is available.
  static const empty = StreakStatus(
    currentStreak: 0,
    needsActivityToday: true,
    message: '',
  );

  final int currentStreak;
  final DateTime? lastActivityDate;

  /// True when the student has not studied yet today.
  final bool needsActivityToday;

  /// Server-provided hint (may be Vietnamese; the UI shows its own English hint).
  final String message;

  factory StreakStatus.fromJson(Map<String, dynamic> json) => StreakStatus(
    currentStreak: json.asInt('currentStreak'),
    lastActivityDate: json.asDate('lastActivityDate'),
    needsActivityToday: json.asBool('needsActivityToday', fallback: true),
    message: json.asString('message'),
  );
}
