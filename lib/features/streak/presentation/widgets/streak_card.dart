import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/streak_status.dart';

/// Bordered daily goal card; only actual streak data is shown.
class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.status,
    required this.streak,
    this.onRetry,
  });
  final ViewStatus status;
  final StreakStatus streak;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final theme = Theme.of(context);
    return OutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  AppStrings.todayGoal,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Flexible(
                flex: 2,
                child: Text(
                  status == ViewStatus.success
                      ? AppStrings.streakDays(streak.currentStreak)
                      : status == ViewStatus.error
                      ? AppStrings.streakUnavailable
                      : AppStrings.loadingStreak,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (status == ViewStatus.success) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                7,
                (index) => Expanded(
                  child: Container(
                    height: 30,
                    margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
                    decoration: BoxDecoration(
                      color: index < streak.currentStreak.clamp(0, 7)
                          ? p.reward
                          : p.muted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              streak.needsActivityToday
                  ? AppStrings.studyToday
                  : AppStrings.studiedToday,
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (status == ViewStatus.error && onRetry != null)
            TextButton(onPressed: onRetry, child: const Text(AppStrings.retry)),
        ],
      ),
    );
  }
}
