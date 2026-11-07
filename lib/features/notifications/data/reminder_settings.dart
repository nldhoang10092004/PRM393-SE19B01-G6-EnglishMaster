import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted study-reminder preferences (enabled flag + time of day).
class ReminderSettings {
  const ReminderSettings({
    this.enabled = false,
    this.time = const TimeOfDay(hour: 20, minute: 0),
  });

  static const _enabledKey = 'reminder_enabled';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';

  final bool enabled;
  final TimeOfDay time;

  /// Returns a copy with the given enabled flag or reminder time.
  ReminderSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );

  /// Reads the saved settings (defaults: disabled, 20:00).
  static Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      time: TimeOfDay(
        hour: prefs.getInt(_hourKey) ?? 20,
        minute: prefs.getInt(_minuteKey) ?? 0,
      ),
    );
  }

  /// Writes these settings to shared_preferences.
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    await prefs.setInt(_hourKey, time.hour);
    await prefs.setInt(_minuteKey, time.minute);
  }
}
