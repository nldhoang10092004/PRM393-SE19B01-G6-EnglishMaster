import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:english_master/app.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/storage/token_storage.dart';
import 'package:english_master/features/auth/data/auth_repository.dart';
import 'package:english_master/features/auth/presentation/providers/auth_provider.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';
import 'package:english_master/features/streak/presentation/providers/streak_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

/// Every API call fails fast; the test only cares about provider lifetimes.
class _OfflineAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString('{}', 500);

  @override
  void close({bool force = false}) {}
}

void main() {
  setUpAll(() => initializeDateFormatting('vi'));

  testWidgets('logging out drops every provider holding account data', (
    tester,
  ) async {
    final storage = InMemoryTokenStorage();
    await storage.save(accessToken: 'token-a', accountId: 1, role: 'STUDENT');
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _OfflineAdapter();
    final api = ApiClient(tokenStorage: storage, dio: dio);

    await tester.pumpWidget(
      EnglishMasterApp(
        apiClient: api,
        authRepository: AuthRepository(api: api, storage: storage),
      ),
    );
    // Real network futures (Dio) only complete outside the fake-async zone,
    // and the home screen has looping animations, so pump in bounded steps.
    Future<void> settle() async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await settle();

    BuildContext appContext() => tester.element(find.byType(AuthGate));
    expect(appContext().read<AuthProvider>().status, AuthStatus.authenticated);
    final profileA = appContext().read<ProfileProvider>();
    final streakA = appContext().read<StreakProvider>();

    await tester.runAsync(() => appContext().read<AuthProvider>().logout());
    await settle();

    expect(
      appContext().read<AuthProvider>().status,
      AuthStatus.unauthenticated,
    );
    expect(appContext().read<ProfileProvider>(), isNot(same(profileA)));
    expect(appContext().read<StreakProvider>(), isNot(same(streakA)));
    // The old instances were disposed, so they can no longer be listened to.
    expect(() => profileA.addListener(() {}), throwsFlutterError);
    expect(tester.takeException(), isNull);
  });
}
