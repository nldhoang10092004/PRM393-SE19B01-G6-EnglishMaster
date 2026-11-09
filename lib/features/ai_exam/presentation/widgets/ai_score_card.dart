import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../data/models/ai_exam.dart';

/// Shows available score criteria and structured or plain-text AI feedback.
class AiScoreCard extends StatelessWidget {
  const AiScoreCard({
    super.key,
    required this.score,
    this.title = AiExamStrings.result,
    this.colors,
  });
  final AiExamScore score;
  final String title;
  final SkillColors? colors;

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
    final p = AppPalette.of(context);
    final c = colors ?? p.speaking;
    final t = Theme.of(context);
    final entries = criteria.entries.where((e) => e.value != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.edge, width: 2),
            boxShadow: [BoxShadow(color: c.edge, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              ScoreRing(
                size: 104,
                fraction: score.overall / 9,
                label: score.overall.toStringAsFixed(1),
                subtitle: '/9',
                trackColor: p.surface,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: t.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    color: c.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in entries)
                SizedBox(
                  width: (constraints.maxWidth - 10) / 2,
                  child: OutlinedCard(
                    padding: const EdgeInsets.all(12),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.key, style: t.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        Text(
                          e.value!.toStringAsFixed(1),
                          style: t.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (e.value! / 9).clamp(0, 1),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (score.transcript.isNotEmpty) ...[
          OutlinedCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AiExamStrings.transcript, style: t.textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(score.transcript),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AiExamStrings.aiReview, style: t.textTheme.titleMedium),
              if (feedback.isEmpty)
                const Text(AiExamStrings.noFeedback)
              else
                ...feedback,
            ],
          ),
        ),
      ],
    );
  }
}
