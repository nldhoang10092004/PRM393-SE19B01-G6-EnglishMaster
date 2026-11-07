import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_audio_controller.dart';
import 'package:english_master/features/ai_exam/data/ai_exam_repository.dart';
import 'package:english_master/features/ai_exam/data/models/ai_exam.dart';
import 'package:english_master/features/ai_exam/presentation/providers/ai_exam_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements AiExamRepository {}

class FakeAudioPlayer extends Fake implements AudioPlayer {
  final durations = StreamController<Duration>.broadcast();
  final positions = StreamController<Duration>.broadcast();
  final states = StreamController<PlayerState>.broadcast();
  final completes = StreamController<void>.broadcast();
  final sources = <Source>[];
  var plays = 0, resumes = 0, pauses = 0, disposes = 0;
  Duration? lastSeek;

  @override
  Stream<Duration> get onDurationChanged => durations.stream;
  @override
  Stream<Duration> get onPositionChanged => positions.stream;
  @override
  Stream<PlayerState> get onPlayerStateChanged => states.stream;
  @override
  Stream<void> get onPlayerComplete => completes.stream;
  @override
  Future<void> setSource(Source source) async => sources.add(source);
  @override
  Future<void> play(
    Source source, {
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    plays++;
    states.add(PlayerState.playing);
  }

  @override
  Future<void> resume() async {
    resumes++;
    states.add(PlayerState.playing);
  }

  @override
  Future<void> pause() async {
    pauses++;
    states.add(PlayerState.paused);
  }

  @override
  Future<void> stop() async {}
  @override
  Future<void> seek(Duration position) async => lastSeek = position;
  @override
  Future<void> dispose() async => disposes++;
}

const _prompt = AiExamPrompt(
  id: 3,
  title: 'Listening',
  content: '',
  audioUrl: 'https://cdn.example.com/a.mp3',
);

void main() {
  test('provider owns exactly one player for the whole exercise', () async {
    final players = <FakeAudioPlayer>[];
    final repository = _Repository();
    when(() => repository.generate(AiExamSkill.listening))
        .thenAnswer((_) async => _prompt);
    final state = AiListeningProvider(
      repository,
      audioPlayerFactory: () {
        final player = FakeAudioPlayer();
        players.add(player);
        return player;
      },
    );
    await state.generate();
    // Widgets may be disposed/recreated by lazy scrolling and request the
    // same source again; neither may create a second player or reload it.
    await state.audio.load(_prompt.audioUrl);
    await state.audio.load(_prompt.audioUrl);
    expect(players, hasLength(1));
    expect(players.single.sources, hasLength(1));
    expect(players.single.sources.single, isA<UrlSource>());
    expect(players.single.disposes, 0);

    await state.audio.toggle();
    expect(players.single.plays, 0);
    expect(players.single.resumes, 1, reason: 'preloaded source is resumed');
    expect(state.audio.playing, isTrue);

    await state.audio.load(_prompt.audioUrl);
    expect(players, hasLength(1));
    expect(state.audio.playing, isTrue);

    state.dispose();
    expect(players.single.disposes, 1);
  });

  test(
    'preloads with a buffering flag and supports pause/seek/rewind',
    () async {
      final player = FakeAudioPlayer();
      final controller = AiExamAudioController(playerFactory: () => player);
      final loading = controller.load('https://cdn.example.com/a.mp3');
      expect(controller.busy, isTrue);
      await loading;
      expect(controller.busy, isFalse);
      player.durations.add(const Duration(seconds: 60));
      player.positions.add(const Duration(seconds: 30));
      await Future<void>.delayed(Duration.zero);
      await controller.rewind();
      expect(player.lastSeek, const Duration(seconds: 20));
      await controller.toggle();
      await controller.toggle();
      expect(player.pauses, 1);
      controller.dispose();
    },
  );
}
