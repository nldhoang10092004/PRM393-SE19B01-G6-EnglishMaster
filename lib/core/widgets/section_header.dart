import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// Responsive section title with an optional catalog action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (onViewAll != null)
        TextButton(onPressed: onViewAll, child: const Text(AppStrings.viewAll)),
    ],
  );
}
