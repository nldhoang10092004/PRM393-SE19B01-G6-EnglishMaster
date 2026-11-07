import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/flashcard_repository.dart';
import 'presentation/providers/flashcard_provider.dart';

/// Dependencies to spread into the integrator's MultiProvider.
class FlashcardProviders {
  FlashcardProviders._();

  /// Registers the repository and catalog state after ApiClient.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, FlashcardRepository>(
      update: (_, api, previous) => previous ?? FlashcardRepository(api),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          FlashcardProvider(context.read<FlashcardRepository>()),
    ),
  ];
}
