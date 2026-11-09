import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../ai_exam_strings.dart';
import '../../data/ai_exam_audio_controller.dart';
import '../../data/ai_exam_recorder.dart';
import '../../data/ai_exam_repository.dart';
import '../../data/models/ai_exam.dart';

/// Translates server failures without exposing English errors or service secrets.
String aiExamError(Object failure) {
  if (failure is! ApiException) return AiExamStrings.genericError;
  final message = failure.message.toLowerCase();
  if (message.contains('membership')) return AiExamStrings.membershipRequired;
  if (message.contains('gemini') ||
      message.contains('murf') ||
      message.contains('deepgram') ||
      message.contains('api key') ||
      message.contains('apikey') ||
      message.contains('not configured')) {
    return AiExamStrings.configurationError;
  }
  if (failure.isUnauthorized) return AiExamStrings.sessionExpired;
  if (failure.statusCode == 403) return AiExamStrings.forbidden;
  if (failure.statusCode == 404 || message.contains('submission not found')) {
    return AiExamStrings.notFound;
  }
  if (message.contains('150')) return AiExamStrings.minimumWords;
  if (message.contains('transcrib')) return AiExamStrings.transcriptionError;
  if (message.contains('too long') ||
      message.contains('timeout') ||
      message.contains('thời gian')) {
    return AiExamStrings.timeoutError;
  }
  if (message.contains('connect') || message.contains('kết nối')) {
    return AiExamStrings.networkError;
  }
  // Locally generated messages are safe, localized and contain no server payload.
  if ([
    AiExamStrings.microphoneDenied,
    AiExamStrings.recordingError,
    AiExamStrings.invalidResponse,
  ].contains(failure.message)) {
    return failure.message;
  }
  return AiExamStrings.genericError;
}

/// Common route-scoped state; failed submissions retain the exercise and answers.
abstract class AiExamProvider<T> extends ChangeNotifier {
  AiExamProvider(
    this.repository,
    this.skill, {
    AiAudioPlayerFactory? audioPlayerFactory,
  }) : audio = AiExamAudioController(playerFactory: audioPlayerFactory);
  final AiExamRepository repository;

  /// One player for the whole exercise; disposed only with this provider.
  final AiExamAudioController audio;
  final AiExamSkill skill;
  ViewStatus status = ViewStatus.idle;
  AiExamPrompt? prompt;
  T? result;
  String? error;
  bool busy = false;
  bool generating = false, grading = false;
  bool disposed = false;

  /// Whether a new AI prompt can be requested right now.
  bool get canGenerate => !busy;

  /// Serializes actions and turns failures into Vietnamese UI state.
  Future<bool> perform(
    Future<void> Function() action, {
    bool isGenerating = false,
    bool isGrading = false,
  }) async {
    if (busy || disposed) return false;
    busy = true;
    generating = isGenerating;
    grading = isGrading;
    error = null;
    if (prompt == null) status = ViewStatus.loading;
    notifyListeners();
    try {
      await action();
      status = ViewStatus.success;
      return true;
    } catch (failure) {
      error = aiExamError(failure);
      status = prompt == null ? ViewStatus.error : ViewStatus.success;
      return false;
    } finally {
      busy = false;
      generating = grading = false;
      notifyListeners();
    }
  }

  /// Replaces the previous work only after generation succeeds.
  Future<void> generate() async {
    if (!canGenerate || disposed) return;
    await perform(() async {
      final generated = await repository.generate(skill);
      prompt = generated;
      result = null;
      clearAnswer();
    }, isGenerating: true);
  }

  /// Resets skill-specific input after successful generation.
  void clearAnswer();

  @override
  void notifyListeners() {
    if (!disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    audio.dispose();
    super.dispose();
  }
}

/// Essay input, backend-compatible word counting, generation and grading state.
class AiWritingProvider extends AiExamProvider<AiExamScore> {
  AiWritingProvider(AiExamRepository repository)
    : super(repository, AiExamSkill.writing);
  String answer = '';

  /// Number of words in the current written answer.
  int get wordCount =>
      answer.trim().isEmpty ? 0 : answer.trim().split(RegExp(r'\s+')).length;

  /// Whether the written answer is long enough to submit.
  bool get canSubmit =>
      !busy && prompt != null && result == null && wordCount >= 150;

  /// Stores the written answer while the exam can still be edited.
  void setAnswer(String value) {
    if (busy || result != null) return;
    answer = value;
    error = null;
    notifyListeners();
  }

  @override
  void clearAnswer() => answer = '';

  /// Submits once, preserving the draft if grading fails.
  Future<bool> submit() async {
    if (busy || prompt == null || result != null) return false;
    if (wordCount < 150) {
      error = AiExamStrings.minimumWords;
      notifyListeners();
      return false;
    }
    return perform(() async {
      result = await repository.submitWriting(prompt!.id, answer.trim());
    }, isGrading: true);
  }
}

/// Listening answers retain exact option content and are graded on the server.
class AiListeningProvider extends AiExamProvider<AiListeningResult> {
  AiListeningProvider(
    AiExamRepository repository, {
    super.audioPlayerFactory,
    AiExamSkill skill = AiExamSkill.listening,
  }) : super(repository, skill);
  final Map<int, String> _answers = {};

  /// Returns the saved answer for a question, or an empty string.
  String answerFor(int id) => _answers[id] ?? '';

  /// Whether every listening question has an answer and can be submitted.
  bool get canSubmit =>
      !busy &&
      result == null &&
      prompt != null &&
      prompt!.questions.every((q) => answerFor(q.id).trim().isNotEmpty);

  /// Stores the answer for one listening question.
  void setAnswer(int questionId, String value) {
    if (busy || result != null || prompt == null) return;
    final question = prompt!.questions
        .where((q) => q.id == questionId)
        .firstOrNull;
    if (question == null ||
        (question.type == 1 && !question.options.contains(value))) {
      return;
    }
    _answers[questionId] = value;
    error = null;
    notifyListeners();
  }

  @override
  void clearAnswer() => _answers.clear();

  /// Checks that all listening answers are filled in, then submits them for grading.
  Future<bool> submit() async {
    if (busy || prompt == null || result != null) return false;
    if (!canSubmit) {
      error = AiExamStrings.incompleteAnswers;
      notifyListeners();
      return false;
    }
    return perform(() async {
      result = await repository.submitListening(
        prompt!.id,
        Map.of(_answers),
        skill: skill,
      );
    }, isGrading: true);
  }
}

/// Reading: an AI passage with multiple-choice questions, graded like listening.
class AiReadingProvider extends AiListeningProvider {
  AiReadingProvider(super.repository) : super(skill: AiExamSkill.reading);
}

/// Captures a timed answer, retains playback on failed uploads, and grades audio.
class AiSpeakingProvider extends AiExamProvider<AiExamScore> {
  AiSpeakingProvider(
    AiExamRepository repository, {
    AiExamRecorder? recorder,
    super.audioPlayerFactory,
  }) : _recorder = recorder ?? AiExamRecorder(),
       super(repository, AiExamSkill.speaking);
  final AiExamRecorder _recorder;
  Timer? _timer;
  StreamSubscription<double>? _levels;
  Future<void>? _recordingAction;
  bool recording = false;
  String? audioPath;
  Duration elapsed = Duration.zero;
  double level = 0;
  @override
  bool get canGenerate => !busy && !recording;

  /// Whether a speaking recording exists and can be submitted.
  bool get canSubmit =>
      !busy &&
      !recording &&
      audioPath != null &&
      result == null &&
      prompt != null;

  @override
  void clearAnswer() {
    unawaited(audio.clear());
    audioPath = null;
    elapsed = Duration.zero;
    level = 0;
  }

  /// Called by both the record button and the five-minute capture limit.
  Future<void> toggleRecording() async {
    if (busy || prompt == null || result != null || disposed) return;
    final action = _toggleRecording();
    _recordingAction = action;
    await action;
  }

  Future<void> _toggleRecording() async {
    await perform(() async {
      if (recording) {
        _timer?.cancel();
        await _levels?.cancel();
        try {
          final path = await _recorder.stop();
          if (path == null || path.isEmpty) {
            throw ApiException(AiExamStrings.recordingError);
          }
          audioPath = path;
        } finally {
          recording = false;
          level = 0;
        }
      } else {
        try {
          await _recorder.start();
          if (disposed) return;
          unawaited(audio.clear());
          audioPath = null;
          elapsed = Duration.zero;
          recording = true;
          _levels = _recorder.levels.listen(
            (value) {
              level = value;
              notifyListeners();
            },
            onError: (Object _) {
              level = 0;
              notifyListeners();
            },
          );
          _timer = Timer.periodic(const Duration(seconds: 1), (_) {
            elapsed += const Duration(seconds: 1);
            notifyListeners();
            if (elapsed.inSeconds >= 300) unawaited(toggleRecording());
          });
        } on ApiException {
          rethrow;
        } catch (_) {
          throw ApiException(AiExamStrings.recordingError);
        }
      }
    });
  }

  /// Submits the recorded speaking audio for AI grading.
  Future<bool> submit() async {
    if (!canSubmit) return false;
    return perform(() async {
      result = await repository.submitSpeaking(prompt!.id, audioPath!);
    }, isGrading: true);
  }

  /// Stops microphone work even if the route closes during permission or setup.
  Future<void> _closeRecorder() async {
    await _recordingAction;
    await _recorder.dispose();
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_levels?.cancel());
    super.dispose();
    unawaited(_closeRecorder());
  }
}
