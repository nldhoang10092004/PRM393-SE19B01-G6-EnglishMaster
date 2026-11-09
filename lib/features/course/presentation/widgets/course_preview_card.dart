import 'package:flutter/material.dart';

import '../../data/models/course_summary.dart';
import 'course_card.dart';

/// Discovery row sharing the catalog component.
class CoursePreviewCard extends StatelessWidget {
  const CoursePreviewCard({
    super.key,
    required this.course,
    required this.onTap,
  });
  final CourseSummary course;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      CourseCard(course: course, onTap: onTap);
}
