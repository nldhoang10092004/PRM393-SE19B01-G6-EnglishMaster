import 'package:flutter/material.dart';

import 'chunky_button.dart';

/// White secondary action sharing the primary action's pressed geometry.
class ChunkyOutlinedButton extends StatelessWidget {
  const ChunkyOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });
  ChunkyOutlinedButton.icon({
    super.key,
    required this.onPressed,
    required Widget icon,
    required Widget label,
    this.style,
  }) : child = Row(
         mainAxisSize: MainAxisSize.min,
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           icon,
           const SizedBox(width: 8),
           Flexible(child: label),
         ],
       );
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) =>
      ChunkyButton.secondary(onPressed: onPressed, style: style, child: child);
}
