import 'package:english_master/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Frame-timing benchmark that drives the real app (see docs/PERFORMANCE.md).
///
/// Run with `flutter drive --no-dds --profile
/// --driver=test_driver/perf_driver.dart
/// --target=integration_test/perf_scroll_test.dart -d DEVICE`.
/// Scenario: home list scroll -> Flashcards tab -> first set -> scroll the card
/// list -> study screen -> swipe 5 cards. Needs the deployed API (student1).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scroll + flashcard timeline', (tester) async {
    app.main();
    // Wait until either the login form or the home navigation is on screen.
    final login = find.byKey(const Key('login_identifier'));
    final nav = find.byType(NavigationBar);
    for (
      var i = 0;
      i < 60 && login.evaluate().isEmpty && nav.evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    // Log in through the form when the login screen is showing.
    if (login.evaluate().isNotEmpty) {
      await tester.pump(const Duration(seconds: 1));
      _setText(tester, login, 'student1');
      await tester.pump(const Duration(milliseconds: 300));
      _setText(tester, find.byKey(const Key('login_password')), 'Student@123');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('login_submit')));
      await tester.pump(const Duration(milliseconds: 300));
      for (var i = 0; i < 60 && nav.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }
    expect(nav, findsOneWidget);
    // Let the home data load (network) before measuring.
    await tester.pump(const Duration(seconds: 5));

    // The VM timeline buffer overflows on long traces, so every phase gets its
    // own short trace (summaries are merged by the driver).
    // 1. Home course list.
    await binding.traceAction(() async {
      final home = find.byType(CustomScrollView).first;
      for (var i = 0; i < 3; i++) {
        await tester.fling(home, const Offset(0, -600), 1500);
        await tester.pump(const Duration(seconds: 1));
        await tester.fling(home, const Offset(0, 600), 1500);
        await tester.pump(const Duration(seconds: 1));
      }
    }, reportKey: 'home_timeline');

    // 2. Flashcards tab -> first set -> scroll the card list (thumbnails).
    await tester.tap(find.byIcon(Icons.style_outlined).first);
    await tester.pump(const Duration(seconds: 4));
    await tester.tap(find.byType(Card).first);
    await tester.pump(const Duration(seconds: 4));
    final list = find.byType(ListView).first;
    await binding.traceAction(() async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(list, const Offset(0, -500), 1200);
        await tester.pump(const Duration(seconds: 1));
        await tester.fling(list, const Offset(0, 500), 1200);
        await tester.pump(const Duration(seconds: 1));
      }
    }, reportKey: 'cards_timeline');

    // 3. Study screen: swipe through 5 cards.
    for (
      var i = 0;
      i < 8 && find.byType(FilledButton).evaluate().isEmpty;
      i++
    ) {
      await tester.fling(list, const Offset(0, 1500), 3000);
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.tap(find.byType(FilledButton).first);
    await tester.pump(const Duration(seconds: 3));
    await binding.traceAction(() async {
      for (var i = 0; i < 5; i++) {
        await tester.fling(
          find.byType(TweenAnimationBuilder<double>).first,
          const Offset(-400, 0),
          1500,
        );
        await tester.pump(const Duration(milliseconds: 1500));
      }
    }, reportKey: 'study_timeline');
  });
}

/// Writes straight into the field controller (the IME channel is unreliable
/// under `flutter drive` on emulators).
void _setText(WidgetTester tester, Finder field, String text) {
  tester
          .widget<EditableText>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .controller
          .text =
      text;
}
