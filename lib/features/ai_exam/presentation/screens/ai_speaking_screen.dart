import '../../../../core/theme/app_palette.dart';

import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_button.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ai_exam_strings.dart';
import '../../data/ai_exam_repository.dart';
import '../providers/ai_exam_provider.dart';
import '../widgets/ai_exam_audio_player.dart';
import '../widgets/ai_exam_body.dart';
import '../widgets/ai_generating_view.dart';
import '../widgets/ai_prompt_card.dart';
import '../widgets/ai_score_card.dart';

/// Speaking exercise with native recording, live levels, playback and AI grading.
class AiSpeakingScreen extends StatelessWidget {
  const AiSpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AiSpeakingProvider(context.read<AiExamRepository>())..generate(),
    child: const _SpeakingView(),
  );
}

class _SpeakingView extends StatefulWidget {
  const _SpeakingView();
  @override
  State<_SpeakingView> createState() => _SpeakingViewState();
}

class _SpeakingViewState extends State<_SpeakingView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final state = context.read<AiSpeakingProvider>();
    if (lifecycle != AppLifecycleState.resumed && state.recording) {
      unawaited(state.toggleRecording());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AiSpeakingProvider>();
    final seconds = state.elapsed.inSeconds;
    final time =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      appBar: AppTopBar(
        title: Text(
          state.result == null
              ? AiExamStrings.speaking
              : AiExamStrings.speakingResult,
        ),
      ),
      body: AiExamBody(
        status: state.status,
        error: state.error,
        hasPrompt: state.prompt != null,
        busy: state.busy,
        canGenerate: state.canGenerate,
        onGenerate: state.generate,
        kind: AiGeneratingKind.speaking,
        hasResult: state.result != null,
        generating: state.generating,
        grading: state.grading,
        footer: state.result != null
            ? ChunkyButton(
                onPressed: state.canGenerate ? state.generate : null,
                child: const Text(AiExamStrings.practiceAgain),
              )
            : state.prompt != null
            ? ChunkyButton(
                onPressed: state.canSubmit ? state.submit : null,
                child: const Text(AiExamStrings.submit),
              )
            : null,
        children: [
          if (state.prompt case final prompt?) ...[
            if (state.result == null)
              AiPromptCard(
                title: prompt.title,
                content: prompt.content,
                colors: AppPalette.of(context).speaking,
              ),
            const SizedBox(height: 16),
            if (state.result == null)
              const Text(
                AiExamStrings.recordingHint,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            if (state.result == null) ...[
              Center(
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: AiExamStrings.level((state.level * 100).round()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(21, (index) {
                    final height = 6 + state.level * (12 + (index % 5) * 7);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: height,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Tooltip(
                  message: state.recording
                      ? AiExamStrings.stopRecording
                      : state.audioPath == null
                      ? AiExamStrings.startRecording
                      : AiExamStrings.recordAgain,
                  child: ChunkyButton(
                    radius: 48,
                    style: FilledButton.styleFrom(
                      fixedSize: const Size(96, 96),
                      minimumSize: const Size(96, 96),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: state.busy ? null : state.toggleRecording,
                    child: Icon(
                      state.recording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (state.audioPath case final path?)
              if (!state.recording && !state.busy)
                AiExamAudioPlayer(
                  controller: state.audio,
                  audio: path,
                  localFile: true,
                ),
            if (state.result case final result?) ...[
              const SizedBox(height: 16),
              AiScoreCard(
                score: result,
                colors: AppPalette.of(context).speaking,
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
