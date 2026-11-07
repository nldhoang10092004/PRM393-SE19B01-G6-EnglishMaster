import 'package:english_master/features/membership/data/membership_repository.dart';
import 'package:english_master/features/membership/data/models/membership_models.dart';
import 'package:english_master/features/membership/membership_strings.dart';
import 'package:english_master/features/membership/presentation/providers/membership_provider.dart';
import 'package:english_master/features/membership/presentation/screens/membership_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repo extends Mock implements MembershipRepository {}

void main() {
  testWidgets('renders plans, current membership and best value', (
    tester,
  ) async {
    final repo = _Repo();
    when(() => repo.plans()).thenAnswer(
      (_) async => const [
        MembershipPlan(
          id: 1,
          code: 'M',
          name: 'Gói tháng',
          price: 2000,
          durationDays: 30,
        ),
        MembershipPlan(
          id: 2,
          code: 'Y',
          name: 'Gói năm',
          price: 10000,
          durationDays: 365,
        ),
      ],
    );
    when(() => repo.current()).thenAnswer(
      (_) async => MembershipInfo(
        hasMembership: true,
        endsAt: DateTime(2030, 1, 2),
        planName: 'Gói tháng',
      ),
    );
    final state = MembershipProvider(repo);
    addTearDown(state.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: MembershipScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gói tháng'), findsWidgets);
    expect(find.text('Gói năm'), findsOneWidget);
    expect(find.text('2.000đ'), findsOneWidget);
    expect(find.text(MembershipStrings.bestValue), findsOneWidget);
    expect(
      find.text(MembershipStrings.activeUntil('02/01/2030')),
      findsOneWidget,
    );
    expect(find.textContaining(MembershipStrings.pay), findsOneWidget);
  });

  testWidgets('shows "Chưa có gói" without membership', (tester) async {
    final repo = _Repo();
    when(() => repo.plans()).thenAnswer((_) async => const []);
    when(() => repo.current()).thenAnswer((_) async => const MembershipInfo());
    final state = MembershipProvider(repo);
    addTearDown(state.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: MembershipScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(MembershipStrings.noMembership), findsOneWidget);
    expect(find.text(MembershipStrings.noPlans), findsOneWidget);
  });
}
