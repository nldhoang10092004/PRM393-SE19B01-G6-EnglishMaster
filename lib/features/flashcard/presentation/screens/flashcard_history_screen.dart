import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../providers/flashcard_history_provider.dart';
import '../../data/flashcard_repository.dart';

/// Refreshable learning history scoped to this route.
class FlashcardHistoryScreen extends StatelessWidget {
  const FlashcardHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardHistoryProvider(context.read<FlashcardRepository>())..load(),
    child: Consumer<FlashcardHistoryProvider>(
      builder: (_, state, _) => Scaffold(
        appBar: AppBar(title: const Text('Study history')),
        body: AsyncView(
          status: state.status,
          error: state.error,
          onRetry: state.load,
          builder: (_) => RefreshIndicator(
            onRefresh: state.load,
            child: state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      MessageView(
                        icon: Icons.history,
                        message: 'No study history yet.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    itemBuilder: (_, index) {
                      final item = state.items[index];
                      return ListTile(
                        leading: Icon(
                          item.actionType == 2
                              ? Icons.check_circle_outline
                              : Icons.replay,
                        ),
                        title: Text(item.front),
                        subtitle: Text(
                          '${item.actionType == 2 ? 'Mastered' : 'Reviewed'} · ${item.createdAt?.toLocal().toString().split('.').first ?? ''}',
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    ),
  );
}
