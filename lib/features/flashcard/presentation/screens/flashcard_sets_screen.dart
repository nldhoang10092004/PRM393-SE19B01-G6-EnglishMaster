import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../../core/widgets/pill_chip.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/widgets/icon_square_button.dart';
import '../../../../core/theme/app_palette.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/flashcard_set_tile.dart';
import 'flashcard_history_screen.dart';

/// Public flashcard sets with counts and progress loaded per tile.
class FlashcardSetsScreen extends StatefulWidget {
  const FlashcardSetsScreen({super.key});
  @override
  State<FlashcardSetsScreen> createState() => _FlashcardSetsScreenState();
}

class _FlashcardSetsScreenState extends State<FlashcardSetsScreen> {
  int _revision = 0;
  int _filter = 0;
  final _counts = <int, (int, int)>{};
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<FlashcardProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<FlashcardProvider>().load();
    if (mounted) {
      setState(() {
        _counts.clear();
        _revision++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FlashcardProvider>();
    final visible = state.sets.where((s) {
      final c = _counts[s.id];
      if (_filter == 0 || c == null) return true;
      return _filter == 1 ? c.$2 < c.$1 : c.$1 > 0 && c.$2 >= c.$1;
    }).toList();
    final p = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.flashcards,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconSquareButton(
                    icon: Icons.history,
                    tooltip: AppStrings.studyHistory,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FlashcardHistoryScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < 3; i++)
                      PillChip(
                        label: [
                          AppStrings.all,
                          AppStrings.studying,
                          AppStrings.mastered,
                        ][i],
                        selected: _filter == i,
                        onTap: () => setState(() => _filter = i),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AsyncView(
                status: state.status,
                error: state.error,
                onRetry: _refresh,
                builder: (_) => RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (visible.isEmpty)
                        const SliverToBoxAdapter(
                          child: MessageView(
                            icon: Icons.style_outlined,
                            message: AppStrings.noSets,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  mainAxisExtent: 220,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: visible.length,
                            itemBuilder: (_, index) {
                              final set = visible[index];
                              return FlashcardSetTile(
                                key: ValueKey('${set.id}:$_revision'),
                                set: set,
                                colorIndex: index,
                                onSummary: (total, mastered) {
                                  if (mounted &&
                                      _counts[set.id] != (total, mastered)) {
                                    setState(
                                      () => _counts[set.id] = (total, mastered),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                          child: OutlinedCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: p.reward,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.local_fire_department_outlined,
                                    color: p.onReward,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.dailyReview,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        AppStrings.dailyReviewHint,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
