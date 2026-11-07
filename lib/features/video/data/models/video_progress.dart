import '../../../../core/utils/json_utils.dart';

/// Saved watch progress of one video for the signed-in student.
class VideoProgress {
  const VideoProgress({
    this.watchDurationSec = 0,
    this.lastPositionSec,
    this.totalDurationSec,
    this.isCompleted = false,
  });

  /// Progress of a video the student never opened.
  static const empty = VideoProgress();

  final int watchDurationSec;
  final int? lastPositionSec;
  final int? totalDurationSec;
  final bool isCompleted;

  factory VideoProgress.fromJson(Map<String, dynamic> json) => VideoProgress(
        watchDurationSec: json.asInt('watchDurationSec'),
        lastPositionSec: json.asIntOrNull('lastPositionSec'),
        totalDurationSec: json.asIntOrNull('totalDurationSec'),
        isCompleted: json.asBool('isCompleted'),
      );
}
