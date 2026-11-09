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
    final activeDays = streak.currentStreak.clamp(0, 7);
    return OutlinedCard(
      edgeColor: p.outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: p.reward,
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  AppStrings.todayGoal,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: p.inkMuted,
                  ),
                ),
              ),
            ],
          ),
          if (status == ViewStatus.success) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(7, (index) {
                final done = index < activeDays;
                return Expanded(
                  child: Container(
                    height: 28,
                    margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? p.primary : p.muted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: done
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: p.onPrimary,
                          )
                        : Text(
                            ['2', '3', '4', '5', '6', '7', 'C'][index],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: p.inkMuted,
                            ),
                          ),
                  ),
                );
              }),
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
