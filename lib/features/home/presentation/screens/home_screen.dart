import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../course/presentation/providers/course_list_provider.dart';
import '../../../course/presentation/screens/course_detail_screen.dart';
import '../../../course/presentation/widgets/course_card.dart';
import '../../../streak/data/models/streak_status.dart';
import '../../../streak/presentation/providers/streak_provider.dart';
import '../../../streak/presentation/widgets/streak_card.dart';
import '../../../ai_exam/presentation/screens/ai_exam_hub_screen.dart';
import '../widgets/home_greeting.dart';

/// Home dashboard: greeting, streak card and the list of courses.
///
/// Needs `CourseListProvider` and `StreakProvider` above it in the tree.
/// Pull down to refresh both.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    await Future.wait([
      context.read<CourseListProvider>().load(),
      context.read<StreakProvider>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseListProvider>();
    // Only the two streak fields the card shows: other StreakProvider changes
    // do not rebuild the whole home screen.
    final streakStatus = context.select<StreakProvider, ViewStatus>(
      (p) => p.status,
    );
    final streakValue = context.select<StreakProvider, StreakStatus>(
      (p) => p.streak,
    );
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: HomeGreeting()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StreakCard(
                    status: streakStatus,
                    streak: streakValue,
                    onRetry: () => context.read<StreakProvider>().load(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _AiPracticeCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    AppStrings.allCourses,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              if (courses.status != ViewStatus.success ||
                  courses.courses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AsyncView(
                    status: courses.status,
                    error: courses.error,
                    onRetry: () => context.read<CourseListProvider>().load(),
                    isEmpty: courses.courses.isEmpty,
                    emptyMessage: AppStrings.noCourses,
                    builder: (_) => const SizedBox.shrink(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList.separated(
                    itemCount: courses.courses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final course = courses.courses[i];
                      return CourseCard(
                        course: course,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => CourseDetailScreen(
                              courseId: course.id,
                              title: course.name,
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
    );
  }
}

/// Shortcut card to the AI exam practice hub (Speaking, Listening, Writing).
class _AiPracticeCard extends StatelessWidget {
  const _AiPracticeCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        color: scheme.tertiaryContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: scheme.tertiary,
            child: Icon(Icons.auto_awesome, color: scheme.onTertiary),
          ),
          title: const Text(AppStrings.aiPracticeTitle),
          subtitle: const Text(AppStrings.aiPracticeSubtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AiExamHubScreen())),
        ),
      ),
    );
  }
}
