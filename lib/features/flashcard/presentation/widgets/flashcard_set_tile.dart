import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
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
        final scheme = Theme.of(context).colorScheme;
        final palettes = [
          scheme.primaryContainer,
          scheme.secondaryContainer,
          scheme.tertiaryContainer,
          scheme.surfaceContainerHigh,
        ];
        return Card(
          color: palettes[set.id.abs() % palettes.length],
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
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
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: scheme.onSurfaceVariant,
                            value: total == null || total == 0
                                ? 0
                                : (mastered / total).clamp(0, 1),
                          ),
                        ),
                        Icon(
                          Icons.style_rounded,
                          size: 22,
                          color: scheme.onSurface,
                        ),
                      ],
                    ),
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
                    total == null
                        ? AppStrings.openToStudy
                        : AppStrings.cardCount(total),
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
                        ? AppStrings.detailsUnavailable
                        : state.progressError != null
                        ? AppStrings.progressUnavailable
                        : total == null
                        ? AppStrings.loadingDetails
                        : AppStrings.masteredCount(mastered),
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
