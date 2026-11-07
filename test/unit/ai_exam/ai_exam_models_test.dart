import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prompt parsing tolerates casing and numeric strings', () {
    final prompt = AiExamPrompt.fromJson({
      'PromptID': '42',
      'TITLE': 'A topic',
      'Content': 'Discuss this.',
    });
    expect(prompt.id, 42);
    expect(prompt.title, 'A topic');
    expect(prompt.content, 'Discuss this.');
    expect(prompt.questions, isEmpty);
  });

  test('listening parses choice content and nullable options', () {
    final prompt = AiExamPrompt.fromJson({
      'promptId': 3,
      'audioUrl': 'https://audio/one.mp3,https://audio/two.mp3',
      'questions': [
        {
          'questionId': 1,
          'type': 1,
          'content': 'Where?',
          'options': [
            {'content': 'At home'},
          ],
        },
        {'questionId': '2', 'type': '2', 'content': 'Name?', 'options': null},
      ],
    });
    expect(prompt.questions.first.options, ['At home']);
    expect(prompt.questions.last.options, isEmpty);
    expect(prompt.questions.last.type, 2);
    expect(
      () => prompt.questions.add(prompt.questions.first),
      throwsUnsupportedError,
    );
  });

  test('speaking score keeps all dimensions and structured feedback', () {
    final score = AiExamScore.fromJson({
      'score': '7.5',
      'Fluency': 7,
      'lexicalResource': '8',
      'grammar': 7.5,
      'pronunciation': 7,
      'transcript': 'My answer',
      'feedback': {
        'grammar': {
          'errors': [
            {'original': 'he go', 'correction': 'he goes'},
          ],
        },
      },
    });
    expect(score.overall, 7.5);
    expect(score.fluency, 7);
    expect(score.lexical, 8);
    expect(score.grammar, 7.5);
    expect(score.pronunciation, 7);
    expect(score.taskResponse, isNull);
    expect(score.transcript, 'My answer');
    expect(score.feedback, isA<Map>());
  });

  test('writing score and JSON-string history feedback are parsed', () {
    final score = AiExamScore.fromJson({
      'score': 6.5,
      'taskResponse': 7,
      'coherence': 6,
      'attemptId': 0,
      'feedback': '{"overall":"Keep practising"}',
    });
    expect(score.taskResponse, 7);
    expect(score.coherence, 6);
    expect(score.attemptId, 0);
    expect(score.feedback, {'overall': 'Keep practising'});
    expect(decodeFeedback('Plain feedback'), 'Plain feedback');
    expect(decodeFeedback(null), isNull);
  });

  test('listening results retain script and correct answers', () {
    final result = AiListeningResult.fromJson({
      'score': '1',
      'total': 2,
      'script': 'Speaker A: Hello.',
      'results': [
        {
          'questionId': 2,
          'content': 'Name?',
          'userAnswer': 'Jane',
          'correctAnswer': 'Jane',
          'isCorrect': true,
        },
      ],
    });
    expect(result.score, 1);
    expect(result.total, 2);
    expect(result.results.single.isCorrect, isTrue);
    expect(result.results.single.correctAnswer, 'Jane');
    expect(result.script, contains('Hello'));
  });

  test('history summary contains nested prompt and teacher status', () {
    final submission = AiExamSubmission.fromJson({
      'submissionId': '900',
      'aireviewId': 10,
      'prompt': {'title': 'Topic', 'content': 'Question'},
      'scoreOverall': '6.5',
      'createdAt': '2026-11-07T10:00:00Z',
      'isTeacherReviewed': true,
    });
    expect(submission.id, 900);
    expect(submission.reviewId, 10);
    expect(submission.title, 'Topic');
    expect(submission.score, 6.5);
    expect(submission.createdAt?.isUtc, isTrue);
    expect(submission.isTeacherReviewed, isTrue);
  });

  test('review supports null scores and misspelled teacher scoreLexial', () {
    final review = AiExamReview.fromJson({
      'prompt': {'title': 'Topic', 'content': 'Question'},
      'answer': {'transcript': 'Stored essay', 'answerText': null},
      'aiReview': {
        'scoreOverall': 7,
        'scoreLexical': 6.5,
        'scoreFluency': null,
        'feedback': '{"overall":"Good"}',
      },
      'teacherReview': {
        'scoreOverall': '8',
        'scoreLexial': 7.5,
        'scoreTask': 8,
        'feedback': 'Well done',
      },
    });
    expect(review.answer, 'Stored essay');
    expect(review.ai.fluency, isNull);
    expect(review.ai.lexical, 6.5);
    expect(review.teacher?.lexical, 7.5);
    expect(review.teacher?.taskResponse, 8);
    expect(review.teacher?.feedback, 'Well done');
  });

  test('review prefers answerText and handles no teacher review', () {
    final review = AiExamReview.fromJson({
      'answer': {'answerText': 'Written text', 'transcript': 'Audio text'},
      'teacherReview': null,
    });
    expect(review.answer, 'Written text');
    expect(review.teacher, isNull);
    expect(review.ai.feedback, isNull);
  });
}
