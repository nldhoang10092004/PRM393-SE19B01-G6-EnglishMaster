import 'package:english_master/features/ai_exam/ai_exam_strings.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements AiExamRepository {}

void main() {
  testWidgets('shows the passage, submits the choice and reviews the result', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository();
    when(() => repository.generate(AiExamSkill.reading)).thenAnswer(
      (_) async => const AiExamPrompt(
        id: 5,
        title: 'Honeybees',
        content: 'Honeybees pollinate many crops.',
        questions: [
          AiListeningQuestion(
            id: 1,
            type: 1,
            content: 'What do honeybees do?',
            options: ['Pollinate crops', 'Build roads'],
          ),
        ],
      ),
    );
    when(
      () => repository.submitListening(5, {
        1: 'Pollinate crops',
      }, skill: AiExamSkill.reading),
    ).thenAnswer(
      (_) async => AiListeningResult.fromJson({
        'score': 1,
        'total': 1,
        'script': 'Honeybees pollinate many crops.',
        'results': [
          {
            'questionId': 1,
            'content': 'What do honeybees do?',
            'userAnswer': 'Pollinate crops',
            'correctAnswer': 'Pollinate crops',
            'isCorrect': true,
          },
        ],
      }),
    );

    await tester.pumpWidget(
      Provider<AiExamRepository>.value(
        value: repository,
        child: const MaterialApp(home: AiReadingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Honeybees pollinate many crops.'), findsOneWidget);
    await tester.tap(find.text('Pollinate crops'));
    await tester.pump();
    await tester.tap(find.text(AiExamStrings.submit));
    await tester.pumpAndSettle();

    expect(find.text(AiExamStrings.readingResult), findsOneWidget);
    expect(find.text(AiExamStrings.listeningScore(1, 1)), findsOneWidget);
    verify(
      () => repository.submitListening(5, {
        1: 'Pollinate crops',
      }, skill: AiExamSkill.reading),
    ).called(1);
  });
}
