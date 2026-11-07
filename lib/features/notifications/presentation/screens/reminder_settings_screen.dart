import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../providers/reminder_provider.dart';

/// Route name of [ReminderSettingsScreen]; the integrator registers it.
const String reminderSettingsRoute = '/settings/reminder';

/// Study reminder settings: enable switch, time picker and a test button.
class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ReminderProvider>();
    final settings = p.settings;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.studyReminder)),
      body: !p.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text(AppStrings.dailyReminder),
                  subtitle: const Text(AppStrings.dailyReminderHint),
                  value: settings.enabled,
                  onChanged: (v) =>
                      context.read<ReminderProvider>().setEnabled(v),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text(AppStrings.reminderTime),
                  trailing: Text(
                    settings.time.format(context),
                    style: theme.textTheme.titleMedium,
                  ),
                  onTap: () async {
                    final provider = context.read<ReminderProvider>();
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.time,
                    );
                    if (picked != null) await provider.setTime(picked);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.read<ReminderProvider>().sendTest(),
                    icon: const Icon(Icons.send_outlined),
                    label: const Text(AppStrings.sendTest),
                  ),
                ),
                if (p.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      p.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
              ],
            ),
    );
  }
}
