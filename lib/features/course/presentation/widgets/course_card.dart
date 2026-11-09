import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../data/models/course_summary.dart';

/// Course row showing API titles and teachers with a coloured initial tile.
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});
  final CourseSummary course;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final theme = Theme.of(context);
    final colors = [
      p.speaking,
      p.listening,
      p.writing,
    ][(course.id - 1).abs() % 3];
    return OutlinedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              course.initials,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                color: colors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  course.teacherName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
