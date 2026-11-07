import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import 'models/quiz.dart';

/// Maps student quiz routes and ASP.NET response shapes.
class QuizRepository {
  QuizRepository(this._api);
  final ApiClient _api;

  /// Lists system quizzes or quizzes attached to a course.
  Future<List<Quiz>> list({int? courseId}) async => asMapList(
    await _api.get(
      courseId == null
          ? '/api/user/quiz/system-quiz'
          : '/api/user/quiz/course/$courseId',
    ),
  ).map(Quiz.fromJson).toList();

  /// Retrieves groups, questions, and options before creating an attempt.
  Future<Quiz> detail(int id) async => Quiz.fromJson(
    Map<String, dynamic>.from(await _api.get('/api/user/quiz/$id') as Map),
  );

  /// The service returns a bare integer, not an attempt object.
  Future<int> start(int id) async {
    final value = await _api.post('/api/user/quiz/start/$id');
    final attemptId = value is num ? value.toInt() : int.tryParse('$value');
    if (attemptId == null || attemptId <= 0) {
      throw ApiException('The server did not return a valid attempt ID.');
    }
    return attemptId;
  }

  /// Submits one entry for every question, including unanswered questions.
  Future<QuizResult> submit(
    int attemptId,
    List<Map<String, dynamic>> answers,
  ) async => QuizResult.fromJson(
    Map<String, dynamic>.from(
      await _api.post(
        '/api/user/quiz/submit/$attemptId',
        body: {'answers': answers},
      ) as Map,
    ),
  );

  /// Retrieves attempts including unfinished and pending-review attempts.
  Future<List<QuizAttempt>> history() async =>
      asMapList(await _api.get('/api/user/quiz/attempts/history'))
          .map(QuizAttempt.fromJson)
          .toList();
}
