import '../../../../core/theme/app_palette.dart';

import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_outlined_button.dart';
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
                for (final question in prompt.questions)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AiExamStrings.question(question.id),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(question.content),
                          const SizedBox(height: 12),
                          if (question.type == 1)
                            for (final option in question.options)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Semantics(
                                  selected:
                                      state.answerFor(question.id) == option,
                                  child: ChunkyOutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          state.answerFor(question.id) == option
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                          : null,
                                      minimumSize: const Size.fromHeight(48),
                                      alignment: Alignment.centerLeft,
                                    ),
                                    onPressed: state.busy
                                        ? null
                                        : () => state.setAnswer(
                                            question.id,
                                            option,
                                          ),
                                    icon: Icon(
                                      state.answerFor(question.id) == option
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                    ),
                                    label: Text(option),
                                  ),
                                ),
                              )
                          else
                            TextFormField(
                              key: ValueKey('${prompt.id}-${question.id}'),
                              initialValue: state.answerFor(question.id),
                              readOnly: state.busy,
                              decoration: const InputDecoration(
                                labelText: AiExamStrings.answerHint,
                              ),
                              onChanged: (value) =>
                                  state.setAnswer(question.id, value),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              if (state.result case final result?) ...[
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 36,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AiExamStrings.listeningScore(
                            result.score,
                            result.total,
                          ),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: result.total == 0
                              ? 0
                              : (result.score / result.total).clamp(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final answer in result.results)
                  Card(
                    child: ListTile(
                      isThreeLine: true,
                      leading: Icon(
                        answer.isCorrect
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: answer.isCorrect
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        '${AiExamStrings.question(answer.id)} · ${answer.isCorrect ? AiExamStrings.correct : AiExamStrings.incorrect}\n${answer.content}',
                      ),
                      subtitle: Text(
                        '${AiExamStrings.yourAnswer(answer.userAnswer.isEmpty ? AiExamStrings.noAnswer : answer.userAnswer)}\n${AiExamStrings.correctAnswer(answer.correctAnswer)}',
                      ),
                    ),
                  ),
                if (result.script.isNotEmpty)
                  ExpansionTile(
                    title: const Text(AiExamStrings.script),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [SelectableText(result.script)],
                  ),
              ],
            ],
          ],
        ),
      ),
    ),
  );
}
