import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import '../ai_exam_strings.dart';
import 'models/ai_exam.dart';

/// The supported student skills and their backend route suffixes.
enum AiExamSkill { speaking, listening, writing, reading }

/// Maps all AI HTTP contracts; the shared client supplies authentication.
class AiExamRepository {
  AiExamRepository(this.api);
  final ApiClient api;

  Map<String, dynamic> _object(dynamic data) {
    if (data is! Map) throw ApiException(AiExamStrings.invalidResponse);
    return Map<String, dynamic>.from(data);
  }

  /// Generates an exercise without a request body; AI calls use 90 seconds.
  Future<AiExamPrompt> generate(AiExamSkill skill) async {
    final json = _object(
      await api.postSlow('/api/user/ai-${skill.name}/generate'),
    );
    final prompt = AiExamPrompt.fromJson(json);
    if (prompt.id <= 0 ||
        (skill != AiExamSkill.listening && prompt.content.trim().isEmpty) ||
        (skill == AiExamSkill.listening &&
            (prompt.audioUrl.isEmpty || prompt.questions.isEmpty)) ||
        (skill == AiExamSkill.reading && prompt.questions.isEmpty)) {
      throw ApiException(AiExamStrings.invalidResponse);
    }
    return prompt;
  }

  AiExamScore _score(dynamic data) {
    final json = _object(data);
    if (json.pick('score') == null) {
      throw ApiException(AiExamStrings.invalidResponse);
    }
    return AiExamScore.fromJson(json);
  }

  /// Sends essay text; the server saves every submission to the history.
  Future<AiExamScore> submitWriting(int promptId, String answerText) async =>
      _score(
        await api.postSlow(
          '/api/user/ai-writing/submit',
          body: {'promptId': promptId, 'answerText': answerText},
        ),
      );

  /// Sends an AAC/M4A recording with the exact form fields expected by ASP.NET.
  Future<AiExamScore> submitSpeaking(int promptId, String filePath) async =>
      _score(
        await api.postMultipart(
          '/api/user/ai-speaking/submit',
          fileField: 'file',
          filePath: filePath,
          fileName: 'answer.m4a',
          fields: {'promptId': promptId},
        ),
      );

  /// Multiple-choice answers contain option text, never a letter or option ID.
  /// Reading reuses the same contract and result shape as listening.
  Future<AiListeningResult> submitListening(
    int promptId,
    Map<int, String> answers, {
    AiExamSkill skill = AiExamSkill.listening,
  }) async {
    final json = _object(
      await api.postSlow(
        '/api/user/ai-${skill.name}/submit',
        body: {
          'promptId': promptId,
          'answers': answers.entries
              .map((e) => {'questionId': e.key, 'answer': e.value})
              .toList(),
        },
      ),
    );
    if (json.pick('score') == null || json.pick('total') == null) {
      throw ApiException(AiExamStrings.invalidResponse);
    }
    return AiListeningResult.fromJson(json);
  }

  /// Lists only server-saved submissions.
  Future<List<AiExamSubmission>> history() async {
    final data = await api.get('/api/user/review/list');
    if (data is! List) throw ApiException(AiExamStrings.invalidResponse);
    return asMapList(data)
        .map(AiExamSubmission.fromJson)
        .toList(growable: false);
  }

  /// Loads a submission owned by the current student.
  Future<AiExamReview> review(int submissionId) async {
    final json = _object(await api.get('/api/user/review/$submissionId'));
    if (json.pick('aiReview') is! Map || json.pick('prompt') is! Map) {
      throw ApiException(AiExamStrings.invalidResponse);
    }
    return AiExamReview.fromJson(json);
  }
}
