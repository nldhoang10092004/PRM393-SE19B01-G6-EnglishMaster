import 'package:english_master/features/ai_exam/ai_exam_strings.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_writing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements AiExamRepository {}

Future<void> _openWriting(WidgetTester tester) async {
  final repository = _Repository();
  when(() => repository.generate(AiExamSkill.writing)).thenAnswer(
    (_) async =>
        const AiExamPrompt(id: 1, title: 'Email', content: 'Write an email.'),
  );
  await tester.pumpWidget(
    Provider<AiExamRepository>.value(
      value: repository,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AiWritingScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('back without a draft leaves immediately', (tester) async {
    await _openWriting(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
    expect(find.text(AiExamStrings.leaveWritingTitle), findsNothing);
  });

  testWidgets('back with a draft asks first; keep writing keeps the text', (
    tester,
  ) async {
    await _openWriting(tester);
    await tester.enterText(find.byType(TextFormField), 'My draft email');
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(AiExamStrings.leaveWritingTitle), findsOneWidget);
    await tester.tap(find.text(AiExamStrings.keepWriting));
    await tester.pumpAndSettle();
    expect(find.text('My draft email'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text(AiExamStrings.discardWriting));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
