import '../../../core/network/api_client.dart';
import '../../../core/utils/json_utils.dart';
import 'models/saved_word.dart';

/// Persists bookmarked flashcard item IDs.
class VocabularyRepository {
  VocabularyRepository(this._api);
  final ApiClient _api;

  /// Retrieves the student's saved words.
  Future<List<SavedWord>> list() async =>
      asMapList(await _api.get('/api/user/vocabulary/list'))
          .map(SavedWord.fromJson)
          .toList();

  /// Saves an existing flashcard, rather than creating an arbitrary word.
  Future<void> save(int itemId) async {
    await _api.post('/api/user/vocabulary/save', body: {'itemId': itemId});
  }

  /// Deletes using the flashcard item ID, not a separate vocabulary ID.
  Future<void> delete(int itemId) async {
    await _api.delete('/api/user/vocabulary/$itemId');
  }
}
