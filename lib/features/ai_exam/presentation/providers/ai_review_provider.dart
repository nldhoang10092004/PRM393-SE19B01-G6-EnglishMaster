import 'package:flutter/foundation.dart';

import '../../../../core/widgets/async_view.dart';
import '../../data/ai_exam_repository.dart';
import '../../data/models/ai_exam.dart';
import 'ai_exam_provider.dart';

/// Independent list/detail state so navigation cannot overwrite another review.
class AiReviewProvider extends ChangeNotifier {
  AiReviewProvider(this.repository);
  final AiExamRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  List<AiExamSubmission> submissions = const [];
  AiExamReview? detail;
  bool _disposed = false;

  Future<void> _load(Future<void> Function() action) async {
    if (status == ViewStatus.loading || _disposed) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      await action();
      status = ViewStatus.success;
    } catch (failure) {
      error = aiExamError(failure);
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Fetches the student's saved speaking and writing submissions.
  Future<void> loadHistory() => _load(() async {
    submissions = await repository.history();
  });

  /// Uses a separate provider instance for each pushed detail route.
  Future<void> loadDetail(int id) => _load(() async {
    detail = await repository.review(id);
  });

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
