import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import 'icon_square_button.dart';

/// Compact reference-style header with a square back control.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.large = false,
  });
  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  /// Tab-root headline (28 ExtraBold) instead of the compact 18 title.
  final bool large;
  @override
  Size get preferredSize =>
      Size.fromHeight(80 + (bottom?.preferredSize.height ?? 0));
  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: SizedBox(
            height: 48,
            child: Row(
              children: [
                if (automaticallyImplyLeading &&
                    Navigator.of(context).canPop()) ...[
                  IconSquareButton(
                    icon: Icons.chevron_left,
                    tooltip: AppStrings.close,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: large ? 28 : 18,
                      fontWeight: large ? FontWeight.w800 : null,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: title,
                  ),
                ),
                ...?actions,
              ],
            ),
          ),
        ),
        ?bottom,
      ],
    ),
  );
}
