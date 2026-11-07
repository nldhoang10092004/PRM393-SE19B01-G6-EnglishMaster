import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/flashcard/data/flashcard_repository.dart';
import 'package:english_master/features/flashcard/data/models/flashcard.dart';
import 'package:english_master/features/flashcard/presentation/providers/flashcard_provider.dart';

class _Repository extends Mock implements FlashcardRepository {}

class _Api extends Mock implements ApiClient {}

void main() {
  test('models parse actual flashcard, progress and history DTOs', () {
    final set = FlashcardSet.fromJson({
      'setID': 4,
      'courseID': null,
      'title': 'Travel',
      'description': null,
      'items': [
        {
          'itemID': 10,
          'frontText': 'journey',
          'backText': 'a trip',
          'ipa': '/ˈdʒɜːni/',
          'example': 'Enjoy your journey.',
        },
      ],
    });
    expect(set.id, 4);
    expect(set.courseId, isNull);
    expect(set.items.single.ipa, '/ˈdʒɜːni/');
    final progress = FlashcardProgress.fromJson({
      'itemId': 10,
      'isMastered': true,
      'isSaved': true,
      'reviewCount': 3,
      'firstLearnedAt': '2026-11-01T00:00:00Z',
      'lastReviewedAt': null,
      'nextReviewAt': '2026-11-08T00:00:00Z',
    });
    expect(progress.isSaved, isTrue);
    expect(progress.reviewCount, 3);
    expect(progress.nextReviewAt!.day, 8);
    final history = FlashcardHistory.fromJson({
      'itemId': 10,
      'frontText': 'journey',
      'actionType': 2,
      'createdAt': '2026-11-07T00:00:00Z',
    });
    expect(history.actionType, 2);
    expect(history.createdAt!.isUtc, isTrue);
  });

  group('study progression', () {
    late _Repository repository;
    late FlashcardStudyProvider state;
    setUp(() {
      repository = _Repository();
      state = FlashcardStudyProvider(repository);
      when(() => repository.detail(4)).thenAnswer(
        (_) async => FlashcardSet(
          id: 4,
          title: 'Travel',
          items: const [
            Flashcard(id: 10, front: 'journey', back: 'trip'),
            Flashcard(id: 20, front: 'ticket', back: 'pass'),
          ],
        ),
      );
      when(() => repository.progress(4)).thenAnswer((_) async => []);
      when(() => repository.learn(any(), mastered: any(named: 'mastered')))
          .thenAnswer((_) async {});
    });
    tearDown(() => state.dispose());

    test('Again requeues, Got it advances, flip resets, completion counts unique cards', () async {
      await state.load(4);
      state.flip();
      expect(state.flipped, isTrue);
      await state.answer(mastered: false);
      expect(state.current!.id, 20);
      expect(state.flipped, isFalse);
      expect(state.remaining, 2);
      await state.answer(mastered: true);
      expect(state.current!.id, 10);
      expect(state.fraction, .5);
      await state.answer(mastered: true);
      expect(state.complete, isTrue);
      expect(state.masteredCount, 2);
      expect(state.reviews, 3);
      expect(state.progress.firstWhere((p) => p.itemId == 10).reviewCount, 2);
    });

    test('failed record does not advance and allows retry', () async {
      await state.load(4);
      when(() => repository.learn(10, mastered: true))
          .thenThrow(ApiException('Offline'));
      await state.answer(mastered: true);
      expect(state.current!.id, 10);
      expect(state.masteredCount, 0);
      expect(state.error, 'Offline');
      when(() => repository.learn(10, mastered: true)).thenAnswer((_) async {});
      await state.answer(mastered: true);
      expect(state.current!.id, 20);
    });

    test('rapid double tap persists only once', () async {
      final pending = Completer<void>();
      await state.load(4);
      when(() => repository.learn(10, mastered: true))
          .thenAnswer((_) => pending.future);
      final first = state.answer(mastered: true);
      await state.answer(mastered: true);
      expect(state.current!.id, 10);
      pending.complete();
      await first;
      verify(() => repository.learn(10, mastered: true)).called(1);
    });

    test('progress failure still permits studying loaded cards', () async {
      when(() => repository.progress(4))
          .thenThrow(ApiException('Progress unavailable'));
      await state.load(4);
      expect(state.current!.id, 10);
      expect(state.progressError, 'Progress unavailable');
    });
  });

  test(
    'repository maps empty progress/history 404 and numeric learning enum',
    () async {
      final api = _Api();
      final repository = FlashcardRepository(api);
      when(() => api.get('/api/flashcard/progress/set/4'))
          .thenThrow(ApiException('No progress', statusCode: 404));
      when(() => api.get('/api/flashcard/progress/history'))
          .thenThrow(ApiException('No history', statusCode: 404));
      expect(await repository.progress(4), isEmpty);
      expect(await repository.history(), isEmpty);
      when(
        () =>
            api.post('/api/flashcard/progress/learn', body: any(named: 'body')),
      ).thenAnswer((_) async => {'message': 'Learn recorded.'});
      await repository.learn(10, mastered: true);
      verify(
        () => api.post(
          '/api/flashcard/progress/learn',
          body: {'itemId': 10, 'actionType': 2, 'isCorrect': true},
        ),
      ).called(1);
    },
  );
}
