import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/lesson_video.dart';
import 'models/video_progress.dart';

/// Video API calls (`/api/public/video/*` and `/api/user/video/progress`).
class VideoRepository {
  VideoRepository(this._api);

  final ApiClient _api;

  /// Loads video metadata. Throws [ApiException] with the server message when
  /// the video is missing or needs a membership (HTTP 403/404).
  Future<LessonVideo> fetchVideo(int videoId) async {
    final json = await _api.get('/api/public/video/$videoId');
    if (json is! Map) throw ApiException('Unexpected video response.');
    return LessonVideo.fromJson(Map<String, dynamic>.from(json));
  }

  /// Saved progress of [videoId] (empty progress if never watched).
  Future<VideoProgress> fetchProgress(int videoId) async {
    final json = await _api.get('/api/user/video/progress/$videoId');
    if (json is! Map) return VideoProgress.empty;
    return VideoProgress.fromJson(Map<String, dynamic>.from(json));
  }

  /// Upserts progress (`VideoProgressRequest`).
  Future<void> saveProgress({
    required int videoId,
    required int watchDurationSec,
    required int lastPositionSec,
    required int totalDurationSec,
    required bool isCompleted,
  }) =>
      _api.post('/api/user/video/progress', body: {
        'videoId': videoId,
        'watchDurationSec': watchDurationSec,
        'lastPositionSec': lastPositionSec,
        'totalDurationSec': totalDurationSec,
        'isCompleted': isCompleted,
      });
}
