import 'package:flutter/material.dart';

/// Large score ring using a tonal track and a scalable centered label.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.fraction, required this.label});
  final double fraction;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 188,
        height: 188,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.secondaryContainer,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: fraction.clamp(0, 1),
                strokeWidth: 10,
                strokeCap: StrokeCap.round,
                color: theme.colorScheme.secondary,
                backgroundColor: theme.colorScheme.surface,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FittedBox(
                child: Text(
                  label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
