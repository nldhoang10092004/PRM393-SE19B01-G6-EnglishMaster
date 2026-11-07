import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/network/api_client.dart';
import 'data/membership_repository.dart';
import 'presentation/providers/membership_provider.dart';

/// Membership dependencies; payment polling state is scoped to its screen.
class MembershipProviders {
  MembershipProviders._();

  /// Registers the repository and membership state after ApiClient.
  static List<SingleChildWidget> providers() => [
    ProxyProvider<ApiClient, MembershipRepository>(
      update: (_, api, previous) => previous ?? MembershipRepository(api),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          MembershipProvider(context.read<MembershipRepository>()),
    ),
  ];
}
