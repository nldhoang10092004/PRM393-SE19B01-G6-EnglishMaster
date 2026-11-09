import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../ai_exam_strings.dart';
import '../../data/ai_exam_repository.dart';
import '../providers/ai_review_provider.dart';
import '../widgets/ai_prompt_card.dart';
import '../widgets/ai_score_card.dart';

/// Original prompt and answer, and AI review.
class AiReviewDetailScreen extends StatelessWidget {
  const AiReviewDetailScreen({super.key, required this.submissionId});
  final int submissionId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        AiReviewProvider(context.read<AiExamRepository>())
          ..loadDetail(submissionId),
    child: Consumer<AiReviewProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: const AppTopBar(title: Text(AiExamStrings.review)),
        body: state.status == ViewStatus.error
            ? MessageView(
                icon: Icons.cloud_off_outlined,
                message: state.error ?? AiExamStrings.genericError,
                actionLabel: AiExamStrings.retry,
                onAction: () => state.loadDetail(submissionId),
              )
            : AsyncView(
                status: state.status,
                builder: (_) {
                  final detail = state.detail!;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      AiPromptCard(
                        title: detail.title,
                        content: detail.content,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AiExamStrings.answer,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(detail.answer),
                      const SizedBox(height: 16),
                      AiScoreCard(
                        score: detail.ai,
                        title: AiExamStrings.aiReview,
                      ),
                    ],
                  );
                },
              ),
      ),
    ),
  );
}
