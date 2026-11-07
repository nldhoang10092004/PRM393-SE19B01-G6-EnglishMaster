import '../../../../core/utils/json_utils.dart';

/// Average rating of a course (`GET /api/user/course/{id}/rating`).
class CourseRating {
  const CourseRating({required this.average, required this.total});

  /// Rating used before the real value is loaded.
  static const none = CourseRating(average: 0, total: 0);

  final double average;
  final int total;

  factory CourseRating.fromJson(Map<String, dynamic> json) => CourseRating(
        average: json.asDouble('averageRating'),
        total: json.asInt('totalFeedback'),
      );
}

/// A student review of a course.
class CourseFeedback {
  const CourseFeedback({
    required this.id,
    required this.username,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final int id;
  final String username;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory CourseFeedback.fromJson(Map<String, dynamic> json) => CourseFeedback(
        id: json.asInt('feedbackId'),
        username: json.asString('username', fallback: 'Student'),
        rating: json.asInt('rating'),
        comment: json.asStringOrNull('comment'),
        createdAt: json.asDate('createdAt'),
      );
}
