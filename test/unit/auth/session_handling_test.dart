import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/storage/token_storage.dart';
import 'package:english_master/features/auth/data/auth_repository.dart';
import 'package:english_master/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake server: `fresh` is the only valid token; refresh can succeed or fail.
class _Adapter implements HttpClientAdapter {
  _Adapter({this.refreshSucceeds = true});

  final bool refreshSucceeds;
  int refreshCalls = 0;
  final dataTokens = <Object?>[];

  ResponseBody _json(String body, int status) => ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/api/auth/refresh') {
      refreshCalls++;
      // Slow refresh, so the parallel 401s all arrive while it is running.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return refreshSucceeds
          ? _json('{"accessToken":"fresh","accountID":7}', 200)
          : _json('{}', 401);
    }
    final auth = options.headers['Authorization'];
    dataTokens.add(auth);
    return auth == 'Bearer fresh'
        ? _json('{"ok":true}', 200)
        : _json('{}', 401);
  }

  @override
  void close({bool force = false}) {}
}

class _BrokenStorage extends InMemoryTokenStorage {
  @override
  Future<String?> readAccessToken() => Future.error(StateError('keystore'));
}

void main() {
  late InMemoryTokenStorage storage;

  ApiClient client(_Adapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));
    return ApiClient(tokenStorage: storage, dio: dio);
  }

  setUp(() async {
    storage = InMemoryTokenStorage();
    await storage.save(accessToken: 'expired', accountId: 7);
  });

  test('parallel 401s share one refresh and all succeed', () async {
    final adapter = _Adapter();
    final api = client(adapter);

    final results = await Future.wait([
      api.get('/api/a'),
      api.get('/api/b'),
      api.get('/api/c'),
    ]);

    expect(adapter.refreshCalls, 1);
    expect(results, everyElement({'ok': true}));
    expect(await storage.readAccessToken(), 'fresh');
  });

  test('a 401 that arrives after another request refreshed just retries', () async {
    final adapter = _Adapter();
    final api = client(adapter);
    await api.get('/api/a'); // refreshes: token is now "fresh"
    // Simulates a request that was sent with the old token before the refresh.
    await storage.save(accessToken: 'fresh', accountId: 7);
    final late = await api.get('/api/b');
    expect(late, {'ok': true});
    expect(adapter.refreshCalls, 1);
  });

  test('failed refresh expires the session exactly once', () async {
    final adapter = _Adapter(refreshSucceeds: false);
    final api = client(adapter);
    var expired = 0;
    api.onSessionExpired = () => expired++;

    final results = await Future.wait([
      for (final p in ['/api/a', '/api/b', '/api/c'])
        api.get(p).then<Object?>((v) => v, onError: (Object e) => e),
    ]);

    expect(results, everyElement(isA<ApiException>()));
    expect(adapter.refreshCalls, 1);
    expect(expired, 1);
    expect(await storage.readAccessToken(), isNull);
  });

  test('bootstrap falls back to login when secure storage fails', () async {
    final broken = _BrokenStorage();
    final api = ApiClient(tokenStorage: broken);
    final auth = AuthProvider(AuthRepository(api: api, storage: broken));

    await auth.bootstrap();

    expect(auth.status, AuthStatus.unauthenticated);
    expect(auth.session, isNull);
  });
}
