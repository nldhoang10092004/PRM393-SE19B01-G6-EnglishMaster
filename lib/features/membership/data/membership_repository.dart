import '../../../core/network/api_client.dart';
import '../../../core/utils/json_utils.dart';
import 'models/membership_models.dart';

/// Maps membership and PayOS payment endpoints.
class MembershipRepository {
  MembershipRepository(this._api);
  final ApiClient _api;

  Future<List<MembershipPlan>> plans() async =>
      asMapList(await _api.get('/api/public/plan'))
          .map(MembershipPlan.fromJson)
          .toList();

  Future<MembershipInfo> current() async => MembershipInfo.fromJson(
    Map<String, dynamic>.from(
      await _api.get('/api/user/membership/check') as Map,
    ),
  );

  Future<VoucherResult> validateVoucher(String code, int planId) async =>
      VoucherResult.fromJson(
        Map<String, dynamic>.from(
          await _api.post(
            '/api/payment/validate-voucher',
            body: {'code': code, 'planId': planId},
          ) as Map,
        ),
        code: code,
      );

  Future<PaymentOrder> createPayment(int planId, {String? voucherCode}) async {
    final query = <String, dynamic>{'planId': planId};
    if (voucherCode != null && voucherCode.isNotEmpty) {
      query['voucherCode'] = voucherCode;
    }
    final data = await _api.post('/api/payment/create', query: query);
    return PaymentOrder.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<PaymentStatus> status(int orderId) async => PaymentStatus.fromJson(
    Map<String, dynamic>.from(
      await _api.get('/api/payment/status/$orderId') as Map,
    ),
  );
}
