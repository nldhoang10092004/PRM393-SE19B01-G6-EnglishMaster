import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/flashcard_repository.dart';
import '../../data/models/flashcard.dart';

/// Independently refreshable flashcard history.
class FlashcardHistoryProvider extends ChangeNotifier {
  FlashcardHistoryProvider(this.repository);
  final FlashcardRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  List<FlashcardHistory> items = [];
  bool _disposed = false;

  /// Refreshes history, including an empty response for a new learner.
  Future<void> load() async {
    if (status == ViewStatus.loading) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      items = await repository.history();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.historyLoadError;
      status = ViewStatus.error;
    }
    notifyListeners();
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
