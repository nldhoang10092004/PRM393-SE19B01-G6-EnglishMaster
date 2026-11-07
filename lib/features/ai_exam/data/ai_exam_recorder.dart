import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/network/api_exception.dart';
import '../ai_exam_strings.dart';

/// Owns temporary recordings; no file outside this instance's paths is removed.
class AiExamRecorder {
  AudioRecorder? _recorder;
  final Set<String> _paths = {};

  /// Requests runtime microphone permission and records mono AAC audio.
  Future<void> start() async {
    final recorder = _recorder ??= AudioRecorder();
    if (!await recorder.hasPermission()) {
      throw ApiException(AiExamStrings.microphoneDenied);
    }
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/ai_exam_${DateTime.now().microsecondsSinceEpoch}.m4a';
    _paths.add(path);
    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
  }

  /// Produces normalized dB amplitude values for the level meter.
  Stream<double> get levels => _recorder!
      .onAmplitudeChanged(const Duration(milliseconds: 150))
      .map(
        (value) => value.current.isFinite
            ? ((value.current + 60) / 60).clamp(0.0, 1.0)
            : 0.0,
      );

  /// Stops capture, keeping the local file for playback and retries.
  Future<String?> stop() async => _recorder?.stop();

  /// Cancels capture, releases the microphone, and deletes owned temporary files.
  Future<void> dispose() async {
    final recorder = _recorder;
    _recorder = null;
    if (recorder != null) {
      try {
        await recorder.cancel();
      } catch (_) {
        /* Best-effort cancellation. */
      }
      try {
        await recorder.dispose();
      } catch (_) {
        /* Platform may already be closed. */
      }
    }
    for (final path in _paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        /* Temporary files can also be reclaimed by the OS. */
      }
    }
    _paths.clear();
  }
}
