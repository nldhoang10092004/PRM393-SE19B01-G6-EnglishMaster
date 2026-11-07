import 'package:flutter/material.dart';

import '../../ai_exam_strings.dart';
import 'ai_listening_screen.dart';
import 'ai_review_history_screen.dart';
import 'ai_speaking_screen.dart';
import 'ai_writing_screen.dart';

/// Entry point for the three AI skills and saved submission history.
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
        AiExamStrings.history,
        AiExamStrings.historyDescription,
        Icons.history_rounded,
        const AiReviewHistoryScreen(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text(AiExamStrings.hub)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AiExamStrings.intro,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          final (title, subtitle, icon, page) = cards[index - 1];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => page)),
            ),
          );
        },
      ),
    );
  }
}
