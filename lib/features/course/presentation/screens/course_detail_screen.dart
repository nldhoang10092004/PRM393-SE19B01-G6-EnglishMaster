import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
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
      create: (ctx) => CourseDetailProvider(ctx.read<CourseRepository>(), courseId)..load(),
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
    final ready = p.status == ViewStatus.success && course != null;
    return Scaffold(
      appBar: ready ? null : AppBar(title: Text(title ?? 'Course')),
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
              if (course.description.trim().isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(course.description, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ),
              _sectionTitle(context, 'Chapters'),
              _Chapters(course: course, provider: p),
              _sectionTitle(context, 'Quizzes'),
              SliverToBoxAdapter(child: QuizListForCourse(courseId: course.id)),
              _sectionTitle(context, 'Reviews'),
              _Reviews(provider: p),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _sectionTitle(BuildContext context, String text) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(text, style: Theme.of(context).textTheme.titleLarge),
        ),
      );
}

/// Collapsing app bar with name, teacher and rating.
class _Header extends StatelessWidget {
  const _Header({required this.course, required this.provider});

  final CourseDetail course;
  final CourseDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rating = provider.rating;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      title: Text(course.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.name,
                style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                course.teacherName.isEmpty ? 'EnglishMaster' : 'By ${course.teacherName}',
                style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  RatingStars(rating: rating.average, color: scheme.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    rating.total == 0 ? 'No reviews yet' : '${rating.average.toStringAsFixed(1)} (${rating.total})',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onPrimary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable chapters; completion checks load when a chapter is opened.
class _Chapters extends StatelessWidget {
  const _Chapters({required this.course, required this.provider});

  final CourseDetail course;
  final CourseDetailProvider provider;

  @override
  Widget build(BuildContext context) {
    final groups = [
      for (final c in course.chapters) (c.name, c.videos),
      if (course.orphanVideos.isNotEmpty) ('Other lessons', course.orphanVideos),
    ];
    if (groups.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('No lessons yet.')),
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
              onExpansionChanged: (open) {
                if (open) provider.loadProgressFor(videos);
              },
              title: Text(name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text('${videos.length} lesson${videos.length == 1 ? '' : 's'}'),
              children: [
                for (final v in videos) _VideoTile(video: v, provider: provider),
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
        color: done ? Colors.green : Theme.of(context).colorScheme.primary,
      ),
      title: Text(video.name),
      trailing: video.isPreview ? const Chip(label: Text('Free'), visualDensity: VisualDensity.compact) : null,
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute<bool>(
          builder: (_) => VideoLessonScreen(videoId: video.id, title: video.name),
        ));
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
    return SliverList.list(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final sent = await showDialog<bool>(
                context: context,
                builder: (_) => FeedbackDialog(provider: provider),
              );
              if (sent == true) messenger.showSnackBar(const SnackBar(content: Text('Thanks for your review!')));
            },
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Write a review'),
          ),
        ),
      ),
      if (feedbacks.isEmpty)
        const Padding(padding: EdgeInsets.all(16), child: Text('Be the first to review this course.')),
      for (final f in feedbacks)
        ListTile(
          leading: CircleAvatar(child: Text(f.username.isEmpty ? '?' : f.username.substring(0, 1).toUpperCase())),
          title: Row(
            children: [
              Flexible(child: Text(f.username, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              RatingStars(rating: f.rating.toDouble(), size: 14),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((f.comment ?? '').trim().isNotEmpty) Text(f.comment!),
              if (f.createdAt != null)
                Text(DateFormat.yMMMd().format(f.createdAt!.toLocal()), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
    ]);
  }
}
