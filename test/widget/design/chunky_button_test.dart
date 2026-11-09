import 'package:english_master/core/theme/app_theme.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final secondary in [false, true]) {
    testWidgets(
      'chunky ${secondary ? 'secondary' : 'primary'} sinks 4dp, releases and cancels',
      (tester) async {
        var calls = 0;
        final button = secondary
            ? ChunkyOutlinedButton(
                onPressed: () => calls++,
                child: const Text('Action'),
              )
            : ChunkyButton(
                onPressed: () => calls++,
                child: const Text('Action'),
              );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(body: Center(child: button)),
          ),
        );
        final face = find.byType(FilledButton);
        final before = tester.getTopLeft(face);
        final gesture = await tester.startGesture(tester.getCenter(face));
        await tester.pump();
        expect(tester.getTopLeft(face).dy, before.dy + 4);
        final decoration =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(ChunkyButton),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(decoration.boxShadow, isEmpty);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(tester.getTopLeft(face), before);
        final canceled = await tester.startGesture(tester.getCenter(face));
        await tester.pump();
        await canceled.cancel();
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(tester.getTopLeft(face), before);
      },
    );
  }
  testWidgets('disabled action remains still and does not activate', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: ChunkyButton(onPressed: null, child: Text('Disabled')),
          ),
        ),
      ),
    );
    final face = find.byType(FilledButton);
    final before = tester.getTopLeft(face);
    final gesture = await tester.startGesture(tester.getCenter(face));
    await tester.pump();
    expect(tester.getTopLeft(face), before);
    await gesture.up();
    expect(tester.widget<FilledButton>(face).onPressed, isNull);
  });
  test('light and dark semantic text pairs exceed 4.5 contrast', () {
    double contrast(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
    }

    for (final p in [AppPalette.light, AppPalette.dark]) {
      for (final pair in [
        (p.ink, p.surface),
        (p.ink, p.background),
        (p.inkMuted, p.surface),
        (p.inkMuted, p.background),
        (p.onPrimary, p.primary),
        (p.onPrimarySoft, p.primarySoft),
        (p.onReward, p.reward),
        (p.speaking.ink, p.speaking.background),
        (p.listening.ink, p.listening.background),
        (p.writing.ink, p.writing.background),
        (p.reading.ink, p.reading.background),
        (p.error, p.surface),
      ]) {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      }
    }
  });
}
