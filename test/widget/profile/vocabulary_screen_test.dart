import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/features/vocabulary/data/models/saved_word.dart';
import 'package:english_master/features/vocabulary/data/vocabulary_repository.dart';
import 'package:english_master/features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'package:english_master/features/vocabulary/presentation/screens/vocabulary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements VocabularyRepository {}

void main() {
  testWidgets('swipe deletes and Undo restores the saved vocabulary', (
    tester,
  ) async {
    const word = SavedWord(itemId: 10, front: 'journey', back: 'trip');
    final repository = _Repository();
    final state = VocabularyProvider(repository);
    addTearDown(state.dispose);
    when(() => repository.list()).thenAnswer((_) async => [word]);
    when(() => repository.delete(10)).thenAnswer((_) async {});
    when(() => repository.save(10)).thenAnswer((_) async {});
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: VocabularyScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Dismissible), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('journey'), findsNothing);
    expect(find.text(AppStrings.undo), findsOneWidget);
    await tester.tap(find.text(AppStrings.undo));
    await tester.pumpAndSettle();
    expect(find.text('journey'), findsOneWidget);
    verify(() => repository.save(10)).called(1);
    expect(tester.takeException(), isNull);
  });
}
