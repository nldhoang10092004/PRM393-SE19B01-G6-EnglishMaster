import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';

/// Attempt-owned audio survives question navigation and scrolling.
class QuizAudioController extends ChangeNotifier {
  QuizAudioController(this.url);
  final String url;
  VideoPlayerController? player;
  bool loading = false;
  String? error;
  bool _disposed = false;

  /// Starts, pauses or retries the same attachment without recreating its player.
  Future<void> toggle() async {
    if (_disposed || loading) return;
    final raw = Uri.tryParse(url.trim());
    if (raw == null || url.trim().isEmpty) return;
    final uri = raw.hasScheme
        ? raw
        : Uri.parse(AppConfig.apiBaseUrl).resolveUri(raw);
    if ((uri.scheme != 'http' && uri.scheme != 'https') || uri.host.isEmpty) {
      return;
    }
    try {
      if (player == null) {
        loading = true;
        error = null;
        notifyListeners();
        final c = VideoPlayerController.networkUrl(uri);
        player = c;
        await c.initialize();
        if (_disposed || player != c) return;
        c.addListener(_changed);
      }
      if (_disposed) return;
      final c = player!;
      if (c.value.isPlaying) {
        await c.pause();
      } else {
        if (c.value.position >= c.value.duration) await c.seekTo(Duration.zero);
        await c.play();
      }
    } catch (_) {
      if (!_disposed) error = AppStrings.audioUnavailable;
    } finally {
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void _changed() {
    if (_disposed) return;
    if (player?.value.hasError ?? false) error = AppStrings.audioPlaybackError;
    notifyListeners();
  }

  /// Stops playback when an attempt is submitted or left.
  Future<void> pause() async {
    try {
      await player?.pause();
    } catch (_) {
      /* Already disposed by the platform. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    player?.removeListener(_changed);
    player?.dispose();
    super.dispose();
  }
}
