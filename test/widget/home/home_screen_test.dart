import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/features/course/data/course_repository.dart';
import 'package:english_master/features/course/data/models/course_summary.dart';
import 'package:english_master/features/course/presentation/providers/course_list_provider.dart';
import 'package:english_master/features/home/presentation/screens/home_screen.dart';
import 'package:english_master/features/streak/data/models/streak_status.dart';
import 'package:english_master/features/streak/data/streak_repository.dart';
import 'package:english_master/features/streak/presentation/providers/streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _CourseRepo extends Mock implements CourseRepository {}

class _StreakRepo extends Mock implements StreakRepository {}

void main() {
  testWidgets('HomeScreen shows the streak card and the course list', (
    tester,
  ) async {
    final courses = _CourseRepo();
    final streaks = _StreakRepo();
    when(() => courses.fetchCourses()).thenAnswer(
      (_) async => [
        const CourseSummary(id: 1, name: 'Basic English', teacherName: 'Ann'),
        const CourseSummary(
          id: 2,
          name: 'Advanced Grammar',
          teacherName: 'Bob',
        ),
      ],
    );
    when(() => streaks.fetchStreak()).thenAnswer(
      (_) async => const StreakStatus(
        currentStreak: 5,
        needsActivityToday: true,
        message: '',
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CourseListProvider(courses)),
          ChangeNotifierProvider(create: (_) => StreakProvider(streaks)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.streakDays(5)), findsOneWidget);
    expect(find.text(AppStrings.studyToday), findsOneWidget);
    expect(find.text('Basic English'), findsOneWidget);
    expect(find.text('Advanced Grammar'), findsOneWidget);
  });
}
