import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/lesson_video.dart';
import '../../data/models/video_progress.dart';
import '../../data/video_repository.dart';

/// State of the video lesson screen: metadata, resume position and
/// completion flag. Progress writes are fire-and-forget (never throw).
class VideoLessonProvider extends ChangeNotifier {
  VideoLessonProvider(this._repository, this.videoId);

  final VideoRepository _repository;
  final int videoId;

  ViewStatus _status = ViewStatus.idle;
  LessonVideo? _video;
  VideoProgress _progress = VideoProgress.empty;
  bool _completed = false;
  String? _error;
  bool _disposed = false;

  ViewStatus get status => _status;
  LessonVideo? get video => _video;
  String? get error => _error;

  /// True when the lesson needs an active membership (show the upgrade banner).
  bool get needsMembership => _needsMembership;
  bool _needsMembership = false;
  bool get isCompleted => _completed;

  /// Position (seconds) to resume from, 0 when starting over.
  int get resumePositionSec =>
      _completed ? 0 : (_progress.lastPositionSec ?? 0);

  /// Loads the video and the saved progress. Progress failures are ignored.
  Future<void> load() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final video = await _repository.fetchVideo(videoId);
      if (!video.canWatch) {
        throw ApiException(AppStrings.videoMembershipRequired);
      }
      if (video.url.trim().isEmpty) {
        throw ApiException(AppStrings.noVideoSource);
      }
      _video = video;
      try {
        _progress = await _repository.fetchProgress(videoId);
        _completed = _progress.isCompleted;
      } catch (_) {
        _progress = VideoProgress.empty;
      }
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _needsMembership = e.isForbidden;
      _status = ViewStatus.error;
    } catch (e) {
      _error = AppStrings.unexpectedError;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Marks the playback as failed (invalid or unreachable URL) so the screen shows an error view.
  void reportPlaybackError(String message) {
    _error = message;
    _status = ViewStatus.error;
    notifyListeners();
  }

  /// Saves the current position. Returns true when the server accepted it.
  /// [markCompleted] flips the completed flag permanently for this session.
  Future<bool> saveProgress({
    required int positionSec,
    required int totalSec,
    bool markCompleted = false,
  }) async {
    if (_video == null || totalSec <= 0) return false;
    final completed = _completed || markCompleted;
    final watched = positionSec > _progress.watchDurationSec
        ? positionSec
        : _progress.watchDurationSec;
    try {
      await _repository.saveProgress(
        videoId: videoId,
        watchDurationSec: watched,
        lastPositionSec: positionSec,
        totalDurationSec: totalSec,
        isCompleted: completed,
      );
      _progress = VideoProgress(
        watchDurationSec: watched,
        lastPositionSec: positionSec,
        totalDurationSec: totalSec,
        isCompleted: completed,
      );
      if (completed != _completed) {
        _completed = completed;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
