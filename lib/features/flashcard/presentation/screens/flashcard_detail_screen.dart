import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/flashcard_repository.dart';
import '../providers/flashcard_provider.dart';
import 'flashcard_study_screen.dart';

/// Set contents and persisted mastery before entering a study session.
class FlashcardDetailScreen extends StatelessWidget {
  const FlashcardDetailScreen({super.key, required this.setId});
  final int setId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardStudyProvider(context.read<FlashcardRepository>())
          ..load(setId),
    child: Consumer<FlashcardStudyProvider>(
      builder: (context, state, _) => Scaffold(
        appBar: AppBar(
          title: Text(state.set?.title ?? AppStrings.flashcardSet),
        ),
        body: AsyncView(
          status: state.status,
          error: state.error,
          onRetry: () => state.load(setId),
          builder: (_) {
            final set = state.set!;
            final mastered = state.progress.where((p) => p.isMastered).length;
            return RefreshIndicator(
              onRefresh: () => state.load(setId),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: set.items.length + 1,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (set.description.isNotEmpty) Text(set.description),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.masteredTotal(mastered, set.items.length),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: set.items.isEmpty
                              ? 0
                              : (mastered / set.items.length).clamp(0, 1),
                        ),
                        if (state.progressError != null)
                          Text(state.progressError!),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(AppStrings.studySet),
                          onPressed: set.items.isEmpty
                              ? null
                              : () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          FlashcardStudyScreen(setId: setId),
                                    ),
                                  );
                                  if (context.mounted) await state.load(setId);
                                },
                        ),
                        const SizedBox(height: 16),
                        if (set.items.isEmpty)
                          const MessageView(
                            icon: Icons.style_outlined,
                            message: AppStrings.noCards,
                          ),
                      ],
                    );
                  }
                  final card = set.items[index - 1];
                  return Card(
                    child: ListTile(
                      leading: card.imageUrl == null
                          ? null
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              // Decoded at 56 px (x pixel ratio) + disk cache.
                              child: AppNetworkImage(
                                url: card.imageUrl!,
                                width: 56,
                                height: 56,
                              ),
                            ),
                      title: Text(card.front),
                      subtitle: Text(card.back),
                      trailing:
                          state.progress.any(
                            (p) => p.itemId == card.id && p.isMastered,
                          )
                          ? const Icon(Icons.check_circle_outline)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}
