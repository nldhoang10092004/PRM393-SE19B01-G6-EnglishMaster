import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/quiz.dart';
import '../../data/quiz_repository.dart';

/// Quiz catalog and independently refreshable attempt history.
class QuizProvider extends ChangeNotifier {
  QuizProvider(this.repository);
  final QuizRepository repository;
  ViewStatus status = ViewStatus.idle;
  ViewStatus historyStatus = ViewStatus.idle;
  String? error;
  String? historyError;
  List<Quiz> quizzes = [];
  List<QuizAttempt> attempts = [];
  bool _disposed = false;

  /// Loads one catalog; course embeds use their own provider instance.
  Future<void> load({int? courseId}) async {
    if (status == ViewStatus.loading) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      quizzes = await repository.list(courseId: courseId);
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.quizzesLoadError;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// History failure does not hide an otherwise usable catalog.
  Future<void> loadHistory() async {
    if (historyStatus == ViewStatus.loading) return;
    historyStatus = ViewStatus.loading;
    historyError = null;
    notifyListeners();
    try {
      attempts = await repository.history();
      historyStatus = ViewStatus.success;
    } on ApiException catch (e) {
      historyError = e.message;
      historyStatus = ViewStatus.error;
    } catch (_) {
      historyError = AppStrings.quizHistoryLoadError;
      historyStatus = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Returns the best submitted score, excluding unfinished attempts.
  double? bestScore(int quizId) {
    final scores = attempts
        .where(
          (a) => a.quizId == quizId && a.submittedAt != null && a.score != null,
        )
        .map((a) => a.score!);
    return scores.isEmpty ? null : scores.reduce((a, b) => a > b ? a : b);
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// A route-scoped attempt with answers retained through navigation and retry.
class QuizTakingProvider extends ChangeNotifier {
  QuizTakingProvider(this.repository);
  final QuizRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  Quiz? quiz;
  int? attemptId;
  int index = 0;
  bool busy = false;
  QuizResult? result;
  final Map<int, int> _choices = {};
  final Map<int, String> _text = {};
  bool _disposed = false;
  List<QuizQuestion> get questions => quiz?.questions ?? const [];
  QuizQuestion? get current => questions.isEmpty ? null : questions[index];
  QuizGroup? get currentGroup => quiz?.groups
      .where((g) => g.questions.any((q) => q.id == current?.id))
      .firstOrNull;
  int? selected(int questionId) => _choices[questionId];
  String textAnswer(int questionId) => _text[questionId] ?? '';
  int get answeredCount => questions
      .where(
        (q) => q.isChoice
            ? _choices.containsKey(q.id)
            : textAnswer(q.id).trim().isNotEmpty,
      )
      .length;
  bool get isLast => questions.isNotEmpty && index == questions.length - 1;

  /// Loads detail without creating a billable/recorded attempt yet.
  Future<void> load(int id) async {
    if (status == ViewStatus.loading || busy) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      quiz = await repository.detail(id);
      index = 0;
      attemptId = null;
      result = null;
      _choices.clear();
      _text.clear();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.quizLoadError;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Starts once; retrying a failed submit keeps this same attempt ID.
  /// True after a start attempt was refused because the membership is missing.
  bool needsMembership = false;

  Future<bool> start() async {
    if (busy || quiz == null || questions.isEmpty) return false;
    if (attemptId != null) return true;
    busy = true;
    error = null;
    notifyListeners();
    try {
      attemptId = await repository.start(quiz!.id);
      return true;
    } on ApiException catch (e) {
      error = e.message;
      needsMembership = e.isForbidden;
      return false;
    } catch (_) {
      error = AppStrings.quizStartError;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Replaces a single-choice answer only with an option of that question.
  void select(int optionId) {
    if (busy ||
        result != null ||
        attemptId == null ||
        current == null ||
        !current!.options.any((o) => o.id == optionId)) {
      return;
    }
    _choices[current!.id] = optionId;
    notifyListeners();
  }

  /// Retains text for fill-in and essay questions when present in mixed quizzes.
  void answerText(String value) {
    if (busy ||
        result != null ||
        attemptId == null ||
        current == null ||
        current!.isChoice) {
      return;
    }
    _text[current!.id] = value;
    notifyListeners();
  }

  /// Moves forward without discarding earlier answers.
  void next() {
    if (!busy &&
        result == null &&
        attemptId != null &&
        !isLast &&
        questions.isNotEmpty) {
      index++;
      notifyListeners();
    }
  }

  /// Returns to the previous question for review.
  void previous() {
    if (!busy && result == null && index > 0) {
      index--;
      notifyListeners();
    }
  }

  /// Sends every question so the backend counts unanswered entries as wrong.
  List<Map<String, dynamic>> get answerPayload => questions
      .map(
        (q) => <String, dynamic>{
          'questionID': q.id,
          'optionID': _choices[q.id],
          'answerText': _text[q.id],
        },
      )
      .toList();

  /// Accepts the server's score; no answer-key-based scoring happens locally.
  Future<bool> submit() async {
    if (busy || attemptId == null || result != null) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      result = await repository.submit(attemptId!, answerPayload);
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = AppStrings.quizSubmitError;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
