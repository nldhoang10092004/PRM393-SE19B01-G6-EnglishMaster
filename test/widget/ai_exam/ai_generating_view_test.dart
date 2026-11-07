import 'package:english_master/features/ai_exam/ai_exam_strings.dart';
import 'package:english_master/features/ai_exam/presentation/widgets/ai_generating_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('steps advance with time, last step stays pending, tips rotate', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AiGeneratingView(kind: AiGeneratingKind.listening),
        ),
      ),
    );
    const steps = AiExamStrings.stepListening;
    expect(find.text(AiExamStrings.generatingListening), findsOneWidget);
    expect(find.byKey(ValueKey('step-active-${steps[0]}')), findsOneWidget);
    expect(find.byKey(ValueKey('step-pending-${steps[3]}')), findsOneWidget);
    expect(find.text(AiExamStrings.tips[0]), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.byKey(ValueKey('step-done-${steps[0]}')), findsOneWidget);
    expect(find.byKey(ValueKey('step-active-${steps[1]}')), findsOneWidget);
    expect(
      find.textContaining(AiExamStrings.elapsedSeconds(6)),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 6));
    expect(find.text(AiExamStrings.tips[2]), findsOneWidget);

    await tester.pump(const Duration(seconds: 60));
    expect(find.byKey(ValueKey('step-done-${steps[1]}')), findsOneWidget);
    expect(find.byKey(ValueKey('step-active-${steps[2]}')), findsOneWidget);
    expect(find.byKey(ValueKey('step-pending-${steps[3]}')), findsOneWidget);
  });

  testWidgets('cancel button pops the route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  body: AiGeneratingView(kind: AiGeneratingKind.grading),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(AiExamStrings.grading), findsOneWidget);
    await tester.tap(find.text(AiExamStrings.cancel));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(AiExamStrings.grading), findsNothing);
  });
}
