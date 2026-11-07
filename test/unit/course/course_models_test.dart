import 'package:english_master/features/course/data/models/course_detail.dart';
import 'package:english_master/features/course/data/models/course_feedback.dart';
import 'package:english_master/features/course/data/models/course_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CourseSummary.fromJson reads case-insensitive keys and builds initials', () {
    final c = CourseSummary.fromJson({
      'courseID': 3,
      'courseName': 'Basic English',
      'courseDescription': 'Intro',
      'teacherName': 'Ann',
      'createAt': '2026-01-02T00:00:00',
    });
    expect(c.id, 3);
    expect(c.initials, 'BE');
    expect(c.teacherName, 'Ann');
    expect(c.createdAt?.year, 2026);
  });

  test('CourseDetail.fromJson parses nested teacher, chapters and orphan videos', () {
    final d = CourseDetail.fromJson({
      'courseId': 1,
      'courseName': 'A',
      'description': 'd',
      'teacher': {'teacherId': 2, 'teacherName': 'Bob'},
      'chapters': [
        {
          'chapterId': 10,
          'chapterName': 'Ch1',
          'videos': [
            {'videoId': 5, 'videoName': 'V', 'videoUrl': 'x', 'isPreview': true}
          ]
        }
      ],
      'orphanVideos': [
        {'videoId': 6, 'videoName': 'O', 'isPreview': false}
      ],
    });
    expect(d.teacherName, 'Bob');
    expect(d.chapters.single.videos.single.isPreview, true);
    expect(d.orphanVideos.single.id, 6);
  });

  test('CourseRating and CourseFeedback parse', () {
    final r = CourseRating.fromJson({'CourseID': 1, 'AverageRating': 4.5, 'TotalFeedback': 2});
    expect(r.average, 4.5);
    expect(r.total, 2);
    final f = CourseFeedback.fromJson({'feedbackId': 1, 'username': 'u', 'rating': 4, 'comment': null});
    expect(f.rating, 4);
    expect(f.comment, isNull);
  });
}
