import 'dart:async';

import 'package:english_master/core/l10n/app_strings.dart';
import 'package:english_master/core/theme/app_theme.dart';
import 'package:english_master/core/widgets/user_avatar.dart';
import 'package:english_master/features/home/presentation/widgets/home_greeting.dart';
import 'package:english_master/features/profile/data/models/user_profile.dart';
import 'package:english_master/features/profile/data/profile_repository.dart';
import 'package:english_master/features/profile/presentation/providers/profile_provider.dart';
import 'package:english_master/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class _Repository extends Mock implements ProfileRepository {}

class _Picker extends Mock implements ImagePicker {}

void main() {
  late _Repository repository;
  late _Picker picker;
  late ProfileProvider state;

  setUp(() {
    repository = _Repository();
    picker = _Picker();
    state = ProfileProvider(repository);
    when(() => repository.detail()).thenAnswer(
      (_) async => const UserProfile(
        accountId: 4,
        fullName: 'Nguyễn Minh Anh',
        email: 'anh@example.test',
      ),
    );
    when(() => repository.avatar()).thenAnswer((_) async => null);
    when(() => repository.membership())
        .thenAnswer((_) async => const MembershipStatus(hasMembership: false));
    when(() => repository.stats())
        .thenAnswer((_) async => (streak: 5, attempts: 12, words: 80));
    when(() => picker.retrieveLostData())
        .thenAnswer((_) async => LostDataResponse.empty());
  });

  tearDown(() => state.dispose());

  Future<void> show(WidgetTester tester, {bool greeting = false}) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: greeting
              ? Scaffold(
                  body: Column(
                    children: [
                      const HomeGreeting(),
                      Expanded(child: ProfileScreen(imagePicker: picker)),
                    ],
                  ),
                )
              : ProfileScreen(imagePicker: picker),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final source in ImageSource.values) {
    testWidgets(
      '${source.name} resizes, shows progress and updates profile plus greeting',
      (tester) async {
        final upload = Completer<String>();
        when(
          () =>
              picker.pickImage(source: source, maxWidth: 512, imageQuality: 85),
        ).thenAnswer((_) async => XFile('photo.jpg'));
        when(() => repository.uploadAvatar('photo.jpg'))
            .thenAnswer((_) => upload.future);
        await show(tester, greeting: true);
        await tester.tap(find.byKey(const Key('change_avatar')));
        await tester.pumpAndSettle();
        expect(find.text(AppStrings.choosePhoto), findsOneWidget);
        expect(find.text(AppStrings.takePhoto), findsOneWidget);
        await tester.tap(
          find.text(
            source == ImageSource.gallery
                ? AppStrings.choosePhoto
                : AppStrings.takePhoto,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(state.uploadingAvatar, isTrue);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        upload.complete('https://example.test/avatar.jpg');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(state.uploadingAvatar, isFalse);
        expect(find.text(AppStrings.avatarUpdated), findsOneWidget);
        expect(
          tester
              .widgetList<UserAvatar>(find.byType(UserAvatar))
              .map((a) => a.url),
          everyElement('https://example.test/avatar.jpg'),
        );
        verify(
          () =>
              picker.pickImage(source: source, maxWidth: 512, imageQuality: 85),
        ).called(1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('canceling the picker never uploads', (tester) async {
    when(
      () => picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        imageQuality: 85,
      ),
    ).thenAnswer((_) async => null);
    await show(tester);
    await tester.tap(find.byKey(const Key('change_avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.choosePhoto));
    await tester.pumpAndSettle();
    verifyNever(() => repository.uploadAvatar(any()));
    expect(state.avatarUrl, isNull);
  });

  testWidgets('camera permission failure is shown in Vietnamese', (
    tester,
  ) async {
    when(
      () => picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        imageQuality: 85,
      ),
    ).thenThrow(PlatformException(code: 'camera_access_denied'));
    await show(tester);
    await tester.tap(find.byKey(const Key('change_avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.takePhoto));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.photoPickerError), findsOneWidget);
    verifyNever(() => repository.uploadAvatar(any()));
  });

  testWidgets('Android recovers an image after activity destruction', (
    tester,
  ) async {
    when(() => picker.retrieveLostData()).thenAnswer(
      (_) async => LostDataResponse(files: [XFile('recovered.jpg')]),
    );
    when(() => repository.uploadAvatar('recovered.jpg'))
        .thenAnswer((_) async => '/recovered.jpg');
    await show(tester);
    expect(state.avatarUrl, '/recovered.jpg');
    verify(() => repository.uploadAvatar('recovered.jpg')).called(1);
  });
}
