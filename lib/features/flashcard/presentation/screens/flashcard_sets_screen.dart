import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<FlashcardProvider>().load();
    });
  }

  Future<void> _refresh() async {
    await context.read<FlashcardProvider>().load();
    if (mounted) setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FlashcardProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.flashcards),
        actions: [
          IconButton(
            tooltip: AppStrings.studyHistory,
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const FlashcardHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      body: AsyncView(
        status: state.status,
        error: state.error,
        onRetry: _refresh,
        builder: (_) => RefreshIndicator(
          onRefresh: _refresh,
          child: state.sets.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    MessageView(
                      icon: Icons.style_outlined,
                      message: AppStrings.noSets,
                    ),
                  ],
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 218,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: state.sets.length,
                  itemBuilder: (_, index) => FlashcardSetTile(
                    key: ValueKey('${state.sets[index].id}:$_revision'),
                    set: state.sets[index],
                  ),
                ),
        ),
      ),
    );
  }
}
