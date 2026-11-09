import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../../core/widgets/icon_square_button.dart';
import '../../../../core/widgets/pill_chip.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../quiz/presentation/widgets/quiz_list_for_course.dart';
import '../../../video/presentation/screens/video_lesson_screen.dart';
import '../../data/course_repository.dart';
import '../../data/models/course_detail.dart';
import '../providers/course_detail_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/rating_stars.dart';

/// Course detail: hero header, description, expandable chapters with videos,
/// quizzes slot and reviews.
class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.courseId, this.title});

  final int courseId;

  /// Course name shown while the detail is loading.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          CourseDetailProvider(ctx.read<CourseRepository>(), courseId)..load(),
      child: _CourseDetailView(title: title),
    );
  }
}

class _CourseDetailView extends StatelessWidget {
  const _CourseDetailView({this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CourseDetailProvider>();
    final course = p.course;
    final lessons = [
      ...?course?.chapters.expand((c) => c.videos),
      ...?course?.orphanVideos,
    ];
    final next =
        lessons.where((v) => !p.isCompleted(v.id)).firstOrNull ??
        lessons.firstOrNull;
    final ready = p.status == ViewStatus.success && course != null;
    return Scaffold(
      appBar: ready ? null : AppTopBar(title: Text(title ?? AppStrings.course)),
      bottomNavigationBar: !ready || next == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: ChunkyButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VideoLessonScreen(
                          videoId: next.id,
                          title: next.name,
                        ),
                      ),
                    );
                    p.loadProgressFor([next], force: true);
                  },
                  child: Text(
                    AppStrings.continueLesson(next.name),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
      body: AsyncView(
        status: p.status,
        error: p.error,
        onRetry: p.load,
        builder: (context) => RefreshIndicator(
          onRefresh: p.load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _Header(course: course!, provider: p),
              _sectionTitle(context, AppStrings.courseContent),
              _Chapters(course: course, provider: p),
              _sectionTitle(context, AppStrings.quizzes),
              SliverToBoxAdapter(child: QuizListForCourse(courseId: course.id)),
              _sectionTitle(context, AppStrings.reviews),
              _Reviews(provider: p),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionTitle(BuildContext context, String text) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
      );
}

/// Flat course hero using the speaking block from the approved reference.
class _Header extends StatelessWidget {
  const _Header({required this.course, required this.provider});
  final CourseDetail course;
  final CourseDetailProvider provider;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final t = Theme.of(context);
    final colors = p.speaking;
    final rating = provider.rating;
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconSquareButton(
                  icon: Icons.chevron_left,
                  tooltip: AppStrings.previous,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 14),
                PillChip(
                  label: course.teacherName.isEmpty
                      ? AppStrings.appName
                      : course.teacherName,
                  color: p.surface,
                  foreground: colors.ink,
                ),
                const SizedBox(height: 14),
                Text(
                  course.name,
                  style: t.textTheme.headlineSmall?.copyWith(color: colors.ink),
                ),
                if (course.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    course.description,
                    style: t.textTheme.bodyMedium?.copyWith(color: colors.ink),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    RatingStars(rating: rating.average, color: colors.ink),
                    Text(
                      rating.total == 0
                          ? AppStrings.noReviews
                          : AppStrings.ratingSummary(
                              rating.average,
                              rating.total,
                            ),
                      style: t.textTheme.bodySmall?.copyWith(color: colors.ink),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Expandable chapters; completion checks load when a chapter is opened.
class _Chapters extends StatefulWidget {
  const _Chapters({required this.course, required this.provider});

  final CourseDetail course;
  final CourseDetailProvider provider;
  @override
  State<_Chapters> createState() => _ChaptersState();
}

class _ChaptersState extends State<_Chapters> {
  CourseDetail get course => widget.course;
  CourseDetailProvider get provider => widget.provider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        provider.loadProgressFor(
          course.chapters.firstOrNull?.videos ?? course.orphanVideos,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final c in course.chapters) (c.name, c.videos),
      if (course.orphanVideos.isNotEmpty)
        (AppStrings.otherLessons, course.orphanVideos),
    ];
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(AppStrings.noLessons),
        ),
      );
    }
    return SliverList.builder(
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final (name, videos) = groups[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              initiallyExpanded: i == 0,
              leading: CircleAvatar(child: Text('${i + 1}')),
              onExpansionChanged: (open) {
                if (open) provider.loadProgressFor(videos);
              },
              title: Text(name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(AppStrings.lessonCount(videos.length)),
              children: [
                for (final v in videos)
                  _VideoTile(video: v, provider: provider),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.provider});

  final LessonSummary video;
  final CourseDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final done = provider.isCompleted(video.id);
    return ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.play_circle_outline_rounded,
        color: done
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(video.name),
      trailing: video.isPreview
          ? const Chip(
              label: Text(AppStrings.free),
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) =>
                VideoLessonScreen(videoId: video.id, title: video.name),
          ),
        );
        provider.loadProgressFor([video], force: true);
      },
    );
  }
}

/// Review summary, "write a review" button and the review list.
class _Reviews extends StatelessWidget {
  const _Reviews({required this.provider});

  final CourseDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedbacks = provider.feedbacks;
    return SliverList.list(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ChunkyOutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final sent = await showDialog<bool>(
                  context: context,
                  builder: (_) => FeedbackDialog(provider: provider),
                );
                if (sent == true) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text(AppStrings.reviewThanks)),
                  );
                }
              },
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text(AppStrings.writeReview),
            ),
          ),
        ),
        if (feedbacks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(AppStrings.firstReview),
          ),
        for (final f in feedbacks)
          ListTile(
            leading: CircleAvatar(
              child: Text(
                f.username.isEmpty
                    ? AppStrings.unknownInitial
                    : f.username.substring(0, 1).toUpperCase(),
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(f.username, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                RatingStars(rating: f.rating.toDouble(), size: 14),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((f.comment ?? '').trim().isNotEmpty) Text(f.comment!),
                if (f.createdAt != null)
                  Text(
                    DateFormat.yMMMd('vi').format(f.createdAt!.toLocal()),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
