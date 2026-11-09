import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../ai_exam_strings.dart';
import '../../data/ai_exam_repository.dart';
import '../providers/ai_review_provider.dart';
import 'ai_review_detail_screen.dart';

/// Refreshable history of submissions actually saved by the backend.
class AiReviewHistoryScreen extends StatelessWidget {
  const AiReviewHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AiReviewProvider(context.read<AiExamRepository>())..loadHistory(),
    child: Consumer<AiReviewProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: const AppTopBar(title: Text(AiExamStrings.history)),
        body: state.status == ViewStatus.error
            ? MessageView(
                icon: Icons.cloud_off_outlined,
                message: state.error ?? AiExamStrings.genericError,
                actionLabel: AiExamStrings.retry,
                onAction: state.loadHistory,
              )
            : AsyncView(
                status: state.status,
                builder: (_) => RefreshIndicator(
                  onRefresh: state.loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.submissions.isEmpty
                        ? 2
                        : state.submissions.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(AiExamStrings.historyNote),
                        );
                      }
                      if (state.submissions.isEmpty) {
                        return const MessageView(
                          icon: Icons.history_rounded,
                          message: AiExamStrings.noHistory,
                        );
                      }
                      final submission = state.submissions[index - 1];
                      final date = submission.createdAt?.toLocal();
                      final dateText = date == null
                          ? ''
                          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                      return Card(
                        child: ListTile(
                          title: Text(
                            submission.title.isEmpty
                                ? AiExamStrings.prompt
                                : submission.title,
                          ),
                          subtitle: Text(dateText),
                          trailing: Text(
                            '${submission.score.toStringAsFixed(1)}/9',
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AiReviewDetailScreen(
                                  submissionId: submission.id,
                                ),
                              ),
                            );
                            if (context.mounted) await state.loadHistory();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    ),
  );
}
