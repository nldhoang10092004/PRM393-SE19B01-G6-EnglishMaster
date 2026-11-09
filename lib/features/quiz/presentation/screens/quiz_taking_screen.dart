import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';

import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/theme/app_palette.dart';
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
        title: const Text(AppStrings.confirmSubmit),
        content: Text(
          AppStrings.submitSummary(state.answeredCount, state.questions.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.keepReviewing),
          ),
          ChunkyButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.submit),
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
            title: const Text(AppStrings.confirmLeave),
            content: const Text(AppStrings.leaveQuizHint),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.stay),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(AppStrings.leave),
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
        appBar: AppTopBar(title: Text(state.quiz?.title ?? AppStrings.quiz)),
        body: question == null
            ? const MessageView(
                icon: Icons.quiz_outlined,
                message: AppStrings.noQuestions,
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: (state.index + 1) / state.questions.length,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.questionProgress(
                            state.index + 1,
                            state.questions.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.currentGroup != null ||
                      question.assets.any((a) => a.isAudio))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        key: const Key('pinned_listening_player'),
                        children: [
                          for (final asset in [
                            ...?state.currentGroup?.assets,
                            ...question.assets,
                          ].where((a) => a.isAudio && a.url.trim().isNotEmpty))
                            QuizAssetView(
                              key: ValueKey('pinned-audio-${asset.id}'),
                              asset: asset,
                              audio: state.audioFor(asset),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: readablePadding(context, top: 0, bottom: 0),
                      children: [
                        if (state.currentGroup != null) ...[
                          if (state.currentGroup!.instruction.isNotEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(state.currentGroup!.instruction),
                              ),
                            ),
                          ...state.currentGroup!.assets
                              .where((a) => !a.isAudio || a.url.trim().isEmpty)
                              .map(
                                (asset) => QuizAssetView(
                                  key: ValueKey('group-${asset.id}'),
                                  asset: asset,
                                ),
                              ),
                        ],
                        Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: const RoundedRectangleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              question.content,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        ...question.assets
                            .where((a) => !a.isAudio)
                            .map(
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
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Semantics(
                                selected: selected,
                                button: true,
                                child: ChunkyOutlinedButton(
                                  key: ValueKey('option-${option.id}'),
                                  style: OutlinedButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                    backgroundColor: selected
                                        ? AppPalette.of(context).primarySoft
                                        : AppPalette.of(context).surface,
                                    foregroundColor: selected
                                        ? AppPalette.of(context).onPrimarySoft
                                        : AppPalette.of(context).ink,
                                    side: BorderSide(
                                      color: selected
                                          ? AppPalette.of(context).primary
                                          : AppPalette.of(context).outline,
                                      width: 2,
                                    ),
                                  ),
                                  onPressed: state.busy
                                      ? null
                                      : () => state.select(option.id),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppPalette.of(context).primary
                                              : AppPalette.of(context).muted,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          String.fromCharCode(
                                            65 +
                                                question.options.indexOf(
                                                  option,
                                                ),
                                          ),
                                          style: TextStyle(
                                            color: selected
                                                ? AppPalette.of(context)
                                                      .onPrimary
                                                : AppPalette.of(context).ink,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(option.content)),
                                    ],
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
                              labelText: AppStrings.yourAnswer,
                            ),
                            onChanged: state.answerText,
                          ),
                        if (question.isChoice && question.options.isEmpty)
                          const Text(AppStrings.noOptions),
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
                            ChunkyOutlinedButton(
                              onPressed: state.busy ? null : state.previous,
                              child: const Text(AppStrings.previous),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ChunkyButton(
                              key: const Key('quiz_next_submit'),
                              onPressed: state.busy
                                  ? null
                                  : state.isLast
                                  ? () => _submit(state)
                                  : state.next,
                              child: Text(
                                state.busy
                                    ? AppStrings.submitting
                                    : state.isLast
                                    ? AppStrings.submitQuiz
                                    : AppStrings.next,
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
