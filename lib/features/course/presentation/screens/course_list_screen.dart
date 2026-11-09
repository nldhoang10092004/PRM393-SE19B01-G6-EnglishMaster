import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../providers/course_list_provider.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

/// Searchable catalog backed by the existing shared course provider.
class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  String _query = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          context.read<CourseListProvider>().status == ViewStatus.idle) {
        context.read<CourseListProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseListProvider>();
    final courses = state.courses
        .where(
          (c) => ('${c.name} ${c.teacherName}').toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                AppStrings.course,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                key: const Key('course_search'),
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: AppStrings.searchCourses,
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: state.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (state.status != ViewStatus.success || courses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AsyncView(
                          status: state.status,
                          error: state.error,
                          onRetry: state.load,
                          isEmpty: courses.isEmpty,
                          emptyMessage: state.courses.isEmpty
                              ? AppStrings.noCourses
                              : AppStrings.noMatchingCourses,
                          builder: (_) => const SizedBox.shrink(),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverList.separated(
                          itemCount: courses.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final c = courses[index];
                            return CourseCard(
                              course: c,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CourseDetailScreen(
                                    courseId: c.id,
                                    title: c.name,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
