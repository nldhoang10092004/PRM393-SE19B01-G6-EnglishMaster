import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications` for the study reminder.
///
/// * [scheduleDailyReminder] repeats every day at a chosen local time;
/// * [showNow] / [showStreakReminder] display an immediate notification.
///
/// All methods lazily call [init], so callers never need to initialize first.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1001;
  static const int _instantId = 1002;
  static const String _channelId = 'study_reminder';
  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      'Study reminders',
      channelDescription: 'Daily reminder to practice English',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Initializes the plugin and the time zone database (idempotent).
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(_deviceLocation());
    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
    );
    _ready = true;
  }

  /// Picks a tz location whose current UTC offset equals the device offset
  /// (no native time-zone plugin is available). Vietnam (UTC+7) has no DST,
  /// so the schedule stays correct; falls back to UTC.
  tz.Location _deviceLocation() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (location.name.contains('/') && location.timeZone(now.millisecondsSinceEpoch).offset == offset) {
        return location;
      }
    }
    return tz.UTC;
  }

  /// Asks for the Android 13+ notification permission. Returns true if granted.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Schedules (or replaces) the repeating daily reminder at [time] local time.
  /// Uses an inexact alarm, so no exact-alarm permission is needed.
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!first.isAfter(now)) first = first.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      title: 'Time to practice English',
      body: 'A few minutes today keeps your streak alive.',
      scheduledDate: first,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Removes the scheduled daily reminder.
  Future<void> cancelDailyReminder() async {
    await init();
    await _plugin.cancel(id: _dailyReminderId);
  }

  /// Shows a notification immediately.
  Future<void> showNow({required String title, required String body}) async {
    await init();
    await _plugin.show(id: _instantId, title: title, body: body, notificationDetails: _details);
  }

  /// Immediate nudge used when the streak API reports `needsActivityToday`.
  Future<void> showStreakReminder({int currentStreak = 0}) => showNow(
        title: currentStreak > 0 ? "Don't lose your $currentStreak day streak!" : 'Start your learning streak',
        body: 'Study for a few minutes today.',
      );
}
