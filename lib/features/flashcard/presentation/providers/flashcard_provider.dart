import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/flashcard_repository.dart';
import '../../data/models/flashcard.dart';

/// Public set catalog and separately loaded learning history.
class FlashcardProvider extends ChangeNotifier {
  FlashcardProvider(this.repository);
  final FlashcardRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  List<FlashcardSet> sets = [];
  bool _disposed = false;

  /// Refreshes the public set catalog.
  Future<void> load() async {
    if (status == ViewStatus.loading) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      sets = await repository.sets();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.flashcardsLoadError;
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

/// Route-scoped study state; failed writes never advance the card queue.
class FlashcardStudyProvider extends ChangeNotifier {
  FlashcardStudyProvider(this.repository);
  final FlashcardRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  String? progressError;
  FlashcardSet? set;
  List<FlashcardProgress> progress = [];
  final List<Flashcard> _queue = [];
  bool flipped = false;
  bool busy = false;
  int masteredCount = 0;
  int reviews = 0;
  bool _disposed = false;
  Flashcard? get current => _queue.isEmpty ? null : _queue.first;
  bool get complete => set != null && _queue.isEmpty;
  int get remaining => _queue.length;
  double get fraction =>
      set == null || set!.items.isEmpty ? 0 : masteredCount / set!.items.length;

  /// Loads detail and progress, retaining usable cards if progress fails.
  Future<void> load(int id) async {
    if (status == ViewStatus.loading || busy) return;
    status = ViewStatus.loading;
    error = null;
    progressError = null;
    notifyListeners();
    try {
      set = await repository.detail(id);
      _queue
        ..clear()
        ..addAll(set!.items);
      masteredCount = 0;
      reviews = 0;
      flipped = false;
      try {
        progress = await repository.progress(id);
      } on ApiException catch (e) {
        progressError = e.message;
      } catch (_) {
        progressError = AppStrings.progressError;
      }
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.setLoadError;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Flips the active card without affecting learning progress.
  void flip() {
    if (!busy && current != null) {
      flipped = !flipped;
      notifyListeners();
    }
  }

  /// Again puts the card at the end; Got it removes it after persistence.
  Future<void> answer({required bool mastered}) async {
    if (busy || current == null) return;
    final card = current!;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await repository.learn(card.id, mastered: mastered);
      _queue.removeAt(0);
      if (mastered) {
        masteredCount++;
      } else {
        _queue.add(card);
      }
      reviews++;
      flipped = false;
      final previous = progress.where((p) => p.itemId == card.id).firstOrNull;
      progress = [
        ...progress.where((p) => p.itemId != card.id),
        FlashcardProgress(
          itemId: card.id,
          isMastered: mastered,
          isSaved: previous?.isSaved ?? false,
          reviewCount: (previous?.reviewCount ?? 0) + 1,
        ),
      ];
    } on ApiException catch (e) {
      error = e.message;
    } catch (_) {
      error = AppStrings.recordLearningError;
    }
    busy = false;
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
