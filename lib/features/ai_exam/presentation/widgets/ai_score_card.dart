import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../data/models/ai_exam.dart';

/// Shows available score criteria and structured or plain-text AI feedback.
class AiScoreCard extends StatelessWidget {
  const AiScoreCard({
    super.key,
    required this.score,
    this.title = AiExamStrings.result,
  });
  final AiExamScore score;
  final String title;

  List<Widget> _feedback(BuildContext context, Object? value, [int depth = 0]) {
    if (value == null || value == '' || depth > 8) return const [];
    if (value is Map) {
      return value.entries.expand((entry) {
        final children = _feedback(context, entry.value, depth + 1);
        if (children.isEmpty) return <Widget>[];
        return <Widget>[
          const SizedBox(height: 8),
          Text(
            AiExamStrings.feedbackLabel(entry.key.toString()),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          ...children,
        ];
      }).toList();
    }
    if (value is List) {
      return value
          .expand((item) => _feedback(context, item, depth + 1))
          .toList();
    }
    return [
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SelectableText('$value'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final criteria = <String, double?>{
      AiExamStrings.taskResponse: score.taskResponse,
      AiExamStrings.coherence: score.coherence,
      AiExamStrings.fluency: score.fluency,
      AiExamStrings.lexical: score.lexical,
      AiExamStrings.grammar: score.grammar,
      AiExamStrings.pronunciation: score.pronunciation,
    };
    final feedback = _feedback(context, score.feedback);
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '${AiExamStrings.overall}: ${score.overall.toStringAsFixed(1)}/9',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: (score.overall / 9).clamp(0, 1)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in criteria.entries)
                  if (entry.value != null)
                    Chip(
                      label: Text(
                        '${entry.key}: ${entry.value!.toStringAsFixed(1)}',
                      ),
                    ),
              ],
            ),
            if (score.transcript.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                AiExamStrings.transcript,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SelectableText(score.transcript),
            ],
            const Divider(height: 32),
            Text(
              AiExamStrings.feedback,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (feedback.isEmpty)
              const Text(AiExamStrings.noFeedback)
            else
              ...feedback,
          ],
        ),
      ),
    );
  }
}
