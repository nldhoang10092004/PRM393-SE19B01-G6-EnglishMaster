import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../ai_exam_strings.dart';
import 'ai_generating_view.dart';

/// Shared exercise loading and retry UI with localized text and retained drafts.
class AiExamBody extends StatelessWidget {
  const AiExamBody({
    super.key,
    required this.status,
    required this.error,
    required this.hasPrompt,
    required this.busy,
    required this.canGenerate,
    required this.onGenerate,
    required this.children,
    required this.kind,
    this.generating = false,
    this.grading = false,
    this.pinned,
  });
  final ViewStatus status;
  final String? error;
  final bool hasPrompt, busy, canGenerate, generating, grading;
  final AiGeneratingKind kind;

  /// Shown above the scrollable list and never scrolled away.
  final Widget? pinned;
  final VoidCallback onGenerate;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!hasPrompt && status == ViewStatus.error) {
      return MessageView(
        icon: Icons.cloud_off_outlined,
        message: error ?? AiExamStrings.genericError,
        actionLabel: AiExamStrings.retry,
        onAction: onGenerate,
      );
    }
    if (!hasPrompt) return AiGeneratingView(kind: kind);
    final list = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...children,
        if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              semanticsLabel: error,
            ),
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: canGenerate ? onGenerate : null,
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text(AiExamStrings.generate),
        ),
        const SizedBox(height: 16),
      ],
    );
    final content = pinned == null
        ? list
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: pinned,
              ),
              Expanded(child: list),
            ],
          );
    if (!(generating || grading)) return content;
    // Keep the form mounted underneath so drafts and scroll are retained.
    return Stack(
      children: [
        content,
        Positioned.fill(
          child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: AiGeneratingView(
              kind: grading ? AiGeneratingKind.grading : kind,
            ),
          ),
        ),
      ],
    );
  }
}
