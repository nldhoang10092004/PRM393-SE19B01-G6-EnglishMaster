import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/pill_chip.dart';
import '../../ai_exam_strings.dart';

/// Flat skill prompt with server content and a small AI-origin badge.
class AiPromptCard extends StatelessWidget {
  const AiPromptCard({
    super.key,
    required this.title,
    required this.content,
    this.colors,
  });
  final String title, content;
  final SkillColors? colors;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = colors ?? p.speaking;
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillChip(
            label: AiExamStrings.prompt,
            color: p.surface,
            foreground: c.ink,
          ),
          const SizedBox(height: 10),
          if (title.isNotEmpty)
            Text(
              title,
              style: t.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                color: c.ink,
              ),
            ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 10),
            SelectableText(
              content,
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: c.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
