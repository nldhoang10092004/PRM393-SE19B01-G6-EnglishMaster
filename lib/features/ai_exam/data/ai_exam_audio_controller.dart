import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../ai_exam_strings.dart';

typedef AiAudioPlayerFactory = AudioPlayer Function();

/// Owns one [AudioPlayer] for a whole exercise so scrolling or rebuilding the
/// UI never disposes or reloads it. Supports local files, remote chunks
/// (comma separated URLs) and encoded audio. Dispose it when the screen closes.
class AiExamAudioController extends ChangeNotifier {
  AiExamAudioController({AiAudioPlayerFactory? playerFactory})
    : _factory = playerFactory ?? AudioPlayer.new;
  final AiAudioPlayerFactory _factory;

  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  String? _audio;
  bool _local = false, _disposed = false, _loaded = false;
  int _token = 0;
  List<String> _parts = const [];

  int index = 0;
  Duration duration = Duration.zero, position = Duration.zero;
  bool playing = false, busy = false;
  String? error;

  bool get hasSource => _audio != null;
  int get partCount => _parts.length;
  AudioPlayer? get player => _player;

  List<String> _split(String audio, bool local) =>
      local || audio.startsWith('data:')
      ? [audio]
      : audio.split(RegExp(r',(?=\s*https?://)')).map((s) => s.trim()).toList();

  AudioPlayer _ensurePlayer() {
    final existing = _player;
    if (existing != null) return existing;
    final player = _player = _factory();
    _subscriptions.addAll([
      player.onDurationChanged.listen((v) {
        duration = v;
        _notify();
      }),
      player.onPositionChanged.listen((v) {
        position = v;
        _notify();
      }),
      player.onPlayerStateChanged.listen((v) {
        playing = v == PlayerState.playing;
        _notify();
      }),
      player.onPlayerComplete.listen((_) {
        _loaded = false;
        if (index + 1 < _parts.length) {
          unawaited(changePart(index + 1));
        } else {
          playing = false;
          position = Duration.zero;
          _notify();
        }
      }),
    ]);
    return player;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Source _source() {
    final part = _parts[index];
    if (_local) return DeviceFileSource(part);
    final uri = Uri.tryParse(part);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return UrlSource(part);
    }
    if (part.startsWith('data:')) {
      final data = UriData.parse(part);
      return BytesSource(data.contentAsBytes(), mimeType: data.mimeType);
    }
    return BytesSource(base64Decode(part), mimeType: 'audio/mpeg');
  }

  /// Sets the source and preloads it. Calling again with the same source is a
  /// no-op, so widgets can safely request it on every (re)build.
  Future<void> load(String audio, {bool local = false}) async {
    if (_disposed || (audio == _audio && local == _local)) return;
    _audio = audio;
    _local = local;
    _parts = _split(audio, local);
    index = 0;
    position = duration = Duration.zero;
    playing = false;
    _loaded = false;
    error = null;
    final token = ++_token;
    final player = _ensurePlayer();
    busy = true;
    _notify();
    try {
      await player.stop();
      if (token != _token || _disposed) return;
      await player.setSource(_source());
      if (token == _token) _loaded = true;
    } catch (_) {
      // Preload is best effort: pressing play retries and reports failures.
      if (token == _token) _loaded = false;
    } finally {
      if (token == _token) {
        busy = false;
        _notify();
      }
    }
  }

  /// Forgets the current source (e.g. a recording that is being replaced).
  Future<void> clear() async {
    if (_audio == null) return;
    _token++;
    _audio = null;
    _parts = const [];
    _loaded = false;
    playing = false;
    busy = false;
    position = duration = Duration.zero;
    error = null;
    _notify();
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> _operate(Future<void> Function() action) async {
    if (busy || _disposed || _audio == null) return;
    busy = true;
    error = null;
    _notify();
    try {
      await action();
    } catch (_) {
      _loaded = false;
      error = AiExamStrings.audioError;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> toggle() => _operate(() async {
    final player = _ensurePlayer();
    if (playing) {
      await player.pause();
    } else if (_loaded) {
      await player.resume();
    } else {
      await player.play(_source());
      _loaded = true;
    }
  });

  Future<void> changePart(int next) => _operate(() async {
    final player = _ensurePlayer();
    await player.stop();
    index = next;
    position = duration = Duration.zero;
    _loaded = false;
    _notify();
    await player.play(_source());
    _loaded = true;
  });

  void previewSeek(Duration value) {
    position = value;
    _notify();
  }

  Future<void> seek(Duration value) => _operate(() async {
    final max = duration;
    final target = value < Duration.zero
        ? Duration.zero
        : (max > Duration.zero && value > max ? max : value);
    position = target;
    if (_loaded || playing) await _ensurePlayer().seek(target);
  });

  Future<void> rewind([Duration by = const Duration(seconds: 10)]) =>
      seek(position - by);

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _token++;
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    final player = _player;
    if (player != null) unawaited(player.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
