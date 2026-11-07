import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Client extends Mock implements ApiClient {}

void main() {
  late _Client api;
  late AiExamRepository repository;
  setUp(() {
    api = _Client();
    repository = AiExamRepository(api);
  });

  test('all generators use a bodyless slow POST', () async {
    for (final skill in AiExamSkill.values) {
      when(() => api.postSlow('/api/user/ai-${skill.name}/generate'))
          .thenAnswer(
            (_) async => {
              'promptId': 10,
              'title': 'Topic',
              'content': 'Question',
              if (skill == AiExamSkill.listening) ...{
                'audioUrl': 'https://example/audio.mp3',
                'questions': [
                  {'questionId': 1, 'type': 2, 'content': 'Name?'},
                ],
              },
            },
          );
      expect((await repository.generate(skill)).id, 10);
      verify(() => api.postSlow('/api/user/ai-${skill.name}/generate'))
          .called(1);
    }
  });

  test('speaking uses file and promptId multipart fields', () async {
    when(
      () => api.postMultipart(
        '/api/user/ai-speaking/submit',
        fileField: 'file',
        filePath: '/tmp/answer.m4a',
        fileName: 'answer.m4a',
        fields: {'promptId': 10},
      ),
    ).thenAnswer((_) async => {'score': 7.5});
    final result = await repository.submitSpeaking(10, '/tmp/answer.m4a');
    expect(result.overall, 7.5);
    verify(
      () => api.postMultipart(
        '/api/user/ai-speaking/submit',
        fileField: 'file',
        filePath: '/tmp/answer.m4a',
        fileName: 'answer.m4a',
        fields: {'promptId': 10},
      ),
    ).called(1);
  });

  test('writing sends camelCase JSON using the slow endpoint', () async {
    when(
      () => api.postSlow(
        '/api/user/ai-writing/submit',
        body: {'promptId': 10, 'answerText': 'Essay'},
      ),
    ).thenAnswer(
      (_) async => {'score': 8, 'taskResponse': 8.5, 'attemptId': 0},
    );
    final result = await repository.submitWriting(10, 'Essay');
    expect(result.taskResponse, 8.5);
    expect(result.attemptId, 0);
  });

  test('listening sends question IDs and exact answer text', () async {
    when(
      () => api.postSlow(
        '/api/user/ai-listening/submit',
        body: {
          'promptId': 10,
          'answers': [
            {'questionId': 1, 'answer': 'At home'},
          ],
        },
      ),
    ).thenAnswer((_) async => {'score': 1, 'total': 1, 'results': []});
    final result = await repository.submitListening(10, {1: 'At home'});
    expect(result.score, 1);
    expect(result.total, 1);
  });

  test('history and detail use authenticated shared GET routes', () async {
    when(() => api.get('/api/user/review/list')).thenAnswer(
      (_) async => [
        {
          'submissionId': 99,
          'aireviewId': 10,
          'prompt': {'title': 'Topic'},
          'scoreOverall': 7,
        },
      ],
    );
    when(() => api.get('/api/user/review/99')).thenAnswer(
      (_) async => {
        'prompt': {'title': 'Topic', 'content': 'Question'},
        'answer': {'transcript': 'Essay'},
        'aiReview': {'scoreOverall': 7},
      },
    );
    expect((await repository.history()).single.id, 99);
    expect((await repository.review(99)).answer, 'Essay');
  });

  test(
    'malformed success payloads never become empty exercises or fake scores',
    () async {
      when(() => api.postSlow('/api/user/ai-writing/generate'))
          .thenAnswer((_) async => {});
      await expectLater(
        repository.generate(AiExamSkill.writing),
        throwsA(isA<ApiException>()),
      );
      when(
        () => api.postSlow(
          '/api/user/ai-writing/submit',
          body: {'promptId': 10, 'answerText': 'Essay'},
        ),
      ).thenAnswer((_) async => {'error': 'missing score'});
      await expectLater(
        repository.submitWriting(10, 'Essay'),
        throwsA(isA<ApiException>()),
      );
      when(() => api.get('/api/user/review/list'))
          .thenAnswer((_) async => null);
      await expectLater(repository.history(), throwsA(isA<ApiException>()));
    },
  );
}
