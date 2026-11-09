import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/flat_hero_card.dart';
import 'ai_listening_screen.dart';
import 'ai_reading_screen.dart';
import 'ai_review_history_screen.dart';
import 'ai_speaking_screen.dart';
import 'ai_writing_screen.dart';

/// Entry point for the four AI skills and saved submission history.
class AiExamHubScreen extends StatelessWidget {
  const AiExamHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        AiExamStrings.speaking,
        AiExamStrings.speakingDescription,
        Icons.mic_none_rounded,
        const AiSpeakingScreen(),
      ),
      (
        AiExamStrings.listening,
        AiExamStrings.listeningDescription,
        Icons.headphones_rounded,
        const AiListeningScreen(),
      ),
      (
        AiExamStrings.writing,
        AiExamStrings.writingDescription,
        Icons.edit_note_rounded,
        const AiWritingScreen(),
      ),
      (
        AiExamStrings.reading,
        AiExamStrings.readingDescription,
        Icons.menu_book_rounded,
        const AiReadingScreen(),
      ),
      (
        AiExamStrings.history,
        AiExamStrings.historyDescription,
        Icons.history_rounded,
        const AiReviewHistoryScreen(),
      ),
    ];
    return Scaffold(
      appBar: const AppTopBar(title: Text(AiExamStrings.hub)),
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: FlatHeroCard(
                title: AiExamStrings.hub,
                subtitle: AiExamStrings.intro,
                icon: Icons.auto_awesome_rounded,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: switch (MediaQuery.sizeOf(context).width) {
                  < 340 => 1,
                  < 600 => 2,
                  < 900 => 3,
                  _ => 5,
                },
                mainAxisExtent: 250,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final (title, subtitle, icon, page) = cards[index];
                final scheme = Theme.of(context).colorScheme;
                final p = AppPalette.of(context);
                final palette = [
                  p.speaking,
                  p.listening,
                  p.writing,
                  p.reading,
                  SkillColors(p.muted, p.ink, p.outline),
                ];
                final c = palette[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: c.edge, width: 2),
                    boxShadow: [
                      BoxShadow(color: c.edge, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => page)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: .76),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: c.edge, width: 1.5),
                              ),
                              child: Icon(icon, color: c.ink),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: c.ink),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: c.ink),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: c.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
