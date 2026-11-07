import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../data/flashcard_repository.dart';
import '../../data/models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../screens/flashcard_detail_screen.dart';

/// Independently loads set counts because the catalog DTO omits them.
class FlashcardSetTile extends StatelessWidget {
  const FlashcardSetTile({super.key, required this.set});
  final FlashcardSet set;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardStudyProvider(context.read<FlashcardRepository>())
          ..load(set.id),
    child: Consumer<FlashcardStudyProvider>(
      builder: (context, state, _) {
        final total = state.set?.items.length;
        final mastered = state.progress.where((p) => p.isMastered).length;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => FlashcardDetailScreen(setId: set.id),
                ),
              );
              if (context.mounted) await state.load(set.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.style_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    set.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    total == null ? 'Open to study' : '$total cards',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == null
                        ? state.status == ViewStatus.loading
                              ? null
                              : 0
                        : total == 0
                        ? 0
                        : (mastered / total).clamp(0, 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.status == ViewStatus.error
                        ? 'Details unavailable'
                        : state.progressError != null
                        ? 'Progress unavailable'
                        : total == null
                        ? 'Loading details'
                        : '$mastered mastered',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
