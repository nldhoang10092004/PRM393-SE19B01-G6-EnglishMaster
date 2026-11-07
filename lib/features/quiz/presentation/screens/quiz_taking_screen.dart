import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_asset_view.dart';
import 'quiz_result_screen.dart';

/// Single-choice attempt UI; obtains its route-scoped provider from detail.
class QuizTakingScreen extends StatefulWidget {
  const QuizTakingScreen({super.key});
  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  bool _allowExit = false;

  Future<void> _submit(QuizTakingProvider state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit quiz?'),
        content: Text(
          '${state.answeredCount} of ${state.questions.length} answered. Unanswered questions will be marked incorrect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep reviewing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await state.submit();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizTakingProvider>();
    if (state.result != null) return const QuizResultScreen();
    final question = state.current;
    return PopScope(
      canPop: _allowExit,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || state.busy) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave quiz?'),
            content: const Text(
              'Your attempt will remain unfinished. You can resume from the quiz detail while it is open.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          setState(() => _allowExit = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop();
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(state.quiz?.title ?? 'Quiz')),
        body: question == null
            ? const MessageView(
                icon: Icons.quiz_outlined,
                message: 'No questions available.',
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: (state.index + 1) / state.questions.length,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Question ${state.index + 1}/${state.questions.length}',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (state.currentGroup != null) ...[
                          if (state.currentGroup!.instruction.isNotEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(state.currentGroup!.instruction),
                              ),
                            ),
                          ...state.currentGroup!.assets.map(
                            (asset) => QuizAssetView(
                              key: ValueKey('group-${asset.id}'),
                              asset: asset,
                            ),
                          ),
                        ],
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              question.content,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        ...question.assets.map(
                          (asset) => QuizAssetView(
                            key: ValueKey(
                              'question-${question.id}-${asset.id}',
                            ),
                            asset: asset,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (question.isChoice)
                          ...question.options.map((option) {
                            final selected =
                                state.selected(question.id) == option.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Semantics(
                                selected: selected,
                                button: true,
                                child: Material(
                                  color: selected
                                      ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                      : Theme.of(context).colorScheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: selected
                                          ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                          : Theme.of(context)
                                                .colorScheme
                                                .outlineVariant,
                                    ),
                                  ),
                                  child: ListTile(
                                    key: ValueKey('option-${option.id}'),
                                    leading: Icon(
                                      selected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_off,
                                    ),
                                    title: Text(option.content),
                                    onTap: state.busy
                                        ? null
                                        : () => state.select(option.id),
                                  ),
                                ),
                              ),
                            );
                          })
                        else
                          TextFormField(
                            key: ValueKey('answer-${question.id}'),
                            initialValue: state.textAnswer(question.id),
                            enabled: !state.busy,
                            minLines: 2,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: 'Your answer',
                            ),
                            onChanged: state.answerText,
                          ),
                        if (question.isChoice && question.options.isEmpty)
                          const Text(
                            'No answer options are available for this question.',
                          ),
                      ],
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          if (state.index > 0) ...[
                            OutlinedButton(
                              onPressed: state.busy ? null : state.previous,
                              child: const Text('Previous'),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: FilledButton(
                              key: const Key('quiz_next_submit'),
                              onPressed: state.busy
                                  ? null
                                  : state.isLast
                                  ? () => _submit(state)
                                  : state.next,
                              child: Text(
                                state.busy
                                    ? 'Submitting…'
                                    : state.isLast
                                    ? 'Submit quiz'
                                    : 'Next',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
