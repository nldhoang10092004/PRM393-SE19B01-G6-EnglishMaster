import 'package:flutter/material.dart';

import '../../membership_strings.dart';
import '../screens/membership_screen.dart';

/// Banner to show where premium content is locked.
class UpgradeMembershipBanner extends StatelessWidget {
  const UpgradeMembershipBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.workspace_premium, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            const Expanded(child: Text(MembershipStrings.upgradeBanner)),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MembershipScreen()),
              ),
              child: const Text(MembershipStrings.upgrade),
            ),
          ],
        ),
      ),
    );
  }
}
