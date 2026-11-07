import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/profile_repository.dart';
import 'presentation/providers/profile_provider.dart';

/// Profile dependencies to spread into MultiProvider.
class ProfileProviders {
  ProfileProviders._();

  /// Registers account details and membership state after ApiClient.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, ProfileRepository>(
      update: (_, api, previous) => previous ?? ProfileRepository(api),
    ),
    ChangeNotifierProvider(
      create: (context) => ProfileProvider(context.read<ProfileRepository>()),
    ),
  ];
}
