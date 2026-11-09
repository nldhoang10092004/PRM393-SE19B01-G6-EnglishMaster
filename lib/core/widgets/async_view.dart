import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import 'skeleton_loading.dart';

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
    this.emptyMessage = AppStrings.empty,
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
        return const SkeletonLoading();
      case ViewStatus.error:
        return MessageView(
          icon: Icons.cloud_off_outlined,
          message: error ?? AppStrings.genericError,
          actionLabel: onRetry == null ? null : AppStrings.retry,
          onAction: onRetry,
        );
      case ViewStatus.success:
        if (isEmpty) {
          return MessageView(icon: Icons.inbox_outlined, message: emptyMessage);
        }
        return builder(context);
    }
  }
}

/// Centered icon + message with an optional action button.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              ChunkyOutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
