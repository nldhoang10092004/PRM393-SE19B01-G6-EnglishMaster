import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/course_repository.dart';
import '../../data/models/course_detail.dart';
import '../../data/models/course_feedback.dart';

/// State of one course detail screen: course tree, rating, reviews and the
/// lazily loaded "completed" flags of its videos.
class CourseDetailProvider extends ChangeNotifier {
  CourseDetailProvider(this._repository, this.courseId);

  final CourseRepository _repository;
  final int courseId;

  ViewStatus _status = ViewStatus.idle;
  CourseDetail? _course;
  CourseRating _rating = CourseRating.none;
  List<CourseFeedback> _feedbacks = const [];
  final Set<int> _completed = {};
  final Set<int> _checked = {};
  bool _submitting = false;
  String? _error;
  String? _actionError;

  /// Loading status of the course detail page.
  ViewStatus get status => _status;

  /// The loaded course details, or null before loading.
  CourseDetail? get course => _course;

  /// Rating summary of the course.
  CourseRating get rating => _rating;

  /// Feedback left on the course.
  List<CourseFeedback> get feedbacks => _feedbacks;

  /// Whether a feedback submission is in progress.
  bool get isSubmitting => _submitting;

  /// Last error message, or null.
  String? get error => _error;

  /// Error of the last user action (e.g. submitting a review), null when none.
  String? get actionError => _actionError;

  /// True when [videoId] is known to be completed.
  bool isCompleted(int videoId) => _completed.contains(videoId);

  /// Loads the course; rating and reviews are best-effort (failures are ignored).
  Future<void> load() async {
    _status = ViewStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _course = await _repository.fetchCourse(courseId);
      _status = ViewStatus.success;
      notifyListeners();
      await _loadReviews();
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
      notifyListeners();
    } catch (e) {
      _error = AppStrings.unexpectedError;
      _status = ViewStatus.error;
      notifyListeners();
    }
  }

  Future<void> _loadReviews() async {
    try {
      final results = await Future.wait([
        _repository.fetchRating(courseId),
        _repository.fetchFeedbacks(courseId),
      ]);
      _rating = results[0] as CourseRating;
      _feedbacks = results[1] as List<CourseFeedback>;
      notifyListeners();
    } catch (_) {
      // Reviews are secondary content; the course itself is still usable.
    }
  }

  /// Fetches completion flags for the videos of one chapter (called when the
  /// chapter is expanded, to avoid one request per video up front).
  /// Pass [force] to re-check videos already looked up (after watching one).
  Future<void> loadProgressFor(
    Iterable<LessonSummary> videos, {
    bool force = false,
  }) async {
    final pending = videos
        .where((v) => force || !_checked.contains(v.id))
        .toList();
    if (pending.isEmpty) return;
    _checked.addAll(pending.map((v) => v.id));
    await Future.wait(
      pending.map((v) async {
        try {
          if (await _repository.isVideoCompleted(v.id)) _completed.add(v.id);
        } catch (_) {
          _checked.remove(v.id); // retry next time the chapter is opened
        }
      }),
    );
    notifyListeners();
  }

  /// Sends a review, then refreshes rating and review list. Returns true on success.
  Future<bool> submitFeedback(int rating, String? comment) async {
    _submitting = true;
    _actionError = null;
    notifyListeners();
    try {
      await _repository.submitFeedback(
        courseId: courseId,
        rating: rating,
        comment: comment,
      );
      await _loadReviews();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      return false;
    } catch (e) {
      _actionError = AppStrings.unexpectedError;
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }
}
