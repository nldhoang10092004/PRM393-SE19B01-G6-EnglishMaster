import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../membership/presentation/screens/membership_screen.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/async_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../quiz/presentation/screens/quiz_history_screen.dart';
import '../../../vocabulary/presentation/screens/vocabulary_screen.dart';
import '../providers/profile_provider.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

/// Student identity, membership and account actions.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.imagePicker});
  final ImagePicker? imagePicker;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final state = context.read<ProfileProvider>();
    await state.load();
    if (!mounted || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      final lost = await (widget.imagePicker ?? ImagePicker())
          .retrieveLostData();
      if (!mounted) return;
      if (lost.files?.isNotEmpty ?? false) {
        await _upload(lost.files!.first);
      } else if (lost.exception != null) {
        _showMessage(AppStrings.photoPickerError);
      }
    } catch (_) {
      /* A platform without recovery still supports normal picking. */
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _upload(XFile file) async {
    if (!mounted) return;
    final state = context.read<ProfileProvider>();
    final ok = await state.uploadAvatar(file.path);
    _showMessage(
      ok
          ? AppStrings.avatarUpdated
          : state.avatarError ?? AppStrings.avatarUploadError,
    );
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text(AppStrings.choosePhoto),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text(AppStrings.takePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final file = await (widget.imagePicker ?? ImagePicker()).pickImage(
        source: source,
        maxWidth: 512,
        imageQuality: 85,
      );
      if (file != null && mounted) await _upload(file);
    } catch (_) {
      _showMessage(AppStrings.photoPickerError);
    }
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
                        Semantics(
                          label: AppStrings.changeAvatar,
                          button: true,
                          child: InkWell(
                            key: const Key('change_avatar'),
                            onTap: state.uploadingAvatar ? null : _pickAvatar,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 92,
                              height: 92,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  UserAvatar(
                                    url: state.avatarUrl,
                                    name: name,
                                    radius: 40,
                                  ),
                                  if (state.uploadingAvatar)
                                    const SizedBox(
                                      width: 88,
                                      height: 88,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 18,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(profile.email, textAlign: TextAlign.center),
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
                const SizedBox(height: 16),
                const SectionHeader(title: AppStrings.accountSettings),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
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
                            Navigator.of(context)
                                .pushNamed('/settings/reminder'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
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

  Widget _stat(BuildContext context, int? count, String label) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: StatTile(
        value: count?.toString() ?? AppStrings.unavailableValue,
        label: label,
      ),
    ),
  );
}
