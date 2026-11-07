import 'package:flutter/material.dart';

/// Loading state of a screen backed by a provider.
enum ViewStatus { idle, loading, success, error }

/// Shared widget that renders loading / error / empty / content states so
/// every feature screen behaves consistently.
class AsyncView extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.status,
    required this.builder,
    this.error,
    this.onRetry,
    this.isEmpty = false,
    this.emptyMessage = 'Nothing here yet.',
  });

  final ViewStatus status;
  final String? error;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final String emptyMessage;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ViewStatus.idle:
      case ViewStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewStatus.error:
        return MessageView(
          icon: Icons.cloud_off_outlined,
          message: error ?? 'Something went wrong.',
          actionLabel: onRetry == null ? null : 'Retry',
          onAction: onRetry,
        );
      case ViewStatus.success:
        if (isEmpty) return MessageView(icon: Icons.inbox_outlined, message: emptyMessage);
        return builder(context);
    }
  }
}

/// Centered icon + message with an optional action button.
class MessageView extends StatelessWidget {
  const MessageView({super.key, required this.icon, required this.message, this.actionLabel, this.onAction});

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
