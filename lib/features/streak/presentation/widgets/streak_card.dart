import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/streak_status.dart';

/// Gradient card with the fire icon, streak length and a "study today" hint.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.status,
    required this.streak,
    this.onRetry,
  });

  final ViewStatus status;
  final StreakStatus streak;

  /// Called when the user taps "Retry" after a load error.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final onColor = scheme.onPrimary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department_rounded, size: 48, color: onColor),
          const SizedBox(width: 16),
          Expanded(child: _content(theme, onColor)),
        ],
      ),
    );
  }

  Widget _content(ThemeData theme, Color onColor) {
    switch (status) {
      case ViewStatus.idle:
      case ViewStatus.loading:
        return Text(
          AppStrings.loadingStreak,
          style: theme.textTheme.titleMedium?.copyWith(color: onColor),
        );
      case ViewStatus.error:
        return Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.streakUnavailable,
                style: theme.textTheme.titleMedium?.copyWith(color: onColor),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(foregroundColor: onColor),
                child: const Text(AppStrings.retry),
              ),
          ],
        );
      case ViewStatus.success:
        final days = streak.currentStreak;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.streakDays(days),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: onColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              streak.needsActivityToday
                  ? AppStrings.studyToday
                  : AppStrings.studiedToday,
              style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
            ),
          ],
        );
    }
  }
}
