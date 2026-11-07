import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/course/data/course_repository.dart';
import 'package:english_master/features/course/data/models/course_detail.dart';
import 'package:english_master/features/course/data/models/course_feedback.dart';
import 'package:english_master/features/course/data/models/course_summary.dart';
import 'package:english_master/features/course/presentation/providers/course_detail_provider.dart';
import 'package:english_master/features/course/presentation/providers/course_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeRepo extends Mock implements CourseRepository {}

void main() {
  late _FakeRepo repo;
  setUp(() => repo = _FakeRepo());

  test('CourseListProvider: idle -> success', () async {
    when(() => repo.fetchCourses()).thenAnswer(
      (_) async => [const CourseSummary(id: 1, name: 'A', teacherName: 'T')],
    );
    final p = CourseListProvider(repo);
    expect(p.status, ViewStatus.idle);
    await p.load();
    expect(p.status, ViewStatus.success);
    expect(p.courses, hasLength(1));
  });

  test('CourseListProvider: error then keeps data on failed refresh', () async {
    when(() => repo.fetchCourses()).thenThrow(ApiException('boom'));
    final p = CourseListProvider(repo);
    await p.load();
    expect(p.status, ViewStatus.error);
    expect(p.error, 'boom');
    when(() => repo.fetchCourses()).thenAnswer(
      (_) async => [const CourseSummary(id: 1, name: 'A', teacherName: 'T')],
    );
    await p.load();
    when(() => repo.fetchCourses()).thenThrow(ApiException('again'));
    await p.load();
    expect(p.status, ViewStatus.success);
    expect(p.courses, hasLength(1));
  });

  test(
    'CourseDetailProvider: loads course, reviews and lazy progress',
    () async {
      const video = LessonSummary(id: 7, name: 'V', isPreview: false);
      when(() => repo.fetchCourse(1)).thenAnswer(
        (_) async => const CourseDetail(
          id: 1,
          name: 'A',
          description: '',
          teacherName: 'T',
          chapters: [
            CourseChapter(id: 1, name: 'C', videos: [video]),
          ],
        ),
      );
      when(() => repo.fetchRating(1))
          .thenAnswer((_) async => const CourseRating(average: 4, total: 1));
      when(() => repo.fetchFeedbacks(1)).thenAnswer((_) async => const []);
      when(() => repo.isVideoCompleted(7)).thenAnswer((_) async => true);
      final p = CourseDetailProvider(repo, 1);
      await p.load();
      expect(p.status, ViewStatus.success);
      expect(p.rating.total, 1);
      await p.loadProgressFor([video]);
      expect(p.isCompleted(7), true);
    },
  );

  test(
    'CourseDetailProvider: submitFeedback failure exposes actionError',
    () async {
      when(() => repo.submitFeedback(courseId: 1, rating: 5, comment: null))
          .thenThrow(ApiException('nope'));
      final p = CourseDetailProvider(repo, 1);
      expect(await p.submitFeedback(5, null), false);
      expect(p.actionError, 'nope');
    },
  );
}
