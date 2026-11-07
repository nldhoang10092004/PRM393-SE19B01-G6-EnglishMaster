import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/vocabulary_repository.dart';
import 'presentation/providers/vocabulary_provider.dart';

/// Saved vocabulary dependencies, also used by flashcard bookmarks.
class VocabularyProviders {
  VocabularyProviders._();

  /// Registers saved-word dependencies, also required by flashcard study.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, VocabularyRepository>(
      update: (_, api, previous) => previous ?? VocabularyRepository(api),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          VocabularyProvider(context.read<VocabularyRepository>()),
    ),
  ];
}
