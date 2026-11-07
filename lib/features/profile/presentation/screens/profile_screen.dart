import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../membership/presentation/screens/membership_screen.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../quiz/presentation/screens/quiz_history_screen.dart';
import '../../../vocabulary/presentation/screens/vocabulary_screen.dart';
import '../providers/profile_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

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
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: AsyncView(
        status: state.status,
        error: state.error,
        onRetry: state.load,
        builder: (_) {
          final profile = state.profile!;
          final name = profile.fullName.isEmpty
              ? AppStrings.student
              : profile.fullName;
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
                                : AppNetworkImage(
                                    url: avatar,
                                    width: 80,
                                    height: 80,
                                    error: Text(
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
                            _stat(
                              context,
                              state.stats?.streak,
                              AppStrings.dayStreak,
                            ),
                            _stat(
                              context,
                              state.stats?.attempts,
                              AppStrings.attempts,
                            ),
                            _stat(
                              context,
                              state.stats?.words,
                              AppStrings.words,
                            ),
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
                    // Opens plan selection / renewal with PayOS QR payment.
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MembershipScreen(),
                        ),
                      );
                      if (context.mounted) {
                        context.read<ProfileProvider>().load();
                      }
                    },
                    trailing: const Icon(Icons.chevron_right),
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: Text(
                      membership == null
                          ? AppStrings.membershipUnavailable
                          : membership.hasMembership
                          ? AppStrings.activeMembership
                          : AppStrings.noMembership,
                    ),
                    subtitle: Text(
                      state.membershipError ??
                          (membership?.endsAt == null
                              ? AppStrings.quizMembershipRequired
                              : AppStrings.membershipExpires(
                                  DateFormat.yMd('vi')
                                      .format(membership!.endsAt!.toLocal()),
                                )),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text(AppStrings.editProfile),
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
                  title: const Text(AppStrings.changePassword),
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
                  title: const Text(AppStrings.vocabulary),
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
                  title: const Text(AppStrings.studyReminder),
                  subtitle: const Text(AppStrings.manageReminders),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/settings/reminder'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text(AppStrings.quizHistory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuizHistoryScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: const Text(AppStrings.logout),
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
        count?.toString() ?? AppStrings.unavailableValue,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(label),
    ],
  );
}
