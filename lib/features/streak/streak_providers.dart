import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/streak_repository.dart';
import 'presentation/providers/streak_provider.dart';

/// Dependency registration of the streak feature.
class StreakProviders {
  StreakProviders._();

  /// Providers to add to the app-level `MultiProvider`.
  static List<SingleChildWidget> providers() => [
        ProxyProvider<ApiClient, StreakRepository>(update: (_, api, _) => StreakRepository(api)),
        ChangeNotifierProvider<StreakProvider>(create: (ctx) => StreakProvider(ctx.read<StreakRepository>())),
      ];
}
