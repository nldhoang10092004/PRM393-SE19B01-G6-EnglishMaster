import '../../../../core/theme/app_palette.dart';

import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ai_exam_strings.dart';
import '../../data/ai_exam_repository.dart';
import '../providers/ai_exam_provider.dart';
import '../widgets/ai_exam_audio_player.dart';
import '../widgets/ai_exam_body.dart';
import '../widgets/ai_generating_view.dart';
import '../widgets/ai_prompt_card.dart';
import '../widgets/ai_question_views.dart';

/// Generated listening audio, mixed choice/text answers and server answer review.
class AiListeningScreen extends StatelessWidget {
  const AiListeningScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AiListeningProvider(context.read<AiExamRepository>())..generate(),
    child: Consumer<AiListeningProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: AppTopBar(
          title: Text(
            state.result == null
                ? AiExamStrings.listening
                : AiExamStrings.listeningResult,
          ),
        ),
        body: AiExamBody(
          status: state.status,
          error: state.error,
          hasPrompt: state.prompt != null,
          busy: state.busy,
          canGenerate: state.canGenerate,
          onGenerate: state.generate,
          kind: AiGeneratingKind.listening,
          hasResult: state.result != null,
          generating: state.generating,
          grading: state.grading,
          pinned: state.prompt == null
              ? null
              : AiExamAudioPlayer(
                  controller: state.audio,
                  audio: state.prompt!.audioUrl,
                ),
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
              AiPromptCard(
                title: prompt.title,
                content: '',
                colors: AppPalette.of(context).listening,
              ),
              const SizedBox(height: 16),
              if (state.result == null) ...[
                AiQuestionCards(state: state),
                const SizedBox(height: 16),
              ],
              if (state.result case final result?)
                AiAnswerReview(
                  result: result,
                  sourceLabel: AiExamStrings.script,
                ),
            ],
          ],
        ),
      ),
    ),
  );
}
