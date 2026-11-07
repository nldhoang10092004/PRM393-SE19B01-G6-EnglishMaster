import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:english_master/features/quiz/data/models/quiz.dart';
import 'package:english_master/features/quiz/data/quiz_repository.dart';
import 'package:english_master/features/quiz/presentation/providers/quiz_provider.dart';
import 'package:english_master/features/quiz/presentation/screens/quiz_taking_screen.dart';

import '../../unit/quiz/quiz_fixtures.dart';

class _Repository extends Mock implements QuizRepository {}

void main() {
  testWidgets(
    'select option, Next, review, confirm dialog, submit and result',
    (tester) async {
      final repository = _Repository();
      final state = QuizTakingProvider(repository);
      addTearDown(state.dispose);
      when(() => repository.detail(7)).thenAnswer((_) async => fixtureQuiz());
      when(() => repository.start(7)).thenAnswer((_) async => 40);
      when(() => repository.submit(40, any()))
          .thenAnswer((_) async => QuizResult.fromJson(resultJson()));
      await state.load(7);
      await state.start();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: state,
          child: const MaterialApp(home: QuizTakingScreen()),
        ),
      );
      expect(find.text('Question 1/2'), findsOneWidget);
      expect(find.text('Anna goes to school by bus.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('option-11')));
      await tester.pump();
      expect(state.selected(10), 11);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Question 2/2'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('option-22')));
      await tester.pump();
      await tester.tap(find.text('Previous'));
      await tester.pump();
      expect(state.selected(10), 11);
      await tester.tap(find.text('Next'));
      await tester.pump();
      await tester.tap(find.text('Submit quiz'));
      await tester.pumpAndSettle();
      expect(find.text('Submit quiz?'), findsOneWidget);
      verifyNever(() => repository.submit(any(), any()));
      await tester.tap(find.text('Keep reviewing'));
      await tester.pumpAndSettle();
      expect(state.result, isNull);
      await tester.tap(find.text('Submit quiz'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.text('Quiz result'), findsOneWidget);
      expect(find.text('50.0%'), findsOneWidget);
      expect(find.text('1/2 correct'), findsOneWidget);
      await tester.ensureVisible(find.text('Review answers'));
      await tester.tap(find.text('Review answers'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Correct answer: School'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
