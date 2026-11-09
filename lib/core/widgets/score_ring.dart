import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Primary score ring with scalable text, including compact mastery rings.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.fraction,
    required this.label,
    this.size = 196,
    this.subtitle,
    this.color,
    this.trackColor,
    this.labelColor,
  });
  final double fraction, size;
  final String label;
  final String? subtitle;
  final Color? color, trackColor, labelColor;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(size * .05),
                child: CircularProgressIndicator(
                  value: fraction.clamp(0, 1),
                  strokeWidth: size * .1,
                  strokeCap: StrokeCap.butt,
                  color: color ?? p.primary,
                  backgroundColor: trackColor ?? p.muted,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size * .16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: size * .265,
                            color: labelColor ?? p.primary,
                          ),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
