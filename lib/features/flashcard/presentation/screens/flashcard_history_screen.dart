import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/flashcard_repository.dart';
import '../providers/flashcard_history_provider.dart';

/// Refreshable learning history scoped to this route.
class FlashcardHistoryScreen extends StatelessWidget {
  const FlashcardHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardHistoryProvider(context.read<FlashcardRepository>())..load(),
    child: Consumer<FlashcardHistoryProvider>(
      builder: (_, state, _) => Scaffold(
        appBar: const AppTopBar(title: Text(AppStrings.studyHistory)),
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
                        message: AppStrings.noStudyHistory,
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
                          AppStrings.historyEntry(
                            item.actionType == 2
                                ? AppStrings.mastered
                                : AppStrings.reviewed,
                            item.createdAt == null
                                ? ''
                                : DateFormat.yMd('vi')
                                      .add_Hm()
                                      .format(item.createdAt!.toLocal()),
                          ),
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
