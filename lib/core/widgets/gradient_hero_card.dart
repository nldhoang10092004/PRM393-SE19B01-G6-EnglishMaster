import 'package:flutter/material.dart';

/// Tonal hero with an illustration and contrast-safe text in either theme.
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.warm = false,
  });
  final String title, subtitle;
  final IconData icon;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = warm
        ? scheme.secondaryContainer
        : scheme.primaryContainer;
    final foreground = warm
        ? scheme.onSecondaryContainer
        : scheme.onPrimaryContainer;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            background,
            Color.alphaBlend(background.withValues(alpha: .75), scheme.surface),
          ],
        ),
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
