import '../../../../core/utils/json_utils.dart';

/// Quiz metadata and, on the detail endpoint, grouped questions.
class Quiz {
  Quiz({
    required this.id,
    required this.title,
    this.description = '',
    this.type = 0,
    this.isActive = true,
    List<QuizGroup> groups = const [],
  }) : groups = List.unmodifiable(groups);
  final int id;
  final String title;
  final String description;
  final int type;
  final bool isActive;
  final List<QuizGroup> groups;

  /// All questions in the quiz, across its groups.
  List<QuizQuestion> get questions =>
      List.unmodifiable(groups.expand((g) => g.questions));

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    id: json.asInt('quizID'),
    title: json.asString('title'),
    description: json.asString('description'),
    type: json.asInt('quizType'),
    isActive: json.asBool('isActive', fallback: true),
    groups: json.asList('groups').map(QuizGroup.fromJson).toList(),
  );
}

/// Passage or instruction shared by a group of questions.
class QuizGroup {
  QuizGroup({
    required this.id,
    this.instruction = '',
    List<QuizAsset> assets = const [],
    List<QuizQuestion> questions = const [],
  }) : assets = List.unmodifiable(assets),
       questions = List.unmodifiable(questions);
  final int id;
  final String instruction;
  final List<QuizAsset> assets;
  final List<QuizQuestion> questions;

  factory QuizGroup.fromJson(Map<String, dynamic> json) => QuizGroup(
    id: json.asInt('groupID'),
    instruction: json.asString('instruction'),
    assets: json.asList('assets').map(QuizAsset.fromJson).toList(),
    questions: json.asList('questions').map(QuizQuestion.fromJson).toList(),
  );
}

/// A question; correct options are never used to grade before submission.
class QuizQuestion {
  QuizQuestion({
    required this.id,
    required this.content,
    this.type = 1,
    List<QuizOption> options = const [],
    List<QuizAsset> assets = const [],
  }) : options = List.unmodifiable(options),
       assets = List.unmodifiable(assets);
  final int id;
  final String content;
  final int type;
  final List<QuizOption> options;
  final List<QuizAsset> assets;

  /// Whether the question is a multiple-choice question.
  bool get isChoice => type == 1 || options.isNotEmpty;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json.asInt('questionID'),
    content: json.asString('content'),
    type: json.asInt('questionType', fallback: 1),
    options: json.asList('options').map(QuizOption.fromJson).toList(),
    assets: json.asList('assets').map(QuizAsset.fromJson).toList(),
  );
}

/// Single selectable answer. Correctness is returned separately at submit.
class QuizOption {
  const QuizOption({required this.id, required this.content});
  final int id;
  final String content;
  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      QuizOption(id: json.asInt('optionID'), content: json.asString('content'));
}

/// Optional passage, image or audio attachment; MIME type determines playback.
class QuizAsset {
  const QuizAsset({
    required this.id,
    this.url = '',
    this.text = '',
    this.caption = '',
    this.mimeType = '',
    this.type = 0,
  });
  final int id;

  /// API AssetType: 1 = audio, 2 = image, 3 = text passage, 4 = file, 5 = video.
  final int type;
  final String url;
  final String text;
  final String caption;
  final String mimeType;

  /// Whether the asset is an image.
  bool get isImage =>
      type == 2 ||
      mimeType.toLowerCase().startsWith('image/') ||
      RegExp(
        r'\.(png|jpe?g|webp|gif)(\?|$)',
        caseSensitive: false,
      ).hasMatch(url);

  /// Whether the asset is an audio clip.
  bool get isAudio =>
      type == 1 ||
      mimeType.toLowerCase().startsWith('audio/') ||
      RegExp(
        r'\.(mp3|wav|m4a|ogg|aac)(\?|$)',
        caseSensitive: false,
      ).hasMatch(url);
  factory QuizAsset.fromJson(Map<String, dynamic> json) => QuizAsset(
    id: json.asInt('assetID'),
    url: json.asString('url'),
    text: json.asString('contentText'),
    caption: json.asString('caption'),
    mimeType: json.asString('mimeType'),
    type: json.asInt('assetType'),
  );
}

/// Attempt history has no quiz title or per-question answers in this API.
class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    this.status = '',
    this.score,
    this.startedAt,
    this.submittedAt,
  });
  final int id;
  final int quizId;
  final String status;
  final double? score;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    id: json.asInt('attemptId'),
    quizId: json.asInt('quizId'),
    status: json.asString('status'),
    score: json.pick('autoScore') == null ? null : json.asDouble('autoScore'),
    startedAt: json.asDate('startedAt'),
    submittedAt: json.asDate('submittedAt'),
  );
}

/// Authoritative server score and review returned by submit.
class QuizResult {
  QuizResult({
    required this.score,
    required this.total,
    required this.correct,
    this.wrong = 0,
    this.pending = 0,
    this.status = '',
    List<QuizQuestionResult> results = const [],
  }) : results = List.unmodifiable(results);
  final double score;
  final int total;
  final int correct;
  final int wrong;
  final int pending;
  final String status;
  final List<QuizQuestionResult> results;
  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    score: json.asDouble('autoScore'),
    total: json.asInt('totalQuestions'),
    correct: json.asInt('correctCount'),
    wrong: json.asInt('wrongCount'),
    pending: json.asInt('essayCount'),
    status: json.asString('status'),
    results: json.asList('results').map(QuizQuestionResult.fromJson).toList(),
  );
}

/// A submitted answer and any correction provided by the server.
class QuizQuestionResult {
  QuizQuestionResult({
    required this.questionId,
    required this.content,
    this.isCorrect,
    this.submittedOptionId,
    this.submittedText = '',
    this.correctText = '',
    List<QuizOption> correctOptions = const [],
  }) : correctOptions = List.unmodifiable(correctOptions);
  final int questionId;
  final String content;
  final bool? isCorrect;
  final int? submittedOptionId;
  final String submittedText;
  final String correctText;
  final List<QuizOption> correctOptions;
  factory QuizQuestionResult.fromJson(Map<String, dynamic> json) =>
      QuizQuestionResult(
        questionId: json.asInt('questionId'),
        content: json.asString('content'),
        isCorrect: json.pick('isCorrect') == null
            ? null
            : json.asBool('isCorrect'),
        submittedOptionId: json.asIntOrNull('submittedOptionId'),
        submittedText: json.asString('submittedAnswerText'),
        correctText: json.asString('correctAnswerText'),
        correctOptions: json
            .asList('correctOptions')
            .map(QuizOption.fromJson)
            .toList(),
      );
}
