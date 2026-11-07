import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/streak/data/models/streak_status.dart';
import 'package:english_master/features/streak/data/streak_repository.dart';
import 'package:english_master/features/streak/presentation/providers/streak_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeRepo extends Mock implements StreakRepository {}

void main() {
  test('StreakStatus.fromJson parses StreakResponse', () {
    final s = StreakStatus.fromJson({
      'currentStreak': 4,
      'lastActivityDate': '2026-11-06',
      'needsActivityToday': true,
      'message': 'm',
    });
    expect(s.currentStreak, 4);
    expect(s.lastActivityDate?.day, 6);
    expect(s.needsActivityToday, true);
  });

  test('StreakProvider: success and error transitions', () async {
    final repo = _FakeRepo();
    when(() => repo.fetchStreak())
        .thenAnswer((_) async => const StreakStatus(currentStreak: 2, needsActivityToday: false, message: ''));
    final p = StreakProvider(repo);
    expect(p.status, ViewStatus.idle);
    await p.load();
    expect(p.status, ViewStatus.success);
    expect(p.streak.currentStreak, 2);
    when(() => repo.fetchStreak()).thenThrow(ApiException('down'));
    await p.load();
    expect(p.status, ViewStatus.error);
    expect(p.error, 'down');
  });
}
