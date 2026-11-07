import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../data/models/course_summary.dart';

/// Horizontal course discovery card; opens the existing course detail flow.
class CoursePreviewCard extends StatelessWidget {
  const CoursePreviewCard({
    super.key,
    required this.course,
    required this.onTap,
  });
  final CourseSummary course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = [
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
    ];
    final color = palette[course.id.abs() % palette.length];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 88,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    Color.alphaBlend(
                      color.withValues(alpha: .7),
                      scheme.surface,
                    ),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 38,
                    color: scheme.onSurface,
                  ),
                  const Spacer(),
                  Text(course.initials, style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.teacherName.isEmpty
                        ? AppStrings.appName
                        : course.teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
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
