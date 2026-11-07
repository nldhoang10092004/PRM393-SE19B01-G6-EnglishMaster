import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../providers/quiz_provider.dart';

/// Server score, correct/total counts and expandable submitted-answer review.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizTakingProvider>();
    final result = state.result!;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.quizResult)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: (result.score / 100).clamp(0, 1),
                      strokeWidth: 10,
                    ),
                  ),
                  Text(
                    AppStrings.percentage(result.score),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.correctCount(result.correct, result.total),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
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
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.backToQuizzes),
          ),
        ],
      ),
    );
  }
}
