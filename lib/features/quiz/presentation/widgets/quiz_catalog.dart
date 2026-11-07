import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../providers/quiz_provider.dart';
import '../screens/quiz_detail_screen.dart';

/// Shared quiz cards for a full list or an embedded course section.
class QuizCatalog extends StatelessWidget {
  const QuizCatalog({super.key, this.courseId, this.embedded = false});
  final int? courseId;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizProvider>();
    Future<void> refresh() async {
      await Future.wait([state.load(courseId: courseId), state.loadHistory()]);
    }

    return AsyncView(
      status: state.status,
      error: state.error,
      onRetry: refresh,
      builder: (_) {
        final list = state.quizzes.isEmpty
            ? (embedded
                  ? const MessageView(
                      icon: Icons.quiz_outlined,
                      message: AppStrings.noQuizzes,
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        MessageView(
                          icon: Icons.quiz_outlined,
                          message: AppStrings.noQuizzes,
                        ),
                      ],
                    ))
            : ListView.builder(
                shrinkWrap: embedded,
                physics: embedded
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = state.quizzes[index];
                  final best = state.bestScore(quiz.id);
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer,
                        child: Icon(
                          quiz.type == 1
                              ? Icons.headphones_outlined
                              : Icons.quiz_outlined,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        quiz.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.description.isEmpty
                                ? (quiz.type == 1
                                      ? AppStrings.listeningQuiz
                                      : AppStrings.practiceQuiz)
                                : quiz.description,
                          ),
                          if (best != null)
                            Chip(label: Text(AppStrings.bestScore(best))),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: quiz.isActive
                          ? () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      QuizDetailScreen(quizId: quiz.id),
                                ),
                              );
                              if (context.mounted) await state.loadHistory();
                            }
                          : null,
                    ),
                  );
                },
              );
        return embedded
            ? list
            : RefreshIndicator(onRefresh: refresh, child: list);
      },
    );
  }
}
