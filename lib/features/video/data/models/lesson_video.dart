import '../../../../core/utils/json_utils.dart';

/// A playable lesson video (`GET /api/public/video/{videoId}`).
class LessonVideo {
  const LessonVideo({
    required this.id,
    required this.name,
    required this.url,
    required this.isPreview,
    required this.canWatch,
  });

  final int id;
  final String name;
  final String url;
  final bool isPreview;

  /// False when the student needs an active membership for this video.
  final bool canWatch;

  factory LessonVideo.fromJson(Map<String, dynamic> json) => LessonVideo(
    id: json.asInt('videoId'),
    name: json.asString('videoName'),
    url: json.asString('videoURL'),
    isPreview: json.asBool('isPreview'),
    canWatch: json.asBool('canWatch', fallback: true),
  );
}
