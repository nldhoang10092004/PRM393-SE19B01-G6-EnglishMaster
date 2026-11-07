import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n/app_strings.dart';
import 'core/network/api_client.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/ai_exam/ai_exam_providers.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/course/course_providers.dart';
import 'features/flashcard/flashcard_providers.dart';
import 'features/home/presentation/screens/home_shell.dart';
import 'features/membership/membership_providers.dart';
import 'features/notifications/notifications_providers.dart';
import 'features/profile/profile_providers.dart';
import 'features/quiz/quiz_providers.dart';
import 'features/streak/streak_providers.dart';
import 'features/video/video_providers.dart';
import 'features/vocabulary/vocabulary_providers.dart';

/// Root widget: registers app-wide dependencies with Provider and picks the
/// first screen from the authentication state.
///
/// Dependency graph: Screen -> Provider (ChangeNotifier) -> Repository -> ApiClient.
class EnglishMasterApp extends StatelessWidget {
  const EnglishMasterApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
  });

  final ApiClient apiClient;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final auth = AuthProvider(authRepository);
            apiClient.onSessionExpired = auth.onSessionExpired;
            return auth..bootstrap();
          },
        ),
        // Feature repositories + providers (each feature exposes its own list).
        ...CourseProviders.providers(),
        ...VideoProviders.providers(),
        ...StreakProviders.providers(),
        ...FlashcardProviders.providers(),
        ...VocabularyProviders.providers(),
        ...QuizProviders.providers(),
        ...ProfileProviders.providers(),
        ...NotificationsProviders.providers(),
        ...MembershipProviders.providers(),
        ...AiExamProviders.providers(),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: const AuthGate(),
      ),
    );
  }
}

/// Shows a splash while the saved session loads, then login or the main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((a) => a.status);
    return switch (status) {
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => const HomeShell(),
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}
