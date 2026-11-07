import '../../../core/l10n/app_strings.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import 'models/course_detail.dart';
import 'models/course_feedback.dart';
import 'models/course_summary.dart';

/// Course API calls (`/api/user/course/*`) plus the per-video completion lookup.
class CourseRepository {
  CourseRepository(this._api);

  final ApiClient _api;

  /// Lists every course. The API wraps the list as `{ courses: [...] }`.
  Future<List<CourseSummary>> fetchCourses() async {
    final json = await _api.get('/api/user/course');
    final list = json is Map
        ? Map<String, dynamic>.from(json).asList('courses')
        : asMapList(json);
    return list.map(CourseSummary.fromJson).toList();
  }

  /// Loads one course with its chapters and videos.
  Future<CourseDetail> fetchCourse(int id) async {
    final json = await _api.get('/api/user/course/$id');
    if (json is! Map) throw ApiException(AppStrings.invalidCourse);
    return CourseDetail.fromJson(Map<String, dynamic>.from(json));
  }

  /// Average rating and number of reviews.
  Future<CourseRating> fetchRating(int courseId) async {
    final json = await _api.get('/api/user/course/$courseId/rating');
    if (json is! Map) return CourseRating.none;
    return CourseRating.fromJson(Map<String, dynamic>.from(json));
  }

  /// Visible reviews of a course.
  Future<List<CourseFeedback>> fetchFeedbacks(int courseId) async {
    final json = await _api.get('/api/user/course/$courseId/feedback');
    final list = json is Map
        ? Map<String, dynamic>.from(json).asList('feedbacks')
        : asMapList(json);
    return list.map(CourseFeedback.fromJson).toList();
  }

  /// Submits a review (students only). [rating] is 1..5.
  Future<void> submitFeedback({
    required int courseId,
    required int rating,
    String? comment,
  }) => _api.post(
    '/api/user/course/feedback',
    body: {
      'courseID': courseId,
      'rating': rating,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
    },
  );

  /// Whether the signed-in student completed [videoId].
  Future<bool> isVideoCompleted(int videoId) async {
    final json = await _api.get('/api/user/video/progress/$videoId');
    return json is Map && Map<String, dynamic>.from(json).asBool('isCompleted');
  }
}
