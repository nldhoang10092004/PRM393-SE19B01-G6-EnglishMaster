import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';

/// Displays server-generated English exercise content under a Vietnamese heading.
class AiPromptCard extends StatelessWidget {
  const AiPromptCard({super.key, required this.title, required this.content});
  final String title, content;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AiExamStrings.prompt,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          if (title.isNotEmpty)
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText(content),
          ],
        ],
      ),
    ),
  );
}
