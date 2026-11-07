import '../../../../core/utils/json_utils.dart';

/// A lesson video as listed inside a course (the raw URL is fetched later by the video feature).
class LessonSummary {
  const LessonSummary({
    required this.id,
    required this.name,
    required this.isPreview,
  });

  final int id;
  final String name;

  /// Preview videos can be watched without a membership.
  final bool isPreview;

  factory LessonSummary.fromJson(Map<String, dynamic> json) => LessonSummary(
    id: json.asInt('videoId'),
    name: json.asString('videoName'),
    isPreview: json.asBool('isPreview'),
  );
}

/// A chapter with its ordered videos.
class CourseChapter {
  const CourseChapter({
    required this.id,
    required this.name,
    required this.videos,
  });

  final int id;
  final String name;
  final List<LessonSummary> videos;

  factory CourseChapter.fromJson(Map<String, dynamic> json) => CourseChapter(
    id: json.asInt('chapterId'),
    name: json.asString('chapterName'),
    videos: json.asList('videos').map(LessonSummary.fromJson).toList(),
  );
}

/// Full course returned by `GET /api/user/course/{id}`.
class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.teacherName,
    required this.chapters,
    this.orphanVideos = const [],
  });

  final int id;
  final String name;
  final String description;
  final String teacherName;
  final List<CourseChapter> chapters;

  /// Videos that are not attached to any chapter.
  final List<LessonSummary> orphanVideos;

  /// Builds the detail from the API response (teacher is a nested object).
  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final teacher = json.pick('teacher');
    final teacherName = teacher is Map
        ? Map<String, dynamic>.from(teacher).asString('teacherName')
        : json.asString('teacherName');
    return CourseDetail(
      id: json.asInt('courseId'),
      name: json.asString('courseName'),
      description: json.asString('description'),
      teacherName: teacherName,
      chapters: json.asList('chapters').map(CourseChapter.fromJson).toList(),
      orphanVideos: json
          .asList('orphanVideos')
          .map(LessonSummary.fromJson)
          .toList(),
    );
  }
}
