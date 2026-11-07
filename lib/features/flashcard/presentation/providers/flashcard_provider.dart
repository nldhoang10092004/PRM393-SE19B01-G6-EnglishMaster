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

/// Route-scoped study state.
///
/// The learner browses every card of the set with previous/next; the
/// mastered count comes from the progress saved on the server, so it matches
/// the set detail screen. Failed writes never move to another card.
class FlashcardStudyProvider extends ChangeNotifier {
  FlashcardStudyProvider(this.repository);
  final FlashcardRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  String? progressError;
  FlashcardSet? set;
  List<FlashcardProgress> progress = [];
  List<Flashcard> _cards = const [];
  int index = 0;
  bool flipped = false;
  bool busy = false;

  /// Number of answers given in this session (for the summary).
  int reviews = 0;

  /// True after the learner answered the last card of the set.
  bool complete = false;
  bool _disposed = false;

  int get total => _cards.length;
  Flashcard? get current => _cards.isEmpty || complete ? null : _cards[index];
  bool get hasPrevious => index > 0;
  bool get hasNext => index < _cards.length - 1;

  bool isMastered(int itemId) =>
      progress.any((p) => p.itemId == itemId && p.isMastered);

  /// Mastered cards of this set according to the saved progress.
  int get masteredCount => _cards.where((c) => isMastered(c.id)).length;
  int get remaining => total - masteredCount;
  double get fraction => total == 0 ? 0 : masteredCount / total;

  /// Loads detail and progress, retaining usable cards if progress fails.
  /// Starts at the first card that is not mastered yet.
  Future<void> load(int id) async {
    if (status == ViewStatus.loading || busy) return;
    status = ViewStatus.loading;
    error = null;
    progressError = null;
    notifyListeners();
    try {
      set = await repository.detail(id);
      _cards = List.unmodifiable(set!.items);
      reviews = 0;
      complete = false;
      flipped = false;
      try {
        progress = await repository.progress(id);
      } on ApiException catch (e) {
        progressError = e.message;
      } catch (_) {
        progressError = AppStrings.progressError;
      }
      final firstUnmastered = _cards.indexWhere((c) => !isMastered(c.id));
      index = firstUnmastered < 0 ? 0 : firstUnmastered;
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

  /// Moves to the previous card (front side up).
  void previous() {
    if (busy || !hasPrevious) return;
    index--;
    flipped = false;
    notifyListeners();
  }

  /// Moves to the next card (front side up).
  void next() {
    if (busy || !hasNext) return;
    index++;
    flipped = false;
    notifyListeners();
  }

  /// Jumps to a card, e.g. from a swipe gesture.
  void goTo(int value) {
    if (busy || value < 0 || value >= _cards.length || value == index) return;
    index = value;
    flipped = false;
    notifyListeners();
  }

  /// Restarts the session from the first card that is still not mastered.
  void restart() {
    final firstUnmastered = _cards.indexWhere((c) => !isMastered(c.id));
    index = firstUnmastered < 0 ? 0 : firstUnmastered;
    complete = false;
    flipped = false;
    notifyListeners();
  }

  /// Saves "Again" / "Got it" for the current card, then moves to the next
  /// card; answering the last card finishes the session.
  Future<void> answer({required bool mastered}) async {
    if (busy || current == null) return;
    final card = current!;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await repository.learn(card.id, mastered: mastered);
      reviews++;
      flipped = false;
      if (hasNext) {
        index++;
      } else {
        complete = true;
      }
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
