import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../data/models/ai_exam.dart';
import '../providers/ai_exam_provider.dart';

/// Answer cards for listening/reading questions (multiple choice or short text).
class AiQuestionCards extends StatelessWidget {
  const AiQuestionCards({super.key, required this.state});
  final AiListeningProvider state;

  @override
  Widget build(BuildContext context) {
    final prompt = state.prompt!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                          selected: state.answerFor(question.id) == option,
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
                                : () => state.setAnswer(question.id, option),
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
                      onChanged: (value) => state.setAnswer(question.id, value),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Score summary, per-question review and the source text after grading.
class AiAnswerReview extends StatelessWidget {
  const AiAnswerReview({
    super.key,
    required this.result,
    required this.sourceLabel,
  });
  final AiListeningResult result;
  final String sourceLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: scheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 36,
                  color: scheme.onSecondaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  AiExamStrings.listeningScore(result.score, result.total),
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
                color: answer.isCorrect ? scheme.primary : scheme.error,
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
            title: Text(sourceLabel),
            childrenPadding: const EdgeInsets.all(16),
            children: [SelectableText(result.script)],
          ),
      ],
    );
  }
}
