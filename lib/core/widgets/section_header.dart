import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_palette.dart';

/// Responsive section title with an editorial ledger bar and optional catalog action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: p.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text(AppStrings.viewAll),
          ),
      ],
    );
  }
}
