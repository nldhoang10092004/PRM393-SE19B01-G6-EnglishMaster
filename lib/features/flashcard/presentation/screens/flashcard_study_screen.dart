import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/app_network_image.dart';
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
  String? _precachedUrl;

  /// Warms the image cache for the next card so swiping shows it instantly.
  void _precacheNext(String? url) {
    if (url == null || url == _precachedUrl) return;
    _precachedUrl = url;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final media = MediaQuery.of(context);
      // Same size the card renders at: screen width minus card margin/padding.
      precacheImage(
        AppNetworkImage.providerFor(
          url,
          logicalWidth: media.size.width - 80,
          pixelRatio: media.devicePixelRatio,
        ),
        context,
        onError: (_, _) {},
      );
    });
  }

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
        _precacheNext(state.upcoming?.imageUrl);
        final vocabulary = context.watch<VocabularyProvider>();
        final saved =
            card != null &&
            (vocabulary.isSaved(card.id) ||
                state.progress.any((p) => p.itemId == card.id && p.isSaved));
        return Scaffold(
          appBar: AppBar(
            title: Text(state.set?.title ?? AppStrings.study),
            actions: [
              if (card != null)
                IconButton(
                  tooltip: AppStrings.saveVocabulary,
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
                                      ? AppStrings.savedVocabulary
                                      : vocabulary.error ??
                                            AppStrings.saveWordError,
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
                          AppStrings.setComplete,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          AppStrings.studySummaryTotal(
                            state.masteredCount,
                            state.total,
                            state.reviews,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (state.remaining > 0) ...[
                          FilledButton(
                            onPressed: state.restart,
                            child: const Text(AppStrings.studyUnmastered),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(AppStrings.backToSet),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (card == null) {
                return const MessageView(
                  icon: Icons.style_outlined,
                  message: AppStrings.emptySet,
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
                        Row(
                          children: [
                            Text(
                              AppStrings.cardPosition(
                                state.index + 1,
                                state.total,
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            Text(
                              AppStrings.studyProgress(
                                state.masteredCount,
                                state.remaining,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: state.flip,
                      // Swipe left/right to move between cards.
                      onHorizontalDragEnd: (details) {
                        final v = details.primaryVelocity ?? 0;
                        if (v < -200) state.next();
                        if (v > 200) state.previous();
                      },
                      child: Semantics(
                        button: true,
                        label: AppStrings.flipCard,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(
                            '${card.id}:${state.index}:${state.reviews}',
                          ),
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
                                            if (state.isMastered(card.id))
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: Chip(
                                                  avatar: Icon(
                                                    Icons.check_circle,
                                                    size: 18,
                                                  ),
                                                  label: Text(
                                                    AppStrings.masteredBadge,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              ),
                                            if (!back && card.imageUrl != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  // Decoded at the card width, cached on disk.
                                                  child: AppNetworkImage(
                                                    url: card.imageUrl!,
                                                    height: 180,
                                                    width: double.infinity,
                                                    error: const SizedBox(
                                                      height: 60,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder: const SizedBox(
                                                      height: 180,
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                            const Text(AppStrings.tapToFlip),
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
                          IconButton.outlined(
                            tooltip: AppStrings.previousCard,
                            onPressed: state.busy || !state.hasPrevious
                                ? null
                                : state.previous,
                            icon: const Icon(Icons.chevron_left),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.busy
                                  ? null
                                  : () => state.answer(mastered: false),
                              child: const Text(AppStrings.again),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: state.busy
                                  ? null
                                  : () => state.answer(mastered: true),
                              child: Text(
                                state.busy
                                    ? AppStrings.saving
                                    : AppStrings.gotIt,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            tooltip: AppStrings.nextCard,
                            onPressed: state.busy || !state.hasNext
                                ? null
                                : state.next,
                            icon: const Icon(Icons.chevron_right),
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
