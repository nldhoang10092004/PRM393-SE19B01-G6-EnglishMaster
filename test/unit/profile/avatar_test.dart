import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/core/network/api_client.dart';
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/storage/token_storage.dart';
import 'package:english_master/features/profile/data/profile_repository.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _Repository extends Mock implements ProfileRepository {}

class _Api extends Mock implements ApiClient {}

class _UploadAdapter implements HttpClientAdapter {
  final uploads = <String>[];
  final tokens = <Object?>[];
  final forms = <FormData>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/api/auth/refresh') {
      return ResponseBody.fromString(
        '{"accessToken":"fresh","accountID":4}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    expect(options.method, 'PUT');
    expect(options.path, '/api/user/profile/avatar');
    expect(options.sendTimeout, const Duration(seconds: 90));
    expect(options.receiveTimeout, const Duration(seconds: 90));
    forms.add(options.data as FormData);
    final bytes = await requestStream!.expand((chunk) => chunk).toList();
    uploads.add(String.fromCharCodes(bytes));
    tokens.add(options.headers['Authorization']);
    return ResponseBody.fromString(
      uploads.length == 1 ? '{}' : '{"avatarUrl":"/avatars/new.jpg"}',
      uploads.length == 1 ? 401 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'PUT uploads File as an image and replays its stream after token refresh',
    () async {
      final directory = await Directory.systemTemp.createTemp('avatar_test');
      addTearDown(() => directory.delete(recursive: true));
      final file = await File('${directory.path}/avatar.jpg')
          .writeAsString('image-payload');
      final storage = InMemoryTokenStorage();
      await storage.save(accessToken: 'expired', accountId: 4);
      final adapter = _UploadAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));
      final api = ApiClient(tokenStorage: storage, dio: dio);
      final result = await ProfileRepository(api).uploadAvatar(file.path);
      expect(result, '/avatars/new.jpg');
      expect(adapter.tokens, ['Bearer expired', 'Bearer fresh']);
      expect(adapter.forms[0], isNot(same(adapter.forms[1])));
      for (final payload in adapter.uploads) {
        expect(payload, contains('name="File"; filename="avatar.jpg"'));
        expect(payload, contains('content-type: image/jpeg'));
        expect(payload, contains('image-payload'));
      }
    },
  );

  test('repository rejects a successful response without avatarUrl', () async {
    final api = _Api();
    when(
      () => api.putMultipart(
        any(),
        fileField: any(named: 'fileField'),
        filePath: any(named: 'filePath'),
      ),
    ).thenAnswer((_) async => <String, dynamic>{});
    await expectLater(
      ProfileRepository(api).uploadAvatar('photo.jpg'),
      throwsFormatException,
    );
  });

  test('provider publishes busy state, prevents duplicate uploads and updates avatar', () async {
    final repository = _Repository();
    final state = ProfileProvider(repository)..avatarUrl = '/old.jpg';
    addTearDown(state.dispose);
    final completion = Completer<String>();
    when(() => repository.uploadAvatar('photo.jpg'))
        .thenAnswer((_) => completion.future);
    final notifications = <bool>[];
    state.addListener(() => notifications.add(state.uploadingAvatar));
    final upload = state.uploadAvatar('photo.jpg');
    expect(state.uploadingAvatar, isTrue);
    expect(await state.uploadAvatar('photo.jpg'), isFalse);
    completion.complete('/new.jpg');
    expect(await upload, isTrue);
    expect(state.avatarUrl, '/new.jpg');
    expect(state.avatarError, isNull);
    expect(notifications, [true, false]);
    verify(() => repository.uploadAvatar('photo.jpg')).called(1);
  });

  test(
    'upload failure retains avatar and exposes a friendly Vietnamese message',
    () async {
      final repository = _Repository();
      final state = ProfileProvider(repository)..avatarUrl = '/old.jpg';
      addTearDown(state.dispose);
      when(() => repository.uploadAvatar(any()))
          .thenThrow(ApiException('Internal storage error'));
      expect(await state.uploadAvatar('photo.jpg'), isFalse);
      expect(state.avatarUrl, '/old.jpg');
      expect(state.uploadingAvatar, isFalse);
      expect(state.avatarError, AppStrings.avatarUploadError);
    },
  );

  test('disposing during upload suppresses notifications safely', () async {
    final repository = _Repository();
    final state = ProfileProvider(repository);
    final completion = Completer<String>();
    when(() => repository.uploadAvatar(any()))
        .thenAnswer((_) => completion.future);
    final upload = state.uploadAvatar('photo.jpg');
    state.dispose();
    completion.complete('/new.jpg');
    expect(await upload, isTrue);
  });
}
