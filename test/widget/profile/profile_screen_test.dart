import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/features/profile/data/models/user_profile.dart';
import 'package:english_master/features/profile/data/profile_repository.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';
import 'package:english_master/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements ProfileRepository {}

void main() {
  setUpAll(() => initializeDateFormatting('vi'));
  testWidgets(
    'renders fake profile, membership, stats and named reminder route',
    (tester) async {
      final repository = _Repository();
      final state = ProfileProvider(repository);
      addTearDown(state.dispose);
      when(() => repository.detail()).thenAnswer(
        (_) async => const UserProfile(
          accountId: 4,
          fullName: 'Anna Nguyen',
          email: 'anna@example.test',
        ),
      );
      when(() => repository.avatar()).thenAnswer((_) async => null);
      when(() => repository.membership()).thenAnswer(
        (_) async => MembershipStatus(
          hasMembership: true,
          endsAt: DateTime(2026, 12, 31),
        ),
      );
      when(() => repository.stats())
          .thenAnswer((_) async => (streak: 3, attempts: 2, words: 8));
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: state,
          child: MaterialApp(
            home: const ProfileScreen(),
            routes: {
              '/settings/reminder': (_) =>
                  const Scaffold(body: Text(AppStrings.studyReminder)),
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Anna Nguyen'), findsOneWidget);
      expect(find.text('anna@example.test'), findsOneWidget);
      expect(find.text(AppStrings.activeMembership), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      await tester.scrollUntilVisible(find.text(AppStrings.studyReminder), 160);
      await tester.ensureVisible(find.text(AppStrings.studyReminder));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.studyReminder));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.studyReminder), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('profile error exposes Retry and recovers', (tester) async {
    final repository = _Repository();
    final state = ProfileProvider(repository);
    addTearDown(state.dispose);
    when(() => repository.detail()).thenThrow(ApiException('Offline'));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text(AppStrings.retry), findsOneWidget);
    when(() => repository.detail()).thenAnswer(
      (_) async => const UserProfile(accountId: 4, fullName: 'Anna'),
    );
    when(() => repository.avatar()).thenAnswer((_) async => null);
    when(() => repository.membership())
        .thenAnswer((_) async => const MembershipStatus(hasMembership: false));
    when(() => repository.stats())
        .thenAnswer((_) async => (streak: 0, attempts: 0, words: 0));
    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();
    expect(find.text('Anna'), findsOneWidget);
  });
}
