import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/async_view.dart';
import '../providers/vocabulary_provider.dart';

/// Local word search and swipe removal with server-backed undo.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<VocabularyProvider>()
          ..search('')
          ..load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VocabularyProvider>();
    final words = state.words;
    return Scaffold(
      appBar: const AppTopBar(title: Text(AppStrings.vocabulary)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: state.search,
              decoration: const InputDecoration(
                labelText: AppStrings.searchWords,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AsyncView(
              status: state.status,
              error: state.error,
              onRetry: state.load,
              builder: (_) => RefreshIndicator(
                onRefresh: state.load,
                child: words.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 96),
                          MessageView(
                            icon: Icons.bookmark_border,
                            message: AppStrings.noMatchingWords,
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return Dismissible(
                            key: ValueKey(word.itemId),
                            direction: state.isPending(word.itemId)
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .errorContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_outline),
                            ),
                            confirmDismiss: (_) async {
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await state.remove(word);
                              if (!mounted) return false;
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? AppStrings.wordRemoved(word.front)
                                        : state.error ??
                                              AppStrings.deleteWordError,
                                  ),
                                  action: ok
                                      ? SnackBarAction(
                                          label: AppStrings.undo,
                                          onPressed: () async {
                                            final restored = await state.save(
                                              word,
                                            );
                                            if (mounted && !restored) {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    state.error ??
                                                        AppStrings
                                                            .restoreWordError,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        )
                                      : null,
                                ),
                              );
                              return false;
                            },
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  child: Icon(
                                    Icons.translate_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer,
                                  ),
                                ),
                                title: Text(word.front),
                                subtitle: Text(
                                  AppStrings.wordDetails(
                                    word.back,
                                    word.example,
                                  ),
                                ),
                                isThreeLine: word.example.isNotEmpty,
                                trailing: word.isMastered
                                    ? const Icon(Icons.check_circle_outline)
                                    : const Icon(Icons.swipe_left_outlined),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
