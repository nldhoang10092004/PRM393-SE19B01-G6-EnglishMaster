import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/pill_chip.dart';
import '../../../streak/presentation/providers/streak_provider.dart';

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
    final p = AppPalette.of(context);
    final streak = context.watch<StreakProvider?>();
    final profile = context.watch<ProfileProvider?>();
    final name = (userName ?? profile?.profile?.fullName)?.trim() ?? '';
    final greeting = greetingFor((now ?? DateTime.now()).hour);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Row(
        children: [
          UserAvatar(url: profile?.avatarUrl, name: name),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.inkMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? AppStrings.student : name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (streak != null)
            PillChip(
              label: streak.streak.currentStreak.toString(),
              icon: Icons.local_fire_department_outlined,
              color: p.reward,
              foreground: p.onReward,
            ),
        ],
      ),
    );
  }
}
