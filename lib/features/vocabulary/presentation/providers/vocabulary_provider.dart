import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/saved_word.dart';
import '../../data/vocabulary_repository.dart';

/// Searchable saved vocabulary with serialized per-item mutations and undo.
class VocabularyProvider extends ChangeNotifier {
  VocabularyProvider(this.repository);
  final VocabularyRepository repository;
  ViewStatus status = ViewStatus.idle;
  String? error;
  List<SavedWord> _words = [];
  String _query = '';
  final Set<int> _pending = {};
  bool _disposed = false;
  List<SavedWord> get words => List.unmodifiable(
    _words.where(
      (w) => '${w.front} ${w.back} ${w.example}'.toLowerCase().contains(_query),
    ),
  );
  bool isPending(int id) => _pending.contains(id);
  bool isSaved(int id) => _words.any((w) => w.itemId == id);

  /// Filters all text locally without another HTTP request.
  void search(String value) {
    _query = value.trim().toLowerCase();
    notifyListeners();
  }

  /// Refreshes the saved list.
  Future<void> load() async {
    if (status == ViewStatus.loading) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      _words = await repository.list();
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = 'Unable to load saved vocabulary.';
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Saves a term, including sufficient text for immediate display and undo.
  Future<bool> save(SavedWord word) => _mutate(word, save: true);

  /// Removes a word after a successful server response.
  Future<bool> remove(SavedWord word) => _mutate(word, save: false);

  Future<bool> _mutate(SavedWord word, {required bool save}) async {
    if (!_pending.add(word.itemId)) return false;
    error = null;
    notifyListeners();
    try {
      if (save) {
        await repository.save(word.itemId);
      } else {
        await repository.delete(word.itemId);
      }
      _words = _words.where((w) => w.itemId != word.itemId).toList();
      if (save) _words.insert(0, word);
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Could not update saved vocabulary.';
      return false;
    } finally {
      _pending.remove(word.itemId);
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
