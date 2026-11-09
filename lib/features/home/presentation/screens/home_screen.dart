import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skill_tile.dart';
import '../../../course/presentation/providers/course_list_provider.dart';
import '../../../course/presentation/screens/course_detail_screen.dart';
import '../../../course/presentation/screens/course_list_screen.dart';
import '../../../course/presentation/widgets/course_card_sliver.dart';
import '../../../streak/presentation/providers/streak_provider.dart';
import '../../../streak/presentation/widgets/streak_card.dart';
import '../../../ai_exam/presentation/screens/ai_speaking_screen.dart';
import '../../../ai_exam/presentation/screens/ai_listening_screen.dart';
import '../../../ai_exam/presentation/screens/ai_reading_screen.dart';
import '../../../ai_exam/presentation/screens/ai_writing_screen.dart';
import '../widgets/home_greeting.dart';

/// Dashboard with a real streak, three AI skills and compact course discovery.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onViewCourses});
  final VoidCallback? onViewCourses;
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

  void _open(Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));
  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseListProvider>();
    final streak = context.watch<StreakProvider>();
    final p = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: HomeGreeting()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: StreakCard(
                    status: streak.status,
                    streak: streak.streak,
                    onRetry: streak.load,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: AppStrings.aiPracticeTitle),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SkillTile(
                              label: AppStrings.speaking,
                              icon: Icons.mic_none_rounded,
                              colors: p.speaking,
                              onTap: () => _open(const AiSpeakingScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SkillTile(
                              label: AppStrings.reading,
                              icon: Icons.menu_book_rounded,
                              colors: p.reading,
                              onTap: () => _open(const AiReadingScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SkillTile(
                              label: AppStrings.listening,
                              icon: Icons.headphones_rounded,
                              colors: p.listening,
                              onTap: () => _open(const AiListeningScreen()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SkillTile(
                              label: AppStrings.writing,
                              icon: Icons.edit_outlined,
                              colors: p.writing,
                              onTap: () => _open(const AiWritingScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SectionHeader(
                        title: AppStrings.continueLearning,
                        onViewAll:
                            widget.onViewCourses ??
                            () => _open(const CourseListScreen()),
                      ),
                      const SizedBox(height: 12),
                    ],
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
                    onRetry: courses.load,
                    isEmpty: courses.courses.isEmpty,
                    emptyMessage: AppStrings.noCourses,
                    builder: (_) => const SizedBox.shrink(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: CourseCardSliver(
                    courses: courses.courses,
                    onTap: (c) => _open(
                      CourseDetailScreen(courseId: c.id, title: c.name),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
