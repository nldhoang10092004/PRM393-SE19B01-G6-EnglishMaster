import '../../../../core/widgets/chunky_outlined_button.dart';
import '../../../../core/theme/app_palette.dart';

import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../providers/quiz_provider.dart';

/// Server score, correct/total counts and expandable submitted-answer review.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizTakingProvider>();
    final result = state.result!;
    return Scaffold(
      appBar: const AppTopBar(title: Text(AppStrings.quizResult)),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: ChunkyOutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    AppStrings.backToQuizzes,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChunkyButton(
                  onPressed: state.busy
                      ? null
                      : () async {
                          final id = state.quiz?.id;
                          if (id == null) return;
                          await state.load(id);
                          if (context.mounted) await state.start();
                        },
                  child: const Text(AppStrings.retry),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ScoreRing(
            fraction: result.score / 100,
            label: AppStrings.percentage(result.score),
            subtitle: AppStrings.correctCount(result.correct, result.total),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.wellDone,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (state.quiz != null)
            Text(
              state.quiz!.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: result.correct.toString(),
                  label: AppStrings.correctAnswers,
                  colors: AppPalette.of(context).listening,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: result.wrong.toString(),
                  label: AppStrings.wrongAnswers,
                  colors: AppPalette.of(context).speaking,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: result.pending.toString(),
                  label: AppStrings.pendingAnswers,
                  icon: Icons.hourglass_empty_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.pendingCount(result.wrong, result.pending),
            textAlign: TextAlign.center,
          ),
          if (result.status == 'PENDING_REVIEW')
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(AppStrings.pendingScoreHint),
            ),
          const SizedBox(height: 24),
          ExpansionTile(
            title: const Text(AppStrings.reviewAnswers),
            children: List.generate(result.results.length, (index) {
              final answer = result.results[index];
              final question = state.questions
                  .where((q) => q.id == answer.questionId)
                  .firstOrNull;
              final selectedText = question?.options
                  .where((o) => o.id == answer.submittedOptionId)
                  .firstOrNull
                  ?.content;
              final correction = [
                ...answer.correctOptions.map((o) => o.content),
                if (answer.correctText.isNotEmpty) answer.correctText,
              ].join(AppStrings.answerSeparator);
              return ListTile(
                leading: Icon(
                  answer.isCorrect == null
                      ? Icons.hourglass_empty
                      : answer.isCorrect!
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                ),
                title: Text(answer.content),
                subtitle: Text(
                  AppStrings.answerReview(
                    selectedText ??
                        (answer.submittedText.isEmpty
                            ? AppStrings.unanswered
                            : answer.submittedText),
                    correction,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
