import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Compact, wrapping pill for filters and semantic badges.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.color,
    this.foreground,
    this.icon,
    this.onTap,
  });
  final String label;
  final bool selected;
  final Color? color, foreground;
  final IconData? icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final fg = foreground ?? (selected ? p.onPrimary : p.ink);
    return Semantics(
      selected: onTap == null ? null : selected,
      child: Material(
        color: color ?? (selected ? p.primary : p.muted),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: fg, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
