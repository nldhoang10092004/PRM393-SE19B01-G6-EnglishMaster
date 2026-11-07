import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';

/// Audio controls supporting local recordings, remote chunks and encoded audio.
class AiExamAudioPlayer extends StatefulWidget {
  const AiExamAudioPlayer({
    super.key,
    required this.audio,
    this.localFile = false,
  });
  final String audio;
  final bool localFile;

  @override
  State<AiExamAudioPlayer> createState() => _AiExamAudioPlayerState();
}

class _AiExamAudioPlayerState extends State<AiExamAudioPlayer> {
  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Duration _duration = Duration.zero, _position = Duration.zero;
  bool _playing = false, _busy = false, _loaded = false;
  String? _error;
  int _index = 0;

  List<String> get _parts =>
      widget.localFile || widget.audio.startsWith('data:')
      ? [widget.audio]
      : widget.audio
            .split(RegExp(r',(?=\s*https?://)'))
            .map((s) => s.trim())
            .toList();

  AudioPlayer _ensurePlayer() {
    if (_player != null) return _player!;
    final player = _player = AudioPlayer();
    _subscriptions.addAll([
      player.onDurationChanged.listen((value) {
        if (mounted) setState(() => _duration = value);
      }),
      player.onPositionChanged.listen((value) {
        if (mounted) setState(() => _position = value);
      }),
      player.onPlayerStateChanged.listen((value) {
        if (mounted) setState(() => _playing = value == PlayerState.playing);
      }),
      player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        _loaded = false;
        if (_index + 1 < _parts.length) {
          unawaited(_changePart(_index + 1));
        } else {
          setState(() {
            _playing = false;
            _position = Duration.zero;
          });
        }
      }),
    ]);
    return player;
  }

  Source _source() {
    final part = _parts[_index];
    if (widget.localFile) return DeviceFileSource(part);
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

  Future<void> _operate(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (_) {
      _loaded = false;
      if (mounted) setState(() => _error = AiExamStrings.audioError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle() => _operate(() async {
    final player = _ensurePlayer();
    if (_playing) {
      await player.pause();
    } else if (_loaded) {
      await player.resume();
    } else {
      await player.play(_source());
      _loaded = true;
    }
  });

  Future<void> _changePart(int index) => _operate(() async {
    final player = _ensurePlayer();
    await player.stop();
    if (!mounted) return;
    setState(() {
      _index = index;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    _loaded = false;
    await player.play(_source());
    _loaded = true;
  });

  @override
  void didUpdateWidget(covariant AiExamAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio != widget.audio ||
        oldWidget.localFile != widget.localFile) {
      // Screens key this widget by source, so each exercise owns a fresh player.
      _index = 0;
      _duration = _position = Duration.zero;
      _loaded = false;
      final player = _player;
      if (player != null) unawaited(player.stop().catchError((Object _) {}));
    }
  }

  String _time(Duration duration) =>
      '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final maximum = _duration.inMilliseconds.toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: _busy ? null : _toggle,
                  tooltip: _playing ? AiExamStrings.pause : AiExamStrings.play,
                  icon: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${_time(_position)} / ${_time(_duration)}'),
                ),
                if (_busy)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            Semantics(
              label: AiExamStrings.seek,
              child: Slider(
                value: _position.inMilliseconds.toDouble().clamp(
                  0.0,
                  maximum > 0 ? maximum : 1,
                ),
                max: maximum > 0 ? maximum : 1,
                onChanged: maximum <= 0 || _busy
                    ? null
                    : (value) {
                        setState(
                          () =>
                              _position = Duration(milliseconds: value.round()),
                        );
                      },
                onChangeEnd: maximum <= 0 || _busy
                    ? null
                    : (value) => _operate(() async {
                        await _ensurePlayer().seek(
                          Duration(milliseconds: value.round()),
                        );
                      }),
              ),
            ),
            if (_parts.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: AiExamStrings.previousAudio,
                    onPressed: _busy || _index == 0
                        ? null
                        : () => _changePart(_index - 1),
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  Text(AiExamStrings.audioPart(_index + 1, _parts.length)),
                  IconButton(
                    tooltip: AiExamStrings.nextAudio,
                    onPressed: _busy || _index + 1 == _parts.length
                        ? null
                        : () => _changePart(_index + 1),
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                ],
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    final player = _player;
    if (player != null) unawaited(player.dispose().catchError((Object _) {}));
    super.dispose();
  }
}
