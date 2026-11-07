import 'package:flutter/material.dart';

import '../../../../core/widgets/async_view.dart';
import '../../ai_exam_strings.dart';

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
    this.submitting = false,
  });
  final ViewStatus status;
  final String? error;
  final bool hasPrompt, busy, canGenerate, submitting;
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
    return AsyncView(
      status: hasPrompt ? ViewStatus.success : status,
      builder: (_) => ListView(
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
          if (busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              submitting ? AiExamStrings.submitting : AiExamStrings.generating,
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: canGenerate ? onGenerate : null,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text(AiExamStrings.generate),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
