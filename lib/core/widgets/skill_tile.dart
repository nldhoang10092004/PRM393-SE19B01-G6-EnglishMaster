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
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: colors.edge, offset: const Offset(0, 4))],
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 116,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 26, color: colors.ink),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 20, color: colors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
