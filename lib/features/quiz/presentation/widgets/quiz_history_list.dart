import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../providers/quiz_provider.dart';

/// Read-only attempt history, since the API exposes no past-answer endpoint.
class QuizHistoryList extends StatelessWidget {
  const QuizHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizProvider>();
    return AsyncView(
      status: state.historyStatus,
      error: state.historyError,
      onRetry: state.loadHistory,
      builder: (_) => RefreshIndicator(
        onRefresh: state.loadHistory,
        child: state.attempts.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  MessageView(
                    icon: Icons.history,
                    message: AppStrings.noAttempts,
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: state.attempts.length,
                itemBuilder: (_, index) {
                  final attempt = state.attempts[index];
                  final title =
                      state.quizzes
                          .where((q) => q.id == attempt.quizId)
                          .firstOrNull
                          ?.title ??
                      AppStrings.quizNumber(attempt.quizId);
                  final timestamp = attempt.submittedAt ?? attempt.startedAt;
                  final date = timestamp == null
                      ? ''
                      : DateFormat.yMd('vi')
                            .add_Hm()
                            .format(timestamp.toLocal());
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(title),
                      subtitle: Text(
                        AppStrings.attemptSummary(attempt.status, date),
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        attempt.submittedAt == null || attempt.score == null
                            ? AppStrings.unavailableValue
                            : AppStrings.percentage(attempt.score!),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
