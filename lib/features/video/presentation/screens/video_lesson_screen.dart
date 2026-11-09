import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_button.dart';

import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../membership/presentation/widgets/upgrade_membership_banner.dart';

import 'package:video_player/video_player.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/video_repository.dart';
import '../providers/video_lesson_provider.dart';

/// Plays one lesson video (16:9 player, title, "Mark as completed").
///
/// Progress is saved every [saveInterval] while playing and once more when
/// the screen closes; playback resumes from the last saved position.
/// Pops with `true` so the caller can refresh its completion flags.
class VideoLessonScreen extends StatelessWidget {
  const VideoLessonScreen({super.key, required this.videoId, this.title});

  final int videoId;

  /// Title shown in the app bar until the real name is loaded.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          VideoLessonProvider(ctx.read<VideoRepository>(), videoId),
      child: _VideoLessonBody(title: title),
    );
  }
}

class _VideoLessonBody extends StatefulWidget {
  const _VideoLessonBody({this.title});

  final String? title;

  @override
  State<_VideoLessonBody> createState() => _VideoLessonBodyState();
}

/// How often the watch position is sent to the server.
const Duration saveInterval = Duration(seconds: 15);

class _VideoLessonBodyState extends State<_VideoLessonBody> {
  late final VideoLessonProvider _provider;
  VideoPlayerController? _controller;
  ChewieController? _chewie;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _provider = context.read<VideoLessonProvider>();
    _start();
  }

  /// Loads metadata, then prepares the player; any failure becomes an error view.
  Future<void> _start() async {
    await _provider.load();
    final video = _provider.video;
    if (!mounted || _provider.status != ViewStatus.success || video == null) {
      return;
    }
    try {
      final uri = Uri.parse(video.url.trim());
      if (!uri.hasScheme || !(uri.scheme == 'http' || uri.scheme == 'https')) {
        throw const FormatException(AppStrings.invalidVideoAddress);
      }
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;
      await controller.initialize();
      if (!mounted) return;
      final resume = Duration(seconds: _provider.resumePositionSec);
      if (resume > Duration.zero &&
          resume < controller.value.duration - const Duration(seconds: 2)) {
        await controller.seekTo(resume);
      }
      _chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        optionsTranslation: OptionsTranslation(
          playbackSpeedButtonText: AppStrings.playbackSpeed,
          subtitlesButtonText: AppStrings.subtitles,
          cancelButtonText: AppStrings.cancel,
          qualityButtonText: AppStrings.videoQuality,
        ),
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        errorBuilder: (_, message) => const MessageView(
          icon: Icons.error_outline,
          message: AppStrings.videoPlaybackError,
        ),
      );
      _timer = Timer.periodic(saveInterval, (_) {
        if (controller.value.isPlaying) _save();
      });
      setState(() {});
    } catch (_) {
      if (mounted) {
        _provider.reportPlaybackError(AppStrings.videoPlaybackError);
      }
    }
  }

  /// Sends the current position to the API (no-op until the player is ready).
  Future<void> _save({bool markCompleted = false}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final total = controller.value.duration.inSeconds;
    var position = controller.value.position.inSeconds;
    if (markCompleted) position = total;
    await _provider.saveProgress(
      positionSec: position,
      totalSec: total,
      markCompleted: markCompleted,
    );
  }

  Future<void> _markCompleted() async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _save(markCompleted: true)
        .then((_) => _provider.isCompleted);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? AppStrings.lessonCompleted : AppStrings.progressSaveError,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      // Fire-and-forget final save before the controller is released.
      _provider.saveProgress(
        positionSec: controller.value.position.inSeconds,
        totalSec: controller.value.duration.inSeconds,
      );
    }
    _chewie?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoLessonProvider>();
    final theme = Theme.of(context);
    final video = provider.video;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        await _save();
        navigator.pop(true);
      },
      child: Scaffold(
        appBar: AppTopBar(
          title: Text(video?.name ?? widget.title ?? AppStrings.lesson),
        ),
        body: provider.needsMembership
            ? _LockedLesson(message: provider.error)
            : AsyncView(
                status: provider.status,
                error: provider.error,
                onRetry: () {
                  _disposePlayer();
                  _start();
                },
                builder: (context) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _chewie == null
                              ? const Center(child: CircularProgressIndicator())
                              : Chewie(controller: _chewie!),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video?.name ?? '',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          if (video?.isPreview ?? false)
                            const Chip(
                              label: Text(AppStrings.freePreview),
                              visualDensity: VisualDensity.compact,
                            ),
                          const SizedBox(height: 16),
                          provider.isCompleted
                              ? FilledButton.tonalIcon(
                                  onPressed: null,
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                  label: const Text(AppStrings.completed),
                                )
                              : ChunkyButton.icon(
                                  onPressed: _chewie == null
                                      ? null
                                      : _markCompleted,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text(AppStrings.markCompleted),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _disposePlayer() {
    _timer?.cancel();
    _chewie?.dispose();
    _controller?.dispose();
    _chewie = null;
    _controller = null;
  }
}

/// Shown instead of the player when the lesson is premium and the user has no membership.
class _LockedLesson extends StatelessWidget {
  const _LockedLesson({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            if (message != null) Text(message!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const UpgradeMembershipBanner(),
          ],
        ),
      ),
    );
  }
}
