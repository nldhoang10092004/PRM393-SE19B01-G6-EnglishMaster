import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../../vocabulary/data/models/saved_word.dart';
import '../../../vocabulary/presentation/providers/vocabulary_provider.dart';
import '../../data/flashcard_repository.dart';
import '../providers/flashcard_provider.dart';

/// Flip cards with a perspective transform and persist every learning action.
class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({super.key, required this.setId});
  final int setId;

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<VocabularyProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        FlashcardStudyProvider(context.read<FlashcardRepository>())
          ..load(widget.setId),
    child: Consumer<FlashcardStudyProvider>(
      builder: (context, state, _) {
        final card = state.current;
        final vocabulary = context.watch<VocabularyProvider>();
        final saved =
            card != null &&
            (vocabulary.isSaved(card.id) ||
                state.progress.any((p) => p.itemId == card.id && p.isSaved));
        return Scaffold(
          appBar: AppBar(
            title: Text(state.set?.title ?? 'Study'),
            actions: [
              if (card != null)
                IconButton(
                  tooltip: 'Save to vocabulary',
                  onPressed: vocabulary.isPending(card.id) || saved
                      ? null
                      : () async {
                          final ok = await vocabulary.save(
                            SavedWord(
                              itemId: card.id,
                              front: card.front,
                              back: card.back,
                              example: card.example,
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Saved to vocabulary'
                                      : vocabulary.error ??
                                            'Unable to save word.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                ),
            ],
          ),
          body: AsyncView(
            status: state.status,
            error: state.error,
            onRetry: () => state.load(widget.setId),
            builder: (_) {
              if (state.complete) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.celebration_outlined,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Set complete!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '${state.masteredCount} cards mastered in ${state.reviews} reviews.',
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to set'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (card == null) {
                return const MessageView(
                  icon: Icons.style_outlined,
                  message: 'No cards in this set.',
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        LinearProgressIndicator(value: state.fraction),
                        const SizedBox(height: 8),
                        Text(
                          '${state.masteredCount} mastered · ${state.remaining} remaining',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: state.flip,
                      child: Semantics(
                        button: true,
                        label: 'Flip flashcard',
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey('${card.id}:${state.reviews}'),
                          tween: Tween(
                            begin: 0,
                            end: state.flipped ? math.pi : 0,
                          ),
                          duration: const Duration(milliseconds: 280),
                          builder: (context, angle, _) {
                            final back = angle > math.pi / 2;
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  back ? math.pi : 0,
                                ),
                                child: Card(
                                  margin: const EdgeInsets.all(16),
                                  child: SizedBox.expand(
                                    child: Center(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              back ? card.back : card.front,
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall,
                                            ),
                                            if (!back && card.ipa.isNotEmpty)
                                              Text(card.ipa),
                                            if (back &&
                                                card.example.isNotEmpty) ...[
                                              const SizedBox(height: 16),
                                              Text(
                                                card.example,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                            const SizedBox(height: 24),
                                            const Text('Tap to flip'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.busy
                                  ? null
                                  : () => state.answer(mastered: false),
                              child: const Text('Again'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: state.busy
                                  ? null
                                  : () => state.answer(mastered: true),
                              child: Text(state.busy ? 'Saving…' : 'Got it'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    ),
  );
}
