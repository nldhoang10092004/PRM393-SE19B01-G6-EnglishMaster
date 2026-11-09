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
    this.longText = false,
  });
  final String title, content;

  /// Long passages (reading) use regular weight and roomier lines.
  final bool longText;
  final SkillColors? colors;
  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final c = colors ?? p.speaking;
    final t = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.edge, width: 2),
        boxShadow: [BoxShadow(color: c.edge, offset: const Offset(0, 4))],
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
                fontWeight: longText ? FontWeight.w400 : FontWeight.w700,
                height: longText ? 1.6 : null,
                color: c.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
