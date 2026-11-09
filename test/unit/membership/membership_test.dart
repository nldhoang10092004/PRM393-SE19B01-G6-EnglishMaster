import 'dart:async';

import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:english_master/core/network/api_exception.dart';
import 'package:english_master/core/widgets/async_view.dart';
import 'package:english_master/features/membership/data/membership_repository.dart';
import 'package:english_master/features/membership/data/models/membership_models.dart';
import 'package:english_master/features/membership/presentation/providers/membership_provider.dart';
import 'package:english_master/features/membership/presentation/providers/payment_status_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class FakeRepo extends Mock implements MembershipRepository {}

const monthly = MembershipPlan(
  id: 1,
  code: 'M',
  name: 'Tháng',
  price: 30000,
  durationDays: 30,
);
const yearly = MembershipPlan(
  id: 2,
  code: 'Y',
  name: 'Năm',
  price: 200000,
  durationDays: 365,
);

const order = PaymentOrder(
  orderId: 9,
  orderCode: '123',
  paymentUrl: 'https://pay.example',
  qrCode: '0002',
  amount: 2000,
  description: 'DEVORA',
);

PaymentStatus st(PaymentState s) => PaymentStatus(orderId: 9, state: s);

void main() {
  group('models', () {
    test('plan parses case-insensitively', () {
      final p = MembershipPlan.fromJson({
        'planId': 3,
        'planCode': 'X',
        'name': 'A',
        'price': 2000.0,
        'durationDays': 10,
      });
      expect(p.id, 3);
      expect(p.pricePerDay, 200);
    });

    test('membership info parses', () {
      final m = MembershipInfo.fromJson({
        'hasMembership': true,
        'endsAt': '2030-01-02T00:00:00Z',
        'planName': 'Tháng',
        'status': 'ACTIVE',
      });
      expect(m.hasMembership, isTrue);
      expect(m.endsAt, isNotNull);
      expect(MembershipInfo.fromJson({'hasMembership': false}).endsAt, isNull);
    });

    test('payment order and status parse', () {
      final o = PaymentOrder.fromJson({
        'orderId': 5,
        'orderCode': 77,
        'paymentUrl': 'u',
        'qrCode': 'q',
        'amount': 2000.0,
        'description': 'd',
      });
      expect(o.orderCode, '77');
      expect(o.amount, 2000);
      expect(
        PaymentStatus.fromJson({
          'orderId': 5,
          'status': 'PAID',
          'paidAt': '2030-01-01T00:00:00Z',
        }).state,
        PaymentState.paid,
      );
      expect(
        PaymentStatus.fromJson({'orderId': 5, 'status': 'CANCELED'}).state,
        PaymentState.canceled,
      );
      expect(
        PaymentStatus.fromJson({'orderId': 5, 'status': 'PENDING'}).state,
        PaymentState.pending,
      );
    });

    test('voucher parses', () {
      final v = VoucherResult.fromJson({
        'voucherId': 1,
        'discountAmount': 500,
        'originalPrice': 2000,
        'finalPrice': 1500,
      }, code: 'ABC');
      expect(v.finalPrice, 1500);
      expect(v.code, 'ABC');
    });
  });

  group('MembershipProvider', () {
    late FakeRepo repo;
    late MembershipProvider provider;
    setUp(() {
      repo = FakeRepo();
      provider = MembershipProvider(repo);
      when(() => repo.plans()).thenAnswer((_) async => [monthly, yearly]);
      when(() => repo.current())
          .thenAnswer((_) async => const MembershipInfo());
    });

    test('load selects best value plan', () async {
      await provider.load();
      expect(provider.status, ViewStatus.success);
      expect(provider.bestValue?.id, 2);
      expect(provider.selected?.id, 2);
    });

    test('load error exposes message', () async {
      when(() => repo.plans()).thenThrow(ApiException('lỗi'));
      await provider.load();
      expect(provider.status, ViewStatus.error);
      expect(provider.error, 'lỗi');
    });

    test('voucher applies and resets when plan changes', () async {
      await provider.load();
      when(() => repo.validateVoucher('ABC', 2)).thenAnswer(
        (_) async => const VoucherResult(
          code: 'ABC',
          voucherId: 1,
          discountAmount: 1000,
          originalPrice: 200000,
          finalPrice: 199000,
        ),
      );
      await provider.applyVoucher(' ABC ');
      expect(provider.payable, 199000);
      provider.select(monthly);
      expect(provider.voucher, isNull);
      expect(provider.payable, 30000);
    });

    test('invalid voucher shows server message', () async {
      await provider.load();
      when(() => repo.validateVoucher('BAD', 2))
          .thenThrow(ApiException('Mã không hợp lệ'));
      await provider.applyVoucher('BAD');
      expect(provider.voucher, isNull);
      expect(provider.voucherError, 'Mã không hợp lệ');
    });

    test('createPayment passes voucher and reports errors', () async {
      await provider.load();
      when(() => repo.createPayment(2, voucherCode: null))
          .thenAnswer((_) async => order);
      expect((await provider.createPayment())?.orderId, 9);
      when(() => repo.createPayment(2, voucherCode: null))
          .thenThrow(ApiException('Hết hàng'));
      expect(await provider.createPayment(), isNull);
      expect(provider.createError, 'Hết hàng');
      expect(provider.creating, isFalse);
    });
  });

  group('PaymentStatusProvider', () {
    late FakeRepo repo;
    setUp(() => repo = FakeRepo());

    PaymentStatusProvider make({
      VoidCallback? onPaid,
      Duration lifetime = const Duration(seconds: 30),
    }) => PaymentStatusProvider(
      repo,
      9,
      lifetime: lifetime,
      pollInterval: const Duration(milliseconds: 20),
      tick: const Duration(milliseconds: 10),
      onPaid: onPaid,
    );

    test('polling stops after PAID and notifies once', () async {
      var paid = 0;
      var calls = 0;
      when(() => repo.status(9)).thenAnswer((_) async {
        calls++;
        return st(calls >= 3 ? PaymentState.paid : PaymentState.pending);
      });
      final p = make(onPaid: () => paid++)..start();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(p.phase, PaymentPhase.paid);
      expect(calls, 3);
      expect(paid, 1);
      p.dispose();
    });

    test('canceled stops polling', () async {
      when(() => repo.status(9))
          .thenAnswer((_) async => st(PaymentState.canceled));
      final p = make()..start();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(p.phase, PaymentPhase.canceled);
      verify(() => repo.status(9)).called(1);
      p.dispose();
    });

    test('countdown end expires and stops polling', () async {
      when(() => repo.status(9))
          .thenAnswer((_) async => st(PaymentState.pending));
      final p = make(lifetime: const Duration(milliseconds: 50))..start();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(p.phase, PaymentPhase.expired);
      expect(p.countdownText, '00:00');
      clearInteractions(repo);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verifyNever(() => repo.status(9));
      p.dispose();
    });

    test('manual check while pending shows hint', () async {
      when(() => repo.status(9))
          .thenAnswer((_) async => st(PaymentState.pending));
      final p = make();
      await p.check();
      expect(p.message, isNotNull);
      expect(p.phase, PaymentPhase.waiting);
      p.dispose();
    });

    test(
      'background poll never puts the confirm button in busy state',
      () async {
        final reply = Completer<PaymentStatus>();
        when(() => repo.status(9)).thenAnswer((_) => reply.future);
        final p = make();
        unawaited(p.check(silent: true));
        expect(p.checking, isTrue);
        expect(p.confirming, isFalse); // button still says "Tôi đã thanh toán"
        reply.complete(st(PaymentState.pending));
        await Future<void>.delayed(Duration.zero);
        expect(p.message, isNull);
        p.dispose();
      },
    );

    test('tap during a background poll reports that poll\'s answer', () async {
      final reply = Completer<PaymentStatus>();
      when(() => repo.status(9)).thenAnswer((_) => reply.future);
      final p = make();
      unawaited(p.check(silent: true));
      await p.check(); // user taps while the poll is in flight
      expect(p.confirming, isTrue);
      reply.complete(st(PaymentState.pending));
      await Future<void>.delayed(Duration.zero);
      expect(p.confirming, isFalse);
      expect(p.message, isNotNull);
      verify(() => repo.status(9)).called(1);
      p.dispose();
    });

    test('countdown text starts at 15:00 by default', () {
      final p = PaymentStatusProvider(repo, 9);
      expect(p.countdownText, '15:00');
      p.dispose();
    });
  });
}
