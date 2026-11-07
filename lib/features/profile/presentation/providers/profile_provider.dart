import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/user_profile.dart';
import '../../data/profile_repository.dart';

/// Personal details and mutations, with optional avatar/membership failures.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this.repository);
  final ProfileRepository repository;
  ViewStatus status = ViewStatus.idle;
  UserProfile? profile;
  MembershipStatus? membership;
  String? avatarUrl;
  String? error;
  String? avatarError;
  String? membershipError;
  String? statsError;
  ({int streak, int attempts, int words})? stats;
  bool busy = false;
  bool _disposed = false;

  /// Loads required details; secondary failures leave the profile usable.
  Future<void> load() async {
    if (status == ViewStatus.loading || busy) return;
    status = ViewStatus.loading;
    error = null;
    avatarError = null;
    membershipError = null;
    notifyListeners();
    try {
      profile = await repository.detail();
      try {
        avatarUrl = await repository.avatar();
      } on ApiException catch (e) {
        avatarError = e.message;
      } catch (_) {
        avatarError = AppStrings.avatarError;
      }
      try {
        membership = await repository.membership();
      } on ApiException catch (e) {
        membershipError = e.message;
      } catch (_) {
        membershipError = AppStrings.membershipStatusError;
      }
      statsError = null;
      try {
        stats = await repository.stats();
      } on ApiException catch (e) {
        statsError = e.message;
      } catch (_) {
        statsError = AppStrings.statsError;
      }
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = AppStrings.profileLoadError;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Refreshes detail after saving because blank fields are ignored by the API.
  Future<bool> update(UserProfile value) => _run(() async {
    await repository.update(value);
    profile = await repository.detail();
  });

  /// Captures password validation and network errors for the form.
  Future<bool> changePassword(
    String current,
    String password,
    String confirm,
  ) => _run(() => repository.changePassword(current, password, confirm));

  Future<bool> _run(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = AppStrings.saveChangesError;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Clears an earlier mutation's message before opening another form.
  void clearError() {
    error = null;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
