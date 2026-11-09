import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Flat hero with an illustration and contrast-safe text in either theme.
class FlatHeroCard extends StatelessWidget {
  const FlatHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.warm = false,
    this.colors,
  });
  final String title, subtitle;
  final IconData icon;
  final bool warm;
  final SkillColors? colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background =
        colors?.background ??
        (warm ? scheme.secondaryContainer : scheme.primaryContainer);
    final foreground =
        colors?.ink ??
        (warm ? scheme.onSecondaryContainer : scheme.onPrimaryContainer);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: foreground.withValues(alpha: .08),
            child: Icon(icon, size: 30, color: foreground),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(color: foreground),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
