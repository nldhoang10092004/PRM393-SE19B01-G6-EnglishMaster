import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'data/notification_service.dart';
import 'presentation/providers/reminder_provider.dart';

/// Dependency registration of the notifications feature.
class NotificationsProviders {
  NotificationsProviders._();

  /// Providers to add to the app-level `MultiProvider`.
  static List<SingleChildWidget> providers() => [
        Provider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<ReminderProvider>(
          create: (ctx) => ReminderProvider(ctx.read<NotificationService>())..load(),
        ),
      ];
}
