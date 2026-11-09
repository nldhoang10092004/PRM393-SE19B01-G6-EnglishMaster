import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// A large, flat skill shortcut with its own semantic colour block.
class SkillTile extends StatelessWidget {
  const SkillTile({
    super.key,
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final SkillColors colors;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.edge, width: 2),
        boxShadow: [BoxShadow(color: colors.edge, offset: const Offset(0, 4))],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 116,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: p.surface.withValues(alpha: .72),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.edge, width: 1.5),
                        ),
                        child: Icon(icon, size: 22, color: colors.ink),
                      ),
                      Icon(
                        Icons.north_east_rounded,
                        size: 18,
                        color: colors.ink,
                      ),
                    ],
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 19,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
