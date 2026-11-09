import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Material 3 window size classes. Compact: phones and folded foldables.
/// Medium: unfolded foldables and tablets in portrait. Expanded: tablet landscape.
abstract final class Breakpoints {
  static const medium = 600.0;
  static const expanded = 840.0;

  /// The whole app never grows wider than this; extra space shows the background.
  static const appMaxWidth = 1100.0;

  /// Comfortable line length for forms, exercises and long text.
  static const readable = 720.0;

  /// Whether the current window is at least the medium size class.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;
}

/// Side padding that centres content at most [maxWidth] wide while the
/// scroll area itself stays full width (so it scrolls from anywhere).
EdgeInsets readablePadding(
  BuildContext context, {
  double horizontal = 20,
  double top = 20,
  double bottom = 20,
  double maxWidth = Breakpoints.readable,
}) {
  final width = MediaQuery.sizeOf(context).width;
  final side = math.max(horizontal, (width - maxWidth) / 2);
  return EdgeInsets.fromLTRB(side, top, side, bottom);
}

/// Centres [child] at most [maxWidth] wide (for non-scrolling content).
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.readable,
  });
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Wraps every route (via `MaterialApp.builder`): on very wide windows the app
/// is centred at [Breakpoints.appMaxWidth] and descendants see that width.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width <= Breakpoints.appMaxWidth) return child;
    const width = Breakpoints.appMaxWidth;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: SizedBox(
          width: width,
          child: MediaQuery(
            data: media.copyWith(size: Size(width, media.size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
