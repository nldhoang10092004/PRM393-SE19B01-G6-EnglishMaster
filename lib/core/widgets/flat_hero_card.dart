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
    final p = AppPalette.of(context);
    final background =
        colors?.background ??
        (warm ? scheme.secondaryContainer : scheme.primaryContainer);
    final foreground =
        colors?.ink ??
        (warm ? scheme.onSecondaryContainer : scheme.onPrimaryContainer);
    final edge = colors?.edge ?? p.outline;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: background,
        border: Border.all(color: edge, width: 2),
        boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: edge, width: 1.5),
            ),
            child: Icon(icon, size: 28, color: foreground),
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
