import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/vocabulary/data/models/saved_word.dart';
import 'package:english_master/features/vocabulary/data/vocabulary_repository.dart';
import 'package:english_master/features/vocabulary/presentation/providers/vocabulary_provider.dart';

class _Repository extends Mock implements VocabularyRepository {}

void main() {
  test(
    'saved vocabulary parses DTO, searches, deletes and restores on undo',
    () async {
      final word = SavedWord.fromJson({
        'itemId': 10,
        'frontText': 'Journey',
        'backText': 'A trip',
        'example': 'Travel by train',
        'isMastered': true,
        'reviewCount': 2,
        'lastReviewedAt': null,
      });
      expect(word.isMastered, isTrue);
      expect(word.reviewCount, 2);
      final repository = _Repository();
      final state = VocabularyProvider(repository);
      addTearDown(state.dispose);
      when(() => repository.list()).thenAnswer((_) async => [word]);
      when(() => repository.delete(10)).thenAnswer((_) async {});
      when(() => repository.save(10)).thenAnswer((_) async {});
      await state.load();
      state.search('TRAIN');
      expect(state.words.single.itemId, 10);
      expect(await state.remove(word), isTrue);
      expect(state.words, isEmpty);
      expect(await state.save(word), isTrue);
      expect(state.words.single.front, 'Journey');
      state.search('missing');
      expect(state.words, isEmpty);
    },
  );

  test('failed delete preserves the saved word', () async {
    const word = SavedWord(itemId: 1, front: 'hello', back: 'greeting');
    final repository = _Repository();
    final state = VocabularyProvider(repository);
    addTearDown(state.dispose);
    when(() => repository.list()).thenAnswer((_) async => [word]);
    when(() => repository.delete(1)).thenThrow(ApiException('Offline'));
    await state.load();
    expect(await state.remove(word), isFalse);
    expect(state.words, [word]);
    expect(state.error, 'Offline');
  });
}
