import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Compact statistic which wraps its label on small displays.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.colors,
    this.reward = false,
  });
  final String value, label;
  final IconData? icon;
  final SkillColors? colors;
  final bool reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    final ink = reward ? p.onReward : colors?.ink ?? p.ink;
    final edge = reward
        ? p.onReward.withValues(alpha: .28)
        : colors?.edge ?? p.outline;
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: reward ? p.reward : colors?.background ?? p.surface,
        border: Border.all(color: edge, width: 2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: ink, size: 22),
            const SizedBox(height: 4),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: ink,
                fontSize: 24,
              ),
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors != null || reward ? ink : p.inkMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
