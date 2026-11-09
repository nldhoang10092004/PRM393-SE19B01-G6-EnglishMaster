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
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.outline, width: 1.0),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 104,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.edge, width: 1.0),
                        ),
                        child: Icon(icon, size: 20, color: colors.ink),
                      ),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                        color: p.inkMuted,
                      ),
                    ],
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                      letterSpacing: -0.2,
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
