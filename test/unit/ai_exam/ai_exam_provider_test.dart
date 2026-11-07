import 'dart:async';

import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/ai_exam/ai_exam_strings.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_recorder.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/presentation/providers/ai_exam_provider.dart';
import 'package:english_master/features/ai_exam/presentation/providers/ai_review_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements AiExamRepository {}

class _Recorder extends Mock implements AiExamRecorder {}

const _prompt = AiExamPrompt(
  id: 5,
  title: 'Topic',
  content: 'Discuss education.',
);
const _score = AiExamScore(overall: 7, feedback: {'overall': 'Good work'});
final _essay = List.filled(150, 'word').join(' ');

void main() {
  late _Repository repository;
  setUp(() => repository = _Repository());

  test(
    'writing goes idle -> loading -> success and counts whitespace',
    () async {
      final pending = Completer<AiExamPrompt>();
      when(() => repository.generate(AiExamSkill.writing))
          .thenAnswer((_) => pending.future);
      final state = AiWritingProvider(repository);
      addTearDown(state.dispose);
      expect(state.status, ViewStatus.idle);
      final request = state.generate();
      expect(state.status, ViewStatus.loading);
      expect(state.busy, isTrue);
      pending.complete(_prompt);
      await request;
      expect(state.status, ViewStatus.success);
      expect(state.busy, isFalse);
      state.setAnswer('  one\n two\tthree  ');
      expect(state.wordCount, 3);
      expect(state.canSubmit, isFalse);
      expect(await state.submit(), isFalse);
      expect(state.error, AiExamStrings.minimumWords);
      verifyNever(
        () => repository.submitWriting(
          any(),
          any(),
          sendToTeacher: any(named: 'sendToTeacher'),
        ),
      );
    },
  );

  test('writing serializes submissions and exposes the result', () async {
    when(() => repository.generate(AiExamSkill.writing))
        .thenAnswer((_) async => _prompt);
    final pending = Completer<AiExamScore>();
    when(() => repository.submitWriting(5, _essay, sendToTeacher: true))
        .thenAnswer((_) => pending.future);
    final state = AiWritingProvider(repository);
    addTearDown(state.dispose);
    await state.generate();
    state.setAnswer(_essay);
    state.setSendToTeacher(true);
    expect(state.canSubmit, isTrue);
    final submit = state.submit();
    expect(state.busy, isTrue);
    state.setAnswer('changed');
    expect(state.answer, _essay);
    expect(await state.submit(), isFalse);
    pending.complete(_score);
    expect(await submit, isTrue);
    expect(state.result, _score);
    expect(state.canSubmit, isFalse);
    verify(() => repository.submitWriting(5, _essay, sendToTeacher: true))
        .called(1);
  });

  test('failed submit retains draft and can retry', () async {
    when(() => repository.generate(AiExamSkill.writing))
        .thenAnswer((_) async => _prompt);
    when(() => repository.submitWriting(5, _essay, sendToTeacher: false))
        .thenThrow(ApiException('Gemini API key missing'));
    final state = AiWritingProvider(repository);
    addTearDown(state.dispose);
    await state.generate();
    state.setAnswer(_essay);
    expect(await state.submit(), isFalse);
    expect(state.error, AiExamStrings.configurationError);
    expect(state.answer, _essay);
    expect(state.prompt, _prompt);
    expect(state.status, ViewStatus.success);
    expect(state.canSubmit, isTrue);
    when(() => repository.submitWriting(5, _essay, sendToTeacher: false))
        .thenAnswer((_) async => _score);
    expect(await state.submit(), isTrue);
    expect(state.error, isNull);
  });

  test(
    'failed regeneration keeps draft; successful regeneration resets it',
    () async {
      when(() => repository.generate(AiExamSkill.writing))
          .thenAnswer((_) async => _prompt);
      final state = AiWritingProvider(repository);
      addTearDown(state.dispose);
      await state.generate();
      state.setAnswer(_essay);
      when(() => repository.generate(AiExamSkill.writing))
          .thenThrow(ApiException('Membership required.'));
      await state.generate();
      expect(state.answer, _essay);
      expect(state.error, AiExamStrings.membershipRequired);
      when(() => repository.generate(AiExamSkill.writing))
          .thenAnswer((_) async => _prompt);
      await state.generate();
      expect(state.answer, isEmpty);
      expect(state.result, isNull);
    },
  );

  test('initial failures are localized, and retry succeeds', () async {
    when(() => repository.generate(AiExamSkill.writing))
        .thenThrow(ApiException('Membership required', statusCode: 400));
    final state = AiWritingProvider(repository);
    addTearDown(state.dispose);
    await state.generate();
    expect(state.status, ViewStatus.error);
    expect(state.error, AiExamStrings.membershipRequired);
    when(() => repository.generate(AiExamSkill.writing))
        .thenAnswer((_) async => _prompt);
    await state.generate();
    expect(state.status, ViewStatus.success);
    expect(state.error, isNull);
  });

  test('dispose during generation suppresses later notifications', () async {
    final pending = Completer<AiExamPrompt>();
    when(() => repository.generate(AiExamSkill.writing))
        .thenAnswer((_) => pending.future);
    final state = AiWritingProvider(repository);
    var notifications = 0;
    state.addListener(() => notifications++);
    final request = state.generate();
    state.dispose();
    pending.complete(_prompt);
    await request;
    expect(notifications, 1);
  });

  test('listening requires all answers and sends exact option text', () async {
    const prompt = AiExamPrompt(
      id: 6,
      title: 'Listening',
      content: '',
      audioUrl: 'https://audio',
      questions: [
        AiListeningQuestion(
          id: 1,
          type: 1,
          content: 'Where?',
          options: ['At home', 'At work'],
        ),
        AiListeningQuestion(id: 2, type: 2, content: 'Name?'),
      ],
    );
    when(() => repository.generate(AiExamSkill.listening))
        .thenAnswer((_) async => prompt);
    when(() => repository.submitListening(6, {1: 'At home', 2: 'Jane'}))
        .thenAnswer((_) async => const AiListeningResult(score: 2, total: 2));
    final state = AiListeningProvider(repository);
    addTearDown(state.dispose);
    await state.generate();
    state.setAnswer(1, 'A');
    expect(state.answerFor(1), isEmpty);
    state.setAnswer(1, 'At home');
    expect(await state.submit(), isFalse);
    expect(state.error, AiExamStrings.incompleteAnswers);
    state.setAnswer(2, 'Jane');
    expect(await state.submit(), isTrue);
    expect(state.result?.score, 2);
    state.setAnswer(2, 'changed');
    expect(state.answerFor(2), 'Jane');
  });

  test('listening upload failure retains answers', () async {
    when(() => repository.generate(AiExamSkill.listening)).thenAnswer(
      (_) async => const AiExamPrompt(
        id: 6,
        title: 'Topic',
        content: '',
        questions: [AiListeningQuestion(id: 1, type: 2, content: 'Name?')],
      ),
    );
    when(() => repository.submitListening(6, {1: 'Jane'}))
        .thenThrow(ApiException('Membership expired'));
    final state = AiListeningProvider(repository);
    addTearDown(state.dispose);
    await state.generate();
    state.setAnswer(1, 'Jane');
    expect(await state.submit(), isFalse);
    expect(state.answerFor(1), 'Jane');
    expect(state.error, AiExamStrings.membershipRequired);
  });

  test(
    'speaking records levels, stops, retains audio on failure and submits',
    () async {
      final recorder = _Recorder();
      final levels = StreamController<double>();
      when(recorder.start).thenAnswer((_) async {});
      when(() => recorder.levels).thenAnswer((_) => levels.stream);
      when(recorder.stop).thenAnswer((_) async => '/temp/answer.m4a');
      when(recorder.dispose).thenAnswer((_) async {});
      when(() => repository.generate(AiExamSkill.speaking))
          .thenAnswer((_) async => _prompt);
      when(
        () => repository.submitSpeaking(
          5,
          '/temp/answer.m4a',
          sendToTeacher: false,
        ),
      ).thenThrow(ApiException('Deepgram API key missing'));
      final state = AiSpeakingProvider(repository, recorder: recorder);
      await state.generate();
      expect(await state.submit(), isFalse);
      await state.toggleRecording();
      expect(state.recording, isTrue);
      expect(state.canGenerate, isFalse);
      levels.add(0.6);
      await Future<void>.delayed(Duration.zero);
      expect(state.level, 0.6);
      await state.toggleRecording();
      expect(state.recording, isFalse);
      expect(state.audioPath, '/temp/answer.m4a');
      expect(await state.submit(), isFalse);
      expect(state.error, AiExamStrings.configurationError);
      expect(state.audioPath, '/temp/answer.m4a');
      when(
        () => repository.submitSpeaking(
          5,
          '/temp/answer.m4a',
          sendToTeacher: false,
        ),
      ).thenAnswer((_) async => _score);
      expect(await state.submit(), isTrue);
      state.dispose();
      await Future<void>.delayed(Duration.zero);
      verify(recorder.dispose).called(1);
      await levels.close();
    },
  );

  test('speaking permission failure leaves recording stopped', () async {
    final recorder = _Recorder();
    when(recorder.start)
        .thenThrow(ApiException(AiExamStrings.microphoneDenied));
    when(recorder.dispose).thenAnswer((_) async {});
    when(() => repository.generate(AiExamSkill.speaking))
        .thenAnswer((_) async => _prompt);
    final state = AiSpeakingProvider(repository, recorder: recorder);
    await state.generate();
    await state.toggleRecording();
    expect(state.recording, isFalse);
    expect(state.audioPath, isNull);
    expect(state.error, AiExamStrings.microphoneDenied);
    state.dispose();
    await Future<void>.delayed(Duration.zero);
  });

  test('history and detail load independently and expose errors', () async {
    when(repository.history).thenAnswer((_) async => []);
    when(() => repository.review(5))
        .thenThrow(ApiException('Submission not found', statusCode: 404));
    final history = AiReviewProvider(repository);
    final detail = AiReviewProvider(repository);
    addTearDown(history.dispose);
    addTearDown(detail.dispose);
    await history.loadHistory();
    expect(history.status, ViewStatus.success);
    expect(history.submissions, isEmpty);
    await detail.loadDetail(5);
    expect(detail.status, ViewStatus.error);
    expect(detail.error, AiExamStrings.notFound);
    expect(history.status, ViewStatus.success);
    when(() => repository.review(5)).thenAnswer(
      (_) async => const AiExamReview(
        title: 'Topic',
        content: 'Question',
        answer: 'Answer',
        ai: _score,
      ),
    );
    await detail.loadDetail(5);
    expect(detail.status, ViewStatus.success);
    expect(detail.detail?.ai.overall, 7);
  });

  test('service failures are safe Vietnamese errors', () {
    for (final text in [
      'Gemini:ApiKey is not configured',
      'Murf error: invalid key',
      'Deepgram API key missing',
    ]) {
      expect(
        aiExamError(ApiException(text, statusCode: 500)),
        AiExamStrings.configurationError,
      );
    }
    expect(
      aiExamError(ApiException('Membership required', statusCode: 403)),
      AiExamStrings.membershipRequired,
    );
    expect(
      aiExamError(ApiException('Forbidden', statusCode: 403)),
      AiExamStrings.forbidden,
    );
    expect(
      aiExamError(ApiException('Unauthorized', statusCode: 401)),
      AiExamStrings.sessionExpired,
    );
    expect(
      aiExamError(ApiException('The server took too long')),
      AiExamStrings.timeoutError,
    );
    expect(
      aiExamError(ApiException('Cannot connect to the server')),
      AiExamStrings.networkError,
    );
    expect(
      aiExamError(StateError('private details')),
      AiExamStrings.genericError,
    );
  });
}
