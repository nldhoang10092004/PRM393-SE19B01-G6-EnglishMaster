import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/score_ring.dart';
import '../../data/flashcard_repository.dart';
import '../../data/models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../screens/flashcard_detail_screen.dart';

/// Loads real mastery counts omitted by the catalog DTO.
class FlashcardSetTile extends StatelessWidget {
  const FlashcardSetTile({
    super.key,
    required this.set,
    this.onSummary,
    this.colorIndex,
  });
  final FlashcardSet set;

  /// Position in the grid; picks the skill colour so neighbours differ.
  final int? colorIndex;
  final void Function(int total, int mastered)? onSummary;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardStudyProvider(context.read<FlashcardRepository>())
          ..load(set.id),
    child: Consumer<FlashcardStudyProvider>(
      builder: (context, state, _) {
        final total = state.set?.items.length;
        final mastered = state.progress.where((p) => p.isMastered).length;
        if (total != null && state.progressError == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) onSummary?.call(total, mastered);
          });
        }
        final p = AppPalette.of(context);
        final colors = [
          p.listening,
          p.writing,
          p.speaking,
        ][(colorIndex ?? (set.id - 1).abs()) % 3];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.edge, width: 2),
            boxShadow: [
              BoxShadow(color: colors.edge, offset: const Offset(0, 4)),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ScoreRing(
                          size: 56,
                          fraction: total == null || total == 0
                              ? 0
                              : mastered / total,
                          label: total == null
                              ? AppStrings.unavailableValue
                              : '$mastered/$total',
                          color: colors.ink,
                          trackColor: p.surface,
                          labelColor: colors.ink,
                        ),
                        Icon(
                          Icons.north_east_rounded,
                          size: 18,
                          color: colors.ink,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      set.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        height: 1.25,
                        color: colors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.status == ViewStatus.error
                          ? AppStrings.detailsUnavailable
                          : total == null
                          ? AppStrings.loadingDetails
                          : AppStrings.cardCount(total),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.ink),
                    ),
                    if (state.progressError != null)
                      Text(
                        AppStrings.progressUnavailable,
                        style: TextStyle(color: colors.ink, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
