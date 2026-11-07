import 'dart:async';

import 'package:english_master/features/ai_exam/ai_exam_strings.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/presentation/screens/ai_writing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements AiExamRepository {}

void main() {
  testWidgets('type essay -> Vietnamese word count -> submit -> AI result', (
    tester,
  ) async {
    // Tall test surface so the whole lazily built form (counter + submit) is laid out.
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repository = _Repository();
    final pending = Completer<AiExamScore>();
    final essay = List.filled(150, 'education').join(' ');
    when(() => repository.generate(AiExamSkill.writing)).thenAnswer(
      (_) async => const AiExamPrompt(
        id: 9,
        title: 'Education',
        content: 'Discuss the value of education.',
      ),
    );
    when(() => repository.submitWriting(9, essay))
        .thenAnswer((_) => pending.future);
    await tester.pumpWidget(
      Provider<AiExamRepository>.value(
        value: repository,
        child: const MaterialApp(home: AiWritingScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Discuss the value of education.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'one two three');
    await tester.pump();
    expect(find.text('3 từ'), findsOneWidget);
    final submit = find.widgetWithText(FilledButton, AiExamStrings.submit);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    await tester.enterText(find.byType(TextFormField), essay);
    await tester.pump();
    expect(find.text('150 từ'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pump();
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(find.text(AiExamStrings.grading), findsOneWidget);
    pending.complete(
      const AiExamScore(
        overall: 7.5,
        taskResponse: 8,
        coherence: 7,
        lexical: 7.5,
        grammar: 7,
        feedback: {'overall': 'Bài viết có luận điểm rõ ràng.'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Điểm tổng: 7.5/9'), findsOneWidget);
    expect(find.text('Bài viết có luận điểm rõ ràng.'), findsOneWidget);
    expect(find.text('Nhận xét chung'), findsOneWidget);
    verify(() => repository.submitWriting(9, essay)).called(1);
    expect(tester.takeException(), isNull);
  });
}
