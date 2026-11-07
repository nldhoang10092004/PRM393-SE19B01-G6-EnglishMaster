import '../../../../core/utils/json_utils.dart';

/// A purchasable membership plan.
class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.durationDays,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> j) => MembershipPlan(
    id: j.asInt('planID'),
    code: j.asString('planCode'),
    name: j.asString('name'),
    price: j.asDouble('price'),
    durationDays: j.asInt('durationDays'),
  );

  final int id;
  final String code;
  final String name;
  final double price;
  final int durationDays;

  double get pricePerDay => durationDays > 0 ? price / durationDays : price;
}

/// Current membership of the signed-in student.
class MembershipInfo {
  const MembershipInfo({
    this.hasMembership = false,
    this.startsAt,
    this.endsAt,
    this.planName,
    this.status,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> j) => MembershipInfo(
    hasMembership: j.asBool('hasMembership'),
    startsAt: j.asDate('startsAt')?.toLocal(),
    endsAt: j.asDate('endsAt')?.toLocal(),
    planName: j.asStringOrNull('planName'),
    status: j.asStringOrNull('status'),
  );

  final bool hasMembership;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? planName;
  final String? status;
}

/// Result of POST /api/payment/validate-voucher.
class VoucherResult {
  const VoucherResult({
    required this.code,
    required this.voucherId,
    required this.discountAmount,
    required this.originalPrice,
    required this.finalPrice,
  });

  factory VoucherResult.fromJson(
    Map<String, dynamic> j, {
    required String code,
  }) => VoucherResult(
    code: code,
    voucherId: j.asInt('voucherId'),
    discountAmount: j.asDouble('discountAmount'),
    originalPrice: j.asDouble('originalPrice'),
    finalPrice: j.asDouble('finalPrice'),
  );

  final String code;
  final int voucherId;
  final double discountAmount;
  final double originalPrice;
  final double finalPrice;
}

/// A freshly created PayOS order.
class PaymentOrder {
  const PaymentOrder({
    required this.orderId,
    required this.orderCode,
    required this.paymentUrl,
    required this.qrCode,
    required this.amount,
    required this.description,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> j) => PaymentOrder(
    orderId: j.asInt('orderId'),
    orderCode: j.asString('orderCode'),
    paymentUrl: j.asString('paymentUrl'),
    qrCode: j.asString('qrCode'),
    amount: j.asDouble('amount'),
    description: j.asString('description'),
  );

  final int orderId;
  final String orderCode;
  final String paymentUrl;
  final String qrCode;
  final double amount;
  final String description;
}

enum PaymentState { pending, paid, canceled }

/// Result of GET /api/payment/status/{orderId}.
class PaymentStatus {
  const PaymentStatus({
    required this.orderId,
    required this.state,
    this.paidAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> j) => PaymentStatus(
    orderId: j.asInt('orderId'),
    state: switch (j.asString('status').toUpperCase()) {
      'PAID' => PaymentState.paid,
      'CANCELED' || 'CANCELLED' => PaymentState.canceled,
      _ => PaymentState.pending,
    },
    paidAt: j.asDate('paidAt')?.toLocal(),
  );

  final int orderId;
  final PaymentState state;
  final DateTime? paidAt;
}
