import 'package:english_master/features/membership/data/membership_repository.dart';
import 'package:english_master/features/membership/data/models/membership_models.dart';
import 'package:english_master/features/membership/membership_strings.dart';
import 'package:english_master/features/membership/presentation/providers/membership_provider.dart';
import 'package:english_master/features/membership/presentation/screens/payment_qr_screen.dart';
import 'package:english_master/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'dart:ui' as ui;

import 'package:english_master/core/utils/qr_gallery.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo extends Mock implements MembershipRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('gal');
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );
  testWidgets('gallery export is a 1024 PNG with a white quiet zone', (
    tester,
  ) async {
    Uint8List? saved;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'hasAccess' || call.method == 'requestAccess') {
            return true;
          }
          if (call.method == 'putImageBytes') {
            saved = (call.arguments as Map)['bytes'] as Uint8List;
          }
          return null;
        });
    await tester.runAsync(() async {
      expect(await QrGallery.save('PayOS-real-order-content'), isTrue);
    });
    expect(saved, isNotNull);
    expect(saved!.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(saved!);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1024);
      expect(frame.image.height, 1024);
      final rgba = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      expect(rgba!.buffer.asUint8List().take(4), [255, 255, 255, 255]);
      frame.image.dispose();
      codec.dispose();
    });
  });
  testWidgets('denied permission never writes to the gallery', (tester) async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return false;
        });
    expect(await QrGallery.save('PayOS'), isFalse);
    expect(calls, ['hasAccess', 'requestAccess']);
  });
  for (final longPress in [false, true]) {
    testWidgets(
      longPress
          ? 'holding QR saves PNG and shows success'
          : 'save QR button saves PNG and shows success',
      (tester) async {
        var writes = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              if (call.method == 'hasAccess' ||
                  call.method == 'requestAccess') {
                return true;
              }
              if (call.method == 'putImageBytes') writes++;
              return null;
            });
        final repo = _Repo();
        when(() => repo.status(1)).thenAnswer(
          (_) async =>
              const PaymentStatus(orderId: 1, state: PaymentState.pending),
        );
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<MembershipRepository>.value(value: repo),
              ChangeNotifierProvider(create: (_) => MembershipProvider(repo)),
            ],
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const PaymentQrScreen(
                order: PaymentOrder(
                  orderId: 1,
                  orderCode: '123',
                  paymentUrl: 'https://example.test',
                  qrCode: 'PayOS-order',
                  amount: 99000,
                  description: 'Gói tháng',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (longPress) {
          await tester.longPress(find.byKey(const Key('payment_qr_image')));
        } else {
          await tester.tap(find.byKey(const Key('save_payment_qr')));
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pumpAndSettle();
        expect(writes, 1);
        expect(find.text(MembershipStrings.savedQr), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text(MembershipStrings.iHavePaid),
          180,
        );
        expect(find.text(MembershipStrings.cancelOrder), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      },
    );
  }
}
