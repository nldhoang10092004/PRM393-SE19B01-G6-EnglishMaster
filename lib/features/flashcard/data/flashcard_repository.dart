import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/json_utils.dart';
import 'models/flashcard.dart';

/// Flashcard endpoints, including the API's 404-for-empty convention.
class FlashcardRepository {
  FlashcardRepository(this._api);
  final ApiClient _api;

  /// Lists public sets without requesting restricted course sets.
  Future<List<FlashcardSet>> sets() async =>
      asMapList(await _api.get('/api/flashcard/sets'))
          .map(FlashcardSet.fromJson)
          .toList();

  /// Loads all cards belonging to a set.
  Future<FlashcardSet> detail(int id) async => FlashcardSet.fromJson(
    Map<String, dynamic>.from(await _api.get('/api/flashcard/set/$id') as Map),
  );

  /// Returns no progress for a new learner.
  Future<List<FlashcardProgress>> progress(int id) async =>
      (await _emptyOn404('/api/flashcard/progress/set/$id'))
          .map(FlashcardProgress.fromJson)
          .toList();

  /// Lists the student's recorded learning actions.
  Future<List<FlashcardHistory>> history() async =>
      (await _emptyOn404('/api/flashcard/progress/history'))
          .map(FlashcardHistory.fromJson)
          .toList();

  /// Records numeric enum values expected by ASP.NET.
  Future<void> learn(int itemId, {required bool mastered}) async {
    await _api.post(
      '/api/flashcard/progress/learn',
      body: {
        'itemId': itemId,
        'actionType': mastered ? 2 : 1,
        'isCorrect': mastered,
      },
    );
  }

  Future<List<Map<String, dynamic>>> _emptyOn404(String path) async {
    try {
      return asMapList(await _api.get(path));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }
}
