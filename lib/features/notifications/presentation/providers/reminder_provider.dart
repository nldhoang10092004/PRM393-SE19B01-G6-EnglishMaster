import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../data/notification_service.dart';
import '../../data/reminder_settings.dart';

/// State of the study-reminder settings screen.
class ReminderProvider extends ChangeNotifier {
  ReminderProvider(this._service);

  final NotificationService _service;

  ReminderSettings _settings = const ReminderSettings();
  bool _loaded = false;
  String? _error;

  /// Current reminder settings.
  ReminderSettings get settings => _settings;
  /// Whether saved reminder settings have been loaded.
  bool get isLoaded => _loaded;

  /// Last error (e.g. permission denied), null when none.
  String? get error => _error;

  /// Reads saved settings and re-applies the schedule when enabled.
  Future<void> load() async {
    _settings = await ReminderSettings.load();
    _loaded = true;
    notifyListeners();
    if (_settings.enabled) {
      try {
        await _service.scheduleDailyReminder(_settings.time);
      } catch (_) {
        // Scheduling is best-effort at startup.
      }
    }
  }

  /// Turns the reminder on/off. Enabling asks for notification permission;
  /// when denied the switch stays off and [error] explains why.
  Future<void> setEnabled(bool value) async {
    _error = null;
    try {
      if (value) {
        if (!await _service.requestPermission()) {
          _error = AppStrings.permissionDenied;
          notifyListeners();
          return;
        }
        await _service.scheduleDailyReminder(_settings.time);
      } else {
        await _service.cancelDailyReminder();
      }
      _settings = _settings.copyWith(enabled: value);
      await _settings.save();
    } catch (e) {
      _error = AppStrings.reminderUpdateError;
    }
    notifyListeners();
  }

  /// Changes the reminder time and reschedules when enabled.
  Future<void> setTime(TimeOfDay time) async {
    _error = null;
    _settings = _settings.copyWith(time: time);
    try {
      await _settings.save();
      if (_settings.enabled) await _service.scheduleDailyReminder(time);
    } catch (e) {
      _error = AppStrings.reminderUpdateError;
    }
    notifyListeners();
  }

  /// Shows an immediate notification so the user can verify permissions.
  Future<void> sendTest() async {
    _error = null;
    try {
      if (!await _service.requestPermission()) {
        _error = AppStrings.permissionDenied;
      } else {
        await _service.showNow(
          title: AppStrings.appName,
          body: AppStrings.testReminder,
        );
      }
    } catch (e) {
      _error = AppStrings.notificationShowError;
    }
    notifyListeners();
  }
}
