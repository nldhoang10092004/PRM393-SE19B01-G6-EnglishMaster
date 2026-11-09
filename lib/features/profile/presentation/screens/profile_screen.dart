import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';

import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../membership/presentation/screens/membership_screen.dart';
import '../../../ai_exam/presentation/screens/ai_exam_hub_screen.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/widgets/chunky_outlined_button.dart';
import '../../../../core/theme/app_palette.dart';
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
    final p = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          status: state.status,
          error: state.error,
          onRetry: state.load,
          builder: (_) {
            final profile = state.profile!;
            final name = profile.fullName.isEmpty
                ? AppStrings.student
                : profile.fullName;
            final membership = state.membership;
            Widget setting(
              IconData icon,
              String label,
              SkillColors colors,
              VoidCallback onTap,
            ) => ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: colors.ink),
              ),
              title: Text(label),
              trailing: Icon(Icons.chevron_right, color: p.inkMuted),
              onTap: onTap,
            );
            return RefreshIndicator(
              onRefresh: state.load,
              child: ListView(
                padding: readablePadding(context, top: 24, bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text(
                    AppStrings.profile,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Semantics(
                        label: AppStrings.changeAvatar,
                        button: true,
                        child: InkWell(
                          key: const Key('change_avatar'),
                          onTap: state.uploadingAvatar ? null : _pickAvatar,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 88,
                            height: 88,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                UserAvatar(
                                  url: state.avatarUrl,
                                  name: name,
                                  radius: 42,
                                  colors: p.writing,
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
                                    radius: 18,
                                    backgroundColor: p.primary,
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                      color: p.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: theme.textTheme.titleLarge),
                            Text(
                              profile.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _stat(
                        context,
                        state.stats?.streak,
                        AppStrings.dayStreak,
                        reward: true,
                      ),
                      _stat(
                        context,
                        state.stats?.attempts,
                        AppStrings.attempts,
                      ),
                      _stat(context, state.stats?.words, AppStrings.words),
                    ],
                  ),
                  if (state.statsError != null) Text(state.statsError!),
                  const SizedBox(height: 16),
                  OutlinedCard(
                    color: p.primary,
                    borderColor: p.primary,
                    edgeColor: p.primaryEdge,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const MembershipScreen(),
                        ),
                      );
                      if (context.mounted) state.load();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          size: 28,
                          color: p.onPrimary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                membership == null
                                    ? AppStrings.membershipUnavailable
                                    : membership.hasMembership
                                    ? AppStrings.activeMembership
                                    : AppStrings.noMembership,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: p.onPrimary,
                                ),
                              ),
                              Text(
                                state.membershipError ??
                                    (membership?.endsAt == null
                                        ? AppStrings.quizMembershipRequired
                                        : AppStrings.membershipExpires(
                                            DateFormat.yMd('vi').format(
                                              membership!.endsAt!.toLocal(),
                                            ),
                                          )),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: p.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: p.onPrimary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        setting(
                          Icons.edit_outlined,
                          AppStrings.editProfile,
                          p.speaking,
                          () {
                            state.clearError();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 2),
                        setting(
                          Icons.lock_outline,
                          AppStrings.changePassword,
                          p.writing,
                          () {
                            state.clearError();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 2),
                        setting(
                          Icons.bookmark_border,
                          AppStrings.vocabulary,
                          p.listening,
                          () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const VocabularyScreen(),
                              ),
                            );
                            if (mounted) await state.load();
                          },
                        ),
                        const Divider(height: 2),
                        setting(
                          Icons.notifications_outlined,
                          AppStrings.studyReminder,
                          p.speaking,
                          () =>
                              Navigator.of(context)
                                  .pushNamed('/settings/reminder'),
                        ),
                        const Divider(height: 2),
                        setting(
                          Icons.history,
                          AppStrings.quizHistory,
                          p.writing,
                          () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const QuizHistoryScreen(),
                            ),
                          ),
                        ),
                        const Divider(height: 2),
                        setting(
                          Icons.auto_awesome_outlined,
                          AppStrings.aiPracticeTitle,
                          p.writing,
                          () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AiExamHubScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ChunkyOutlinedButton(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    },
                    child: Text(
                      AppStrings.logout,
                      style: TextStyle(color: p.error),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    int? count,
    String label, {
    bool reward = false,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: StatTile(
        value: count?.toString() ?? AppStrings.unavailableValue,
        label: label,
        reward: reward,
      ),
    ),
  );
}
