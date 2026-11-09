import 'package:english_master/features/quiz/presentation/widgets/quiz_asset_view.dart';
import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/features/course/presentation/screens/course_list_screen.dart';
import 'package:english_master/features/home/presentation/screens/home_shell.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_listening_screen.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_reading_screen.dart';
import 'package:english_master/features/ai_exam/presentation/widgets/ai_generating_view.dart';

import 'dart:io';
import 'dart:ui' as ui;

import 'package:english_master/core/theme/app_theme.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_speaking_screen.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_writing_screen.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_exam_hub_screen.dart';
import 'package:english_master/features/ai_exam/presentation/widgets/ai_prompt_card.dart';
import 'package:english_master/features/ai_exam/presentation/widgets/ai_score_card.dart';
import 'package:english_master/features/auth/data/auth_repository.dart';
import 'package:english_master/features/auth/presentation/providers/auth_provider.dart';
import 'package:english_master/features/auth/presentation/screens/login_screen.dart';
import 'package:english_master/features/auth/presentation/screens/register_screen.dart';
import 'package:english_master/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:english_master/features/course/data/course_repository.dart';
import 'package:english_master/features/course/data/models/course_summary.dart';
import 'package:english_master/features/course/data/models/course_detail.dart';
import 'package:english_master/features/course/data/models/course_feedback.dart';
import 'package:english_master/features/course/presentation/providers/course_list_provider.dart';
import 'package:english_master/features/course/presentation/screens/course_detail_screen.dart';
import 'package:english_master/features/flashcard/data/flashcard_repository.dart';
import 'package:english_master/features/flashcard/data/models/flashcard.dart';
import 'package:english_master/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:english_master/features/flashcard/presentation/screens/flashcard_sets_screen.dart';
import 'package:english_master/features/flashcard/presentation/screens/flashcard_study_screen.dart';
import 'package:english_master/features/home/presentation/screens/home_screen.dart';
import 'package:english_master/features/membership/data/membership_repository.dart';
import 'package:english_master/features/membership/data/models/membership_models.dart';
import 'package:english_master/features/membership/presentation/providers/membership_provider.dart';
import 'package:english_master/features/membership/presentation/screens/membership_screen.dart';
import 'package:english_master/features/membership/presentation/screens/payment_qr_screen.dart';
import 'package:english_master/features/notifications/data/notification_service.dart';
import 'package:english_master/features/notifications/presentation/providers/reminder_provider.dart';
import 'package:english_master/features/notifications/presentation/screens/reminder_settings_screen.dart';
import 'package:english_master/features/profile/data/profile_repository.dart';
import 'package:english_master/features/profile/data/models/user_profile.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';
import 'package:english_master/features/profile/presentation/screens/profile_screen.dart';
import 'package:english_master/features/quiz/data/quiz_repository.dart';
import 'package:english_master/features/quiz/data/models/quiz.dart';
import 'package:english_master/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:english_master/features/quiz/presentation/screens/quiz_list_screen.dart';
import 'package:english_master/features/quiz/presentation/screens/quiz_detail_screen.dart';
import 'package:english_master/features/quiz/presentation/screens/quiz_taking_screen.dart';
import 'package:english_master/features/quiz/presentation/screens/quiz_result_screen.dart';
import 'package:english_master/features/streak/data/streak_repository.dart';
import 'package:english_master/features/streak/data/models/streak_status.dart';
import 'package:english_master/features/streak/presentation/providers/streak_provider.dart';
import 'package:english_master/features/vocabulary/data/vocabulary_repository.dart';
import 'package:english_master/features/vocabulary/data/models/saved_word.dart';
import 'package:english_master/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:english_master/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../unit/quiz/quiz_fixtures.dart';

class _Ai extends Mock implements AiExamRepository {}

class _Auth extends Mock implements AuthRepository {}

class _Courses extends Mock implements CourseRepository {}

class _Cards extends Mock implements FlashcardRepository {}

class _Membership extends Mock implements MembershipRepository {}

class _Profile extends Mock implements ProfileRepository {}

class _Quiz extends Mock implements QuizRepository {}

class _Streak extends Mock implements StreakRepository {}

class _Vocabulary extends Mock implements VocabularyRepository {}

class _Notifications extends Mock implements NotificationService {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi');
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final textFont = FontLoader('Be Vietnam Pro');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      textFont.addFont(
        rootBundle.load('assets/fonts/BeVietnamPro-$weight.ttf'),
      );
    }
    await textFont.load();
  });
  final pages = <String, Widget>{
    'login': const LoginScreen(),
    'register': const RegisterScreen(),
    'forgot': const ForgotPasswordScreen(),
    'home': const HomeScreen(),
    'home-shell': const HomeShell(),
    'course-list': const CourseListScreen(),
    'ai-listening': const AiListeningScreen(),
    'ai-reading': const AiReadingScreen(),
    'ai-loading': const Scaffold(
      body: AiGeneratingView(kind: AiGeneratingKind.listening),
    ),
    'course': const CourseDetailScreen(courseId: 1),
    'flashcard-sets': const FlashcardSetsScreen(),
    'flashcard-study': const FlashcardStudyScreen(setId: 1),
    'quiz-list': const QuizListScreen(),
    'quiz-detail': const QuizDetailScreen(quizId: 7),
    'quiz-taking': const QuizTakingScreen(),
    'quiz-listening': const QuizTakingScreen(),
    'quiz-result': const QuizResultScreen(),
    'ai-hub': const AiExamHubScreen(),
    'ai-speaking': const AiSpeakingScreen(),
    'ai-writing': const AiWritingScreen(),
    'payment-qr': const PaymentQrScreen(
      order: PaymentOrder(
        orderId: 1,
        orderCode: '123',
        paymentUrl: 'https://example.test/payment',
        qrCode: 'EnglishMaster-Test',
        amount: 1999000,
        description: 'Hội viên trọn năm',
      ),
    ),
    'ai-feedback': Scaffold(
      body: ListView(
        children: const [
          AiPromptCard(
            title: 'A memorable journey',
            content:
                'Describe a journey that changed the way you see the world.',
          ),
          AiScoreCard(
            score: AiExamScore(
              overall: 7.5,
              grammar: 7,
              fluency: 8,
              lexical: 7.5,
              feedback: 'Bạn đã trình bày ý tưởng rõ ràng. Hãy chú ý cách dùng thì và nối các ý.',
            ),
          ),
        ],
      ),
    ),
    'membership': const MembershipScreen(),
    'profile': const ProfileScreen(),
    'vocabulary': const VocabularyScreen(),
    'reminder': const ReminderSettingsScreen(),
    'empty': const Scaffold(
      body: MessageView(
        icon: Icons.auto_stories_outlined,
        message: 'Chưa có bài học. Hãy khám phá các khóa học mới nhé!',
      ),
    ),
  };

  for (final dark in [false, true]) {
    for (final page in pages.entries) {
      testWidgets('${page.key} fits 360dp in ${dark ? 'dark' : 'light'} mode', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final ai = _Ai();
        final courses = _Courses();
        final cards = _Cards();
        final profile = _Profile();
        final quiz = _Quiz();
        final membership = _Membership();
        final streak = _Streak();
        final vocabulary = _Vocabulary();
        when(() => courses.fetchCourses()).thenAnswer(
          (_) async => const [
            CourseSummary(
              id: 1,
              name: 'Tiếng Anh giao tiếp dành cho người mới bắt đầu',
              teacherName: 'Nguyễn Hoàng Phương Anh',
            ),
            CourseSummary(
              id: 2,
              name: 'Chinh phục ngữ pháp tiếng Anh',
              teacherName: 'Trần Minh',
            ),
          ],
        );
        when(() => courses.fetchCourse(1)).thenAnswer(
          (_) async => const CourseDetail(
            id: 1,
            name: 'Tiếng Anh giao tiếp dành cho người mới bắt đầu',
            description: 'Học từng bước nhỏ để tự tin giao tiếp mỗi ngày.',
            teacherName: 'Nguyễn Hoàng Phương Anh',
            chapters: [
              CourseChapter(
                id: 1,
                name: 'Khởi đầu hành trình học tiếng Anh',
                videos: [
                  LessonSummary(
                    id: 1,
                    name: 'Chào hỏi và giới thiệu bản thân',
                    isPreview: true,
                  ),
                ],
              ),
            ],
          ),
        );
        when(() => courses.fetchRating(1))
            .thenAnswer((_) async => CourseRating.none);
        when(() => courses.fetchFeedbacks(1)).thenAnswer((_) async => []);
        final set = FlashcardSet(
          id: 1,
          title: 'Từ vựng giao tiếp hằng ngày',
          items: const [
            Flashcard(
              id: 1,
              front: 'Perseverance',
              back: 'Sự kiên trì',
              example: 'Perseverance makes a difference.',
            ),
            Flashcard(id: 2, front: 'Curiosity', back: 'Sự tò mò'),
          ],
        );
        when(() => cards.sets()).thenAnswer((_) async => [set]);
        when(() => cards.detail(1)).thenAnswer((_) async => set);
        when(() => cards.progress(1)).thenAnswer((_) async => []);
        when(() => profile.detail()).thenAnswer(
          (_) async => const UserProfile(
            accountId: 4,
            fullName: 'Nguyễn Hoàng Phương Anh',
            email: 'phuonganh.nguyen@example.test',
          ),
        );
        when(() => profile.avatar()).thenAnswer((_) async => null);
        when(
          () => profile.membership(),
        ).thenAnswer((_) async => const MembershipStatus(hasMembership: true));
        when(() => profile.stats())
            .thenAnswer((_) async => (streak: 15, attempts: 120, words: 1250));
        when(() => quiz.list(courseId: any(named: 'courseId')))
            .thenAnswer((_) async => [fixtureQuiz()]);
        when(() => quiz.history()).thenAnswer(
          (_) async => [
            QuizAttempt(
              id: 1,
              quizId: 7,
              score: 90,
              submittedAt: DateTime(2026),
              status: 'COMPLETED',
            ),
          ],
        );
        when(() => quiz.detail(7)).thenAnswer((_) async => fixtureQuiz());
        when(() => membership.plans()).thenAnswer(
          (_) async => const [
            MembershipPlan(
              id: 1,
              code: 'Y',
              name: 'Hội viên trọn năm',
              price: 1999000,
              durationDays: 365,
            ),
            MembershipPlan(
              id: 2,
              code: 'M',
              name: 'Hội viên theo tháng',
              price: 299000,
              durationDays: 30,
            ),
          ],
        );
        when(() => membership.current())
            .thenAnswer((_) async => const MembershipInfo());
        when(() => streak.fetchStreak()).thenAnswer(
          (_) async => const StreakStatus(
            currentStreak: 15,
            needsActivityToday: true,
            message: '',
          ),
        );
        when(() => vocabulary.list()).thenAnswer(
          (_) async => const [
            SavedWord(
              itemId: 1,
              front: 'Perseverance',
              back: 'Sự kiên trì',
              example: 'Small steps every day.',
              isMastered: true,
            ),
          ],
        );
        for (final skill in [AiExamSkill.speaking, AiExamSkill.writing]) {
          when(() => ai.generate(skill)).thenAnswer(
            (_) async => const AiExamPrompt(
              id: 1,
              title: 'A memorable journey',
              content:
                  'Describe a journey that changed the way you see the world.',
            ),
          );
        }
        when(() => ai.generate(AiExamSkill.reading)).thenAnswer(
          (_) async => AiExamPrompt(
            id: 3,
            title: 'The Rise of Electric Cars',
            content: List.filled(
              40,
              'Electric cars are getting cheaper.',
            ).join(' '),
            questions: const [
              AiListeningQuestion(
                id: 1,
                type: 1,
                content: 'What is the main idea of the passage?',
                options: [
                  'Prices are falling',
                  'Cars are slower',
                  'Fuel is free',
                ],
              ),
            ],
          ),
        );
        when(() => ai.generate(AiExamSkill.listening)).thenAnswer(
          (_) async => const AiExamPrompt(
            id: 2,
            title: 'At the train station',
            content: '',
            questions: [
              AiListeningQuestion(
                id: 1,
                type: 1,
                content: 'Where does the woman want to go?',
                options: [
                  'To the airport',
                  'To the city centre',
                  'To the museum',
                ],
              ),
            ],
          ),
        );
        final attempt = QuizTakingProvider(quiz)
          ..quiz = fixtureQuiz()
          ..status = ViewStatus.success;
        if (page.key == 'quiz-listening') {
          attempt.quiz = Quiz(
            id: 7,
            title: 'Listening: Booking a Study Room',
            type: 1,
            groups: [
              QuizGroup(
                id: 3,
                instruction: List.filled(
                  12,
                  'Listen carefully and choose the best answer.',
                ).join(' '),
                assets: const [
                  QuizAsset(
                    id: 90,
                    type: 1,
                    url: 'https://example.test/listening.mp3',
                    caption: 'Booking a Study Room',
                  ),
                ],
                questions: fixtureQuiz().questions,
              ),
            ],
          );
          attempt.attemptId = 40;
        }
        if (page.key == 'quiz-result') {
          attempt.result = QuizResult(
            score: 75,
            total: 4,
            correct: 3,
            wrong: 1,
          );
        }
        final boundary = GlobalKey();
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AiExamRepository>.value(value: ai),
              Provider<MembershipRepository>.value(value: membership),
              Provider<CourseRepository>.value(value: courses),
              Provider<FlashcardRepository>.value(value: cards),
              Provider<QuizRepository>.value(value: quiz),
              ChangeNotifierProvider(create: (_) => AuthProvider(_Auth())),
              ChangeNotifierProvider(
                create: (_) => CourseListProvider(courses),
              ),
              ChangeNotifierProvider(create: (_) => FlashcardProvider(cards)),
              ChangeNotifierProvider(create: (_) => ProfileProvider(profile)),
              ChangeNotifierProvider(create: (_) => QuizProvider(quiz)),
              ChangeNotifierProvider(
                create: (_) => MembershipProvider(membership),
              ),
              ChangeNotifierProvider(create: (_) => StreakProvider(streak)),
              ChangeNotifierProvider(
                create: (_) => VocabularyProvider(vocabulary),
              ),
              ChangeNotifierProvider(
                create: (_) => ReminderProvider(_Notifications())..load(),
              ),
              ChangeNotifierProvider(create: (_) => attempt),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.dark() : AppTheme.light(),
              home: RepaintBoundary(key: boundary, child: page.value),
            ),
          ),
        );
        if (page.key == 'ai-loading') {
          await tester.pump(const Duration(seconds: 1));
        } else {
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('UPDATE_DESIGN_PREVIEWS')) {
          final repaint =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await repaint.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final directory = await Directory('build/design-review')
                .create(recursive: true);
            await File(
              '${directory.path}/${page.key}-${dark ? 'dark' : 'light'}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (page.key != 'ai-loading' &&
            find.byType(Scrollable).evaluate().isNotEmpty) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -450),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        if (page.key == 'home-shell') {
          expect(find.byType(NavigationDestination), findsNWidgets(5));
          await tester.tap(find.byType(NavigationDestination).at(1));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('course_search')), findsOneWidget);
          await tester.enterText(
            find.byKey(const Key('course_search')),
            'Trần Minh',
          );
          await tester.pumpAndSettle();
          expect(find.text('Chinh phục ngữ pháp tiếng Anh'), findsOneWidget);
          expect(
            find.text('Tiếng Anh giao tiếp dành cho người mới bắt đầu'),
            findsNothing,
          );
          for (final i in [2, 3, 4, 0, 1]) {
            await tester.tap(find.byType(NavigationDestination).at(i));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(
            tester
                    .widget<TextField>(find.byKey(const Key('course_search')))
                    .controller
                    ?.text ??
                'Trần Minh',
            'Trần Minh',
          );
          expect(find.text('Chinh phục ngữ pháp tiếng Anh'), findsOneWidget);
        }
        if (page.key == 'course-list') {
          await tester.enterText(
            find.byKey(const Key('course_search')),
            'Trần Minh',
          );
          await tester.pumpAndSettle();
          expect(find.text('Chinh phục ngữ pháp tiếng Anh'), findsOneWidget);
          expect(
            find.text('Tiếng Anh giao tiếp dành cho người mới bắt đầu'),
            findsNothing,
          );
          await tester.enterText(
            find.byKey(const Key('course_search')),
            'no matching course',
          );
          await tester.pumpAndSettle();
          expect(find.text(AppStrings.noMatchingCourses), findsOneWidget);
          await tester.enterText(find.byKey(const Key('course_search')), '');
          await tester.pumpAndSettle();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.tap(
            find.text('Tiếng Anh giao tiếp dành cho người mới bắt đầu'),
          );
          await tester.pumpAndSettle();
          expect(find.byType(CourseDetailScreen), findsOneWidget);
        }
        if (page.key == 'quiz-listening') {
          final pinned = find.byKey(const Key('pinned_listening_player'));
          final top = tester.getTopLeft(pinned);
          final element = tester.element(find.byType(QuizAssetView).first);
          final controller = attempt.audioFor(
            attempt.currentGroup!.assets.first,
          );
          await tester.drag(find.byType(ListView).first, const Offset(0, -200));
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(pinned), top);
          attempt.next();
          await tester.pumpAndSettle();
          expect(
            tester.element(find.byType(QuizAssetView).first),
            same(element),
          );
          expect(
            attempt.audioFor(attempt.currentGroup!.assets.first),
            same(controller),
          );
        }
        if (page.key == 'flashcard-study') {
          await tester.tap(find.text('Perseverance'));
          await tester.pumpAndSettle();
          expect(find.text('Sự kiên trì'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      });
    }
  }
}
