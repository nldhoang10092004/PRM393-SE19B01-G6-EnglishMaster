import 'package:flutter/material.dart';

/// Header of the dashboard: avatar and a time-of-day greeting.
///
/// The login response carries no display name, so the greeting is generic.
class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, this.userName, this.now});

  /// Shown after the greeting when known.
  final String? userName;

  /// Clock override for tests; defaults to `DateTime.now()`.
  final DateTime? now;

  /// "Good morning", "Good afternoon" or "Good evening" for [hour].
  static String greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = userName?.trim() ?? '';
    final initial = name.isEmpty ? null : name.substring(0, 1).toUpperCase();
    final greeting = greetingFor((now ?? DateTime.now()).hour);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: initial == null ? const Icon(Icons.person_rounded) : Text(initial),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? greeting : '$greeting, $name', style: theme.textTheme.headlineSmall),
                Text(
                  'Ready to learn something new?',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
