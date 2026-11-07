import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../quiz/presentation/screens/quiz_history_screen.dart';
import '../../../vocabulary/presentation/screens/vocabulary_screen.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

/// Student identity, membership and account actions.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ProfileProvider>().load();
    });
  }

  String? _avatar(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final resolved = uri.hasScheme
        ? uri
        : Uri.parse(AppConfig.apiBaseUrl).resolveUri(uri);
    return (resolved.scheme == 'http' || resolved.scheme == 'https')
        ? resolved.toString()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileProvider>();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AsyncView(
        status: state.status,
        error: state.error,
        onRetry: state.load,
        builder: (_) {
          final profile = state.profile!;
          final name = profile.fullName.isEmpty ? 'Student' : profile.fullName;
          final avatar = _avatar(state.avatarUrl);
          final membership = state.membership;
          return RefreshIndicator(
            onRefresh: state.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: ClipOval(
                            child: avatar == null
                                ? Text(
                                    name.characters.first.toUpperCase(),
                                    style: theme.textTheme.headlineMedium,
                                  )
                                : Image.network(
                                    avatar,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Text(
                                      name.characters.first.toUpperCase(),
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(name, style: theme.textTheme.headlineSmall),
                        Text(profile.email),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _stat(context, state.stats?.streak, 'Day streak'),
                            _stat(context, state.stats?.attempts, 'Attempts'),
                            _stat(context, state.stats?.words, 'Words'),
                          ],
                        ),
                        if (state.statsError != null)
                          Text(state.statsError!, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(
                      membership == null
                          ? 'Membership unavailable'
                          : membership.hasMembership
                          ? 'Active membership'
                          : 'No active membership',
                    ),
                    subtitle: Text(
                      state.membershipError ??
                          (membership?.endsAt == null
                              ? 'Membership is required for course quizzes.'
                              : 'Expires ${membership!.endsAt!.toLocal().toString().split(' ').first}'),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    state.clearError();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    state.clearError();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Saved vocabulary'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const VocabularyScreen(),
                      ),
                    );
                    if (mounted) await state.load();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Study reminder'),
                  subtitle: const Text(
                    'Manage reminder time and notifications',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/settings/reminder'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Quiz history'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuizHistoryScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: const Text('Log out'),
                  onTap: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stat(BuildContext context, int? count, String label) => Column(
    children: [
      Text(
        count?.toString() ?? '—',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(label),
    ],
  );
}
