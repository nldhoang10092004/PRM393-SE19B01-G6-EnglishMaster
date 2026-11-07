import '../../../../core/utils/json_utils.dart';

/// One row of the course list (`GET /api/user/course` -> `courses[]`).
class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.name,
    required this.teacherName,
    this.description = '',
    this.createdAt,
  });

  final int id;
  final String name;
  final String teacherName;
  final String description;
  final DateTime? createdAt;

  /// Up to two upper-case initials of [name], used for the colored leading block.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words.first.substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  /// Builds a summary from the API CourseResponse (keys are case-insensitive).
  factory CourseSummary.fromJson(Map<String, dynamic> json) => CourseSummary(
        id: json.asInt('courseID'),
        name: json.asString('courseName'),
        teacherName: json.asString('teacherName'),
        description: json.asString('courseDescription', fallback: json.asString('description')),
        createdAt: json.asDate('createAt') ?? json.asDate('createdAt'),
      );
}
