import 'package:flutter/material.dart';

/// Row of five stars filled according to [rating] (0..5, half steps rounded).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  final double rating;
  final double size;

  /// Defaults to `colorScheme.tertiary`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.tertiary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final diff = rating - i;
        final icon = diff >= 0.75
            ? Icons.star_rounded
            : diff >= 0.25
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: c);
      }),
    );
  }
}
