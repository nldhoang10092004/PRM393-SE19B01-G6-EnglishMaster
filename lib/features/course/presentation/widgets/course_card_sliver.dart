import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';
import '../../data/models/course_summary.dart';
import 'course_card.dart';

/// Course cards as a list on phones and a multi-column grid on wide windows.
class CourseCardSliver extends StatelessWidget {
  const CourseCardSliver({
    super.key,
    required this.courses,
    required this.onTap,
  });
  final List<CourseSummary> courses;
  final void Function(CourseSummary course) onTap;

  @override
  Widget build(BuildContext context) {
    Widget card(int index) =>
        CourseCard(course: courses[index], onTap: () => onTap(courses[index]));
    if (!Breakpoints.isWide(context)) {
      return SliverList.separated(
        itemCount: courses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) => card(index),
      );
    }
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 460,
        mainAxisExtent: 124,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: courses.length,
      itemBuilder: (_, index) => card(index),
    );
  }
}
