import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/quiz/data/models/quiz.dart';
import 'package:english_master/features/quiz/data/quiz_repository.dart';
import 'package:english_master/features/quiz/presentation/providers/quiz_provider.dart';

import 'quiz_fixtures.dart';

class _Repository extends Mock implements QuizRepository {}

class _Api extends Mock implements ApiClient {}

void main() {
  test('detail parses realistic grouped DTO and mixed-case acronym IDs', () {
    final quiz = fixtureQuiz();
    expect(quiz.id, 7);
    expect(quiz.questions.length, 2);
    expect(
      quiz.groups.single.assets.single.text,
      'Anna goes to school by bus.',
    );
    expect(quiz.questions.first.options.first.id, 11);
    expect(
      Quiz.fromJson({'QuizID': '9', 'Title': 'Mixed case', 'Groups': null}).id,
      9,
    );
    expect(() => quiz.groups.clear(), throwsUnsupportedError);
  });

  test('result and history preserve null and pending review semantics', () {
    final result = QuizResult.fromJson(resultJson());
    expect(result.score, 50);
    expect(result.correct, 1);
    expect(result.results.last.correctOptions.single.content, 'School');
    final pending = QuizQuestionResult.fromJson({
      'questionId': 30,
      'isCorrect': null,
      'correctOptions': null,
    });
    expect(pending.isCorrect, isNull);
    final attempt = QuizAttempt.fromJson({
      'attemptId': 5,
      'quizId': 7,
      'startedAt': '2026-11-07T01:00:00Z',
      'submittedAt': null,
      'autoScore': null,
      'status': 'IN_PROGRESS',
    });
    expect(attempt.score, isNull);
    expect(attempt.startedAt!.isUtc, isTrue);
    expect(
      QuizAsset.fromJson({
        'assetID': 1,
        'mimeType': 'audio/mpeg',
        'url': '/media/lesson',
      }).isAudio,
      isTrue,
    );
    expect(
      QuizAsset.fromJson({
        'assetID': 2,
        'url': 'https://example.test/a.png?token=x',
      }).isImage,
      isTrue,
    );
  });

  group('answer state', () {
    late _Repository repository;
    late QuizTakingProvider state;
    setUp(() {
      repository = _Repository();
      state = QuizTakingProvider(repository);
      when(() => repository.detail(7)).thenAnswer((_) async => fixtureQuiz());
      when(() => repository.start(7)).thenAnswer((_) async => 40);
      when(() => repository.submit(40, any()))
          .thenAnswer((_) async => QuizResult.fromJson(resultJson()));
    });
    tearDown(() => state.dispose());

    test('replaces single choice, rejects foreign option, retains navigation answers', () async {
      await state.load(7);
      await state.start();
      state.select(12);
      state.select(11);
      state.select(21);
      expect(state.selected(10), 11);
      expect(state.answeredCount, 1);
      state.next();
      state.select(22);
      state.next();
      expect(state.index, 1);
      state.previous();
      expect(state.selected(10), 11);
      expect(state.answeredCount, 2);
      expect(state.currentGroup!.id, 3);
    });

    test('submits unanswered entries and uses authoritative score', () async {
      await state.load(7);
      await state.start();
      state.select(11);
      await state.submit();
      final answers =
          verify(() => repository.submit(40, captureAny())).captured.single
              as List<Map<String, dynamic>>;
      expect(answers, [
        {'questionID': 10, 'optionID': 11, 'answerText': null},
        {'questionID': 20, 'optionID': null, 'answerText': null},
      ]);
      expect(state.result!.score, 50);
      expect(state.result!.correct, 1);
      state.select(12);
      expect(state.selected(10), 11);
      expect(await state.submit(), isFalse);
    });

    test(
      'failed submit retains answers and retries the same attempt',
      () async {
        when(() => repository.submit(40, any()))
            .thenThrow(ApiException('Offline'));
        await state.load(7);
        await state.start();
        state.select(12);
        expect(await state.submit(), isFalse);
        expect(state.error, 'Offline');
        expect(state.selected(10), 12);
        when(() => repository.submit(40, any()))
            .thenAnswer((_) async => QuizResult.fromJson(resultJson()));
        expect(await state.submit(), isTrue);
        verify(() => repository.start(7)).called(1);
      },
    );

    test(
      'double start and answer changes are guarded during a pending request',
      () async {
        final completer = Completer<int>();
        when(() => repository.start(7)).thenAnswer((_) => completer.future);
        await state.load(7);
        final first = state.start();
        expect(await state.start(), isFalse);
        state.select(11);
        expect(state.answeredCount, 0);
        completer.complete(40);
        await first;
        expect(await state.start(), isTrue);
        verify(() => repository.start(7)).called(1);
      },
    );

    test('mixed quizzes retain text answers', () async {
      when(() => repository.detail(7)).thenAnswer(
        (_) async => Quiz(
          id: 7,
          title: 'Mixed',
          groups: [
            QuizGroup(
              id: 1,
              questions: [
                QuizQuestion(id: 31, content: 'Complete the sentence', type: 2),
                QuizQuestion(id: 32, content: 'Write a paragraph', type: 3),
              ],
            ),
          ],
        ),
      );
      await state.load(7);
      await state.start();
      state.answerText('Hello');
      state.next();
      state.answerText('My paragraph');
      state.previous();
      expect(state.textAnswer(31), 'Hello');
      expect(state.answeredCount, 2);
      expect(state.answerPayload.last['answerText'], 'My paragraph');
    });
  });

  test(
    'catalog failure does not hide successful history and best submitted score',
    () async {
      final repository = _Repository();
      final state = QuizProvider(repository);
      addTearDown(state.dispose);
      when(() => repository.list())
          .thenThrow(ApiException('Membership expired'));
      when(() => repository.history()).thenAnswer(
        (_) async => [
          QuizAttempt(id: 1, quizId: 7, score: 70, submittedAt: DateTime(2026)),
          const QuizAttempt(id: 2, quizId: 7, score: 99),
        ],
      );
      await Future.wait([state.load(), state.loadHistory()]);
      expect(state.error, 'Membership expired');
      expect(state.attempts.length, 2);
      expect(state.bestScore(7), 70);
    },
  );

  test('repository uses bare attempt ID and exact submit envelope', () async {
    final api = _Api();
    final repository = QuizRepository(api);
    when(() => api.post('/api/user/quiz/start/7')).thenAnswer((_) async => 40);
    expect(await repository.start(7), 40);
    when(() => api.post('/api/user/quiz/submit/40', body: any(named: 'body')))
        .thenAnswer((_) async => resultJson());
    await repository.submit(40, [
      {'questionID': 10, 'optionID': 11},
    ]);
    verify(
      () => api.post(
        '/api/user/quiz/submit/40',
        body: {
          'answers': [
            {'questionID': 10, 'optionID': 11},
          ],
        },
      ),
    ).called(1);
  });
}
