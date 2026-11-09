import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/quiz.dart';
import '../providers/quiz_audio_controller.dart';

/// Renders passages and images, with guarded audio playback and URL fallback.
class QuizAssetView extends StatefulWidget {
  const QuizAssetView({super.key, required this.asset, this.audio});
  final QuizAsset asset;
  final QuizAudioController? audio;
  @override
  State<QuizAssetView> createState() => _QuizAssetViewState();
}

class _QuizAssetViewState extends State<QuizAssetView> {
  QuizAudioController? _ownedAudio;
  QuizAudioController get _playback =>
      widget.audio ?? (_ownedAudio ??= QuizAudioController(widget.asset.url));
  VideoPlayerController? get _audio => _playback.player;
  String? get _error => _playback.error;
  bool get _loading => _playback.loading;

  Uri? get _uri {
    final raw = Uri.tryParse(widget.asset.url.trim());
    if (raw == null || widget.asset.url.trim().isEmpty) return null;
    final uri = raw.hasScheme
        ? raw
        : Uri.parse(AppConfig.apiBaseUrl).resolveUri(raw);
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty
        ? uri
        : null;
  }

  @override
  void didUpdateWidget(covariant QuizAssetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset.url != widget.asset.url) {
      _ownedAudio?.dispose();
      _ownedAudio = null;
    }
  }

  Future<void> _toggleAudio() => _playback.toggle();
  @override
  void dispose() {
    _ownedAudio?.dispose();
    super.dispose();
  }

  void _zoomImage(BuildContext context, Uri uri) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 5,
                // Full-screen zoom: reuses the disk-cached file.
                child: CachedNetworkImage(
                  imageUrl: uri.toString(),
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) =>
                      const Center(child: Text(AppStrings.imageUnavailable)),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: AppStrings.close,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seekBar(VideoPlayerController c) {
    final total = c.value.duration.inMilliseconds;
    final pos = c.value.position.inMilliseconds.clamp(0, total > 0 ? total : 0);
    String fmt(int ms) {
      final d = Duration(milliseconds: ms);
      return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    return Row(
      children: [
        Text(fmt(pos)),
        Expanded(
          child: Slider(
            value: pos.toDouble(),
            max: total > 0 ? total.toDouble() : 1,
            onChanged: total > 0
                ? (v) => c.seekTo(Duration(milliseconds: v.round()))
                : null,
          ),
        ),
        Text(fmt(total)),
      ],
    );
  }

  Widget _audioCard(BuildContext context) {
    final p = AppPalette.of(context);
    final t = Theme.of(context);
    final colors = p.listening;
    String time(Duration d) =>
        '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    return ListenableBuilder(
      listenable: _playback,
      builder: (context, _) {
        final c = _audio;
        final duration = c?.value.duration ?? Duration.zero;
        final position = c?.value.position ?? Duration.zero;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filled(
                    tooltip: _loading
                        ? AppStrings.loadingAudio
                        : c?.value.isPlaying == true
                        ? AppStrings.pauseAudio
                        : AppStrings.playAudio,
                    onPressed: _loading ? null : _toggleAudio,
                    style: IconButton.styleFrom(
                      backgroundColor: p.primary,
                      foregroundColor: p.onPrimary,
                      minimumSize: const Size(48, 48),
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(
                      c?.value.isPlaying == true
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.asset.caption.isEmpty
                              ? AppStrings.listeningQuiz
                              : widget.asset.caption,
                          style: t.textTheme.titleSmall?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                        if (c != null)
                          SizedBox(
                            height: 24,
                            child: Slider(
                              value: position.inMilliseconds.toDouble().clamp(
                                0,
                                duration.inMilliseconds > 0
                                    ? duration.inMilliseconds.toDouble()
                                    : 1,
                              ),
                              max: duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1,
                              onChanged: duration > Duration.zero
                                  ? (v) => c.seekTo(
                                      Duration(milliseconds: v.round()),
                                    )
                                  : null,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(
                              value: 0,
                              minHeight: 6,
                              backgroundColor: p.surface,
                            ),
                          ),
                        Text(
                          _loading
                              ? AppStrings.loadingAudio
                              : c == null
                              ? AppStrings.playAudio
                              : '${time(position)} / ${time(duration)}',
                          style: t.textTheme.bodySmall?.copyWith(
                            color: colors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: p.error)),
                SelectableText(
                  _uri.toString(),
                  style: t.textTheme.bodySmall?.copyWith(color: colors.ink),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final uri = _uri;
    if (asset.isAudio && uri != null && asset.text.isEmpty) {
      return _audioCard(context);
    }
    final colors = AppPalette.of(context).listening;
    return ListenableBuilder(
      listenable: _playback,
      builder: (context, _) => Card(
        color: asset.isAudio ? colors.background : null,
        shape: asset.isAudio
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))
            : null,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: asset.isAudio ? colors.ink : null),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (asset.caption.isNotEmpty)
                  Text(
                    asset.caption,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                if (asset.text.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          asset.text,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ),
                    ),
                  ),
                if (asset.isImage && uri != null)
                  GestureDetector(
                    onTap: () => _zoomImage(context, uri),
                    // Decoded at 200 px height + disk cache.
                    child: AppNetworkImage(
                      url: uri.toString(),
                      height: 200,
                      fit: BoxFit.contain,
                      placeholder: const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: const Text(AppStrings.imageUnavailable),
                    ),
                  ),
                if (asset.isAudio && uri != null)
                  ChunkyOutlinedButton.icon(
                    onPressed: _loading ? null : _toggleAudio,
                    icon: Icon(
                      _audio?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(
                      _loading
                          ? AppStrings.loadingAudio
                          : _audio?.value.isPlaying == true
                          ? AppStrings.pauseAudio
                          : AppStrings.playAudio,
                    ),
                  ),
                if (asset.isAudio && uri != null && _audio != null)
                  _seekBar(_audio!),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (asset.url.isNotEmpty &&
                    (uri == null ||
                        (!asset.isImage && !asset.isAudio) ||
                        _error != null))
                  SelectableText(
                    uri?.toString() ?? AppStrings.attachmentUnavailable,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
