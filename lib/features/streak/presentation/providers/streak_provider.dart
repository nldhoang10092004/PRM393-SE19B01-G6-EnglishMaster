import 'package:flutter/foundation.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/models/streak_status.dart';
import '../../data/streak_repository.dart';

/// State of the streak card on the home dashboard.
class StreakProvider extends ChangeNotifier {
  StreakProvider(this._repository);

  final StreakRepository _repository;

  ViewStatus _status = ViewStatus.idle;
  StreakStatus _streak = StreakStatus.empty;
  String? _error;

  /// Loading status of the streak data.
  ViewStatus get status => _status;
  /// Current study streak information.
  StreakStatus get streak => _streak;
  /// Last error message, or null.
  String? get error => _error;

  /// Loads the streak. The previous value stays visible on refresh failures.
  Future<void> load() async {
    if (_status == ViewStatus.idle) {
      _status = ViewStatus.loading;
      notifyListeners();
    }
    try {
      _streak = await _repository.fetchStreak();
      _error = null;
      _status = ViewStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = ViewStatus.error;
    } catch (e) {
      _error = AppStrings.unexpectedError;
      _status = ViewStatus.error;
    }
    notifyListeners();
  }
}
