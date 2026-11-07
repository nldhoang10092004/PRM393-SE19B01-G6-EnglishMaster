import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/notifications/presentation/screens/reminder_settings_screen.dart';

/// Named routes of the app.
///
/// Screens that need arguments read them from `RouteSettings.arguments`
/// (see each route's comment for the expected type).
class AppRoutes {
  AppRoutes._();

  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const reminderSettings = reminderSettingsRoute;

  /// Builds the page for a named route; returns null for unknown names.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Widget? page = switch (settings.name) {
      register => const RegisterScreen(),
      forgotPassword => const ForgotPasswordScreen(),
      reminderSettings => const ReminderSettingsScreen(),
      _ => null,
    };
    if (page == null) return null;
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
