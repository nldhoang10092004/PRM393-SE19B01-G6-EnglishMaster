import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../data/ai_exam_audio_controller.dart';

/// Compact controls for a provider-owned [AiExamAudioController]. The widget
/// holds no player, so it can be disposed/rebuilt freely (scrolling, route
/// transitions) without interrupting or reloading playback.
class AiExamAudioPlayer extends StatefulWidget {
  const AiExamAudioPlayer({
    super.key,
    required this.controller,
    required this.audio,
    this.localFile = false,
  });
  final AiExamAudioController controller;
  final String audio;
  final bool localFile;

  @override
  State<AiExamAudioPlayer> createState() => _AiExamAudioPlayerState();
}

class _AiExamAudioPlayerState extends State<AiExamAudioPlayer> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AiExamAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio != widget.audio ||
        oldWidget.localFile != widget.localFile ||
        oldWidget.controller != widget.controller) {
      _load();
    }
  }

  // Deferred so the controller's notifications never fire during a build.
  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    widget.controller.load(widget.audio, local: widget.localFile);
  });

  String _time(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final c = widget.controller;
      final maximum = c.duration.inMilliseconds.toDouble();
      final canSeek = maximum > 0 && !c.busy;
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: canSeek ? c.rewind : null,
                    tooltip: AiExamStrings.rewind10,
                    icon: const Icon(Icons.replay_10_rounded),
                  ),
                  IconButton.filledTonal(
                    onPressed: c.busy ? null : c.toggle,
                    tooltip: c.playing
                        ? AiExamStrings.pause
                        : AiExamStrings.play,
                    icon: c.busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            c.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                  ),
                  Expanded(
                    child: Semantics(
                      label: AiExamStrings.seek,
                      child: Slider(
                        value: c.position.inMilliseconds.toDouble().clamp(
                          0.0,
                          maximum > 0 ? maximum : 1,
                        ),
                        max: maximum > 0 ? maximum : 1,
                        onChanged: canSeek
                            ? (v) => c.previewSeek(
                                Duration(milliseconds: v.round()),
                              )
                            : null,
                        onChangeEnd: canSeek
                            ? (v) => c.seek(Duration(milliseconds: v.round()))
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    '${_time(c.position)} / ${_time(c.duration)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              if (c.busy && c.position == Duration.zero && !c.playing)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    AiExamStrings.audioLoading,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              if (c.partCount > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: AiExamStrings.previousAudio,
                      onPressed: c.busy || c.index == 0
                          ? null
                          : () => c.changePart(c.index - 1),
                      icon: const Icon(Icons.skip_previous_rounded),
                    ),
                    Text(AiExamStrings.audioPart(c.index + 1, c.partCount)),
                    IconButton(
                      tooltip: AiExamStrings.nextAudio,
                      onPressed: c.busy || c.index + 1 == c.partCount
                          ? null
                          : () => c.changePart(c.index + 1),
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
              if (c.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    c.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
