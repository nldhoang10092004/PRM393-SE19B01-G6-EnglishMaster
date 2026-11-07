import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/widgets/user_avatar.dart';

import '../../../../core/l10n/app_strings.dart';

/// Header of the dashboard: avatar and a time-of-day greeting.
///
/// The login response carries no display name, so the greeting is generic.
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, this.userName, this.now});

  /// Shown after the greeting when known.
  final String? userName;

  /// Clock override for tests; defaults to `DateTime.now()`.
  final DateTime? now;

  /// "Good morning", "Good afternoon" or "Good evening" for [hour].
  static String greetingFor(int hour) {
    if (hour < 12) return AppStrings.morning;
    if (hour < 18) return AppStrings.afternoon;
    return AppStrings.evening;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider?>();
    final name = (userName ?? profile?.profile?.fullName)?.trim() ?? '';
    final greeting = greetingFor((now ?? DateTime.now()).hour);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          UserAvatar(url: profile?.avatarUrl, name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty
                      ? greeting
                      : AppStrings.greetingName(greeting, name),
                  style: theme.textTheme.headlineSmall,
                ),
                Text(
                  AppStrings.readyToLearn,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
