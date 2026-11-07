import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../data/models/quiz.dart';

/// Renders passages and images, with guarded audio playback and URL fallback.
class QuizAssetView extends StatefulWidget {
  const QuizAssetView({super.key, required this.asset});
  final QuizAsset asset;
  @override
  State<QuizAssetView> createState() => _QuizAssetViewState();
}

class _QuizAssetViewState extends State<QuizAssetView> {
  VideoPlayerController? _audio;
  String? _error;
  bool _loading = false;

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
      _audio?.dispose();
      _audio = null;
      _error = null;
      _loading = false;
    }
  }

  Future<void> _toggleAudio() async {
    if (_uri == null || _loading) return;
    try {
      if (_audio == null) {
        setState(() {
          _loading = true;
          _error = null;
        });
        final controller = VideoPlayerController.networkUrl(_uri!);
        _audio = controller;
        await controller.initialize();
        if (!mounted || _audio != controller) return;
        controller.addListener(_audioChanged);
      }
      if (!mounted) return;
      if (_audio!.value.isPlaying) {
        await _audio!.pause();
      } else {
        if (_audio!.value.position >= _audio!.value.duration) {
          await _audio!.seekTo(Duration.zero);
        }
        await _audio!.play();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppStrings.audioUnavailable);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _audioChanged() {
    if (mounted) {
      setState(() {
        if (_audio?.value.hasError ?? false) {
          _error = AppStrings.audioPlaybackError;
        }
      });
    }
  }

  @override
  void dispose() {
    _audio?.removeListener(_audioChanged);
    _audio?.dispose();
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
                child: Image.network(
                  uri.toString(),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
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

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final uri = _uri;
    return Card(
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
                child: Image.network(
                  uri.toString(),
                  height: 200,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          height: 80,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, _, _) =>
                      const Text(AppStrings.imageUnavailable),
                ),
              ),
            if (asset.isAudio && uri != null)
              OutlinedButton.icon(
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
    );
  }
}
