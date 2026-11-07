import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/quiz_repository.dart';
import 'presentation/providers/quiz_provider.dart';

/// Quiz catalog dependencies; attempt state is scoped to its route.
class QuizProviders {
  QuizProviders._();

  /// Registers the repository and system catalog state after ApiClient.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, QuizRepository>(
      update: (_, api, previous) => previous ?? QuizRepository(api),
    ),
    ChangeNotifierProvider(
      create: (context) => QuizProvider(context.read<QuizRepository>()),
    ),
  ];
}
