import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/async_view.dart';
import '../../data/membership_repository.dart';
import '../../data/models/membership_models.dart';
import '../../membership_strings.dart';

/// Plans, current membership, voucher state and payment creation.
class MembershipProvider extends ChangeNotifier {
  MembershipProvider(this.repository);
  final MembershipRepository repository;

  ViewStatus status = ViewStatus.idle;
  String? error;
  List<MembershipPlan> plans = [];
  MembershipInfo current = const MembershipInfo();
  MembershipPlan? selected;

  VoucherResult? voucher;
  String? voucherError;
  bool applyingVoucher = false;

  bool creating = false;
  String? createError;
  bool _disposed = false;

  /// Loads plans and the current membership together.
  Future<void> load() async {
    if (status == ViewStatus.loading) return;
    status = ViewStatus.loading;
    error = null;
    notifyListeners();
    try {
      final loadedPlans = await repository.plans();
      final loadedCurrent = await repository.current();
      plans = loadedPlans;
      current = loadedCurrent;
      if (selected == null || !plans.any((p) => p.id == selected!.id)) {
        selected = bestValue ?? (plans.isEmpty ? null : plans.first);
      }
      status = ViewStatus.success;
    } on ApiException catch (e) {
      error = e.message;
      status = ViewStatus.error;
    } catch (_) {
      error = MembershipStrings.loadError;
      status = ViewStatus.error;
    }
    notifyListeners();
  }

  /// Re-reads only the membership (after a successful payment).
  Future<void> refreshCurrent() async {
    try {
      current = await repository.current();
      notifyListeners();
    } catch (_) {}
  }

  /// Regular plan (30+ days) with the lowest per-day price; null with fewer than two.
  /// Short trial plans are excluded so a cheap trial is never labelled "best value".
  MembershipPlan? get bestValue {
    final regular = plans.where((p) => p.durationDays >= 30).toList();
    if (regular.length < 2) return null;
    return regular.reduce((a, b) => b.pricePerDay < a.pricePerDay ? b : a);
  }

  void select(MembershipPlan plan) {
    if (selected?.id == plan.id) return;
    selected = plan;
    clearVoucher();
  }

  void clearVoucher() {
    voucher = null;
    voucherError = null;
    notifyListeners();
  }

  /// Price after the applied voucher.
  double get payable => voucher?.finalPrice ?? selected?.price ?? 0;

  Future<void> applyVoucher(String rawCode) async {
    final plan = selected;
    final code = rawCode.trim();
    if (plan == null) {
      voucherError = MembershipStrings.selectPlanFirst;
      notifyListeners();
      return;
    }
    if (code.isEmpty || applyingVoucher) return;
    applyingVoucher = true;
    voucherError = null;
    notifyListeners();
    try {
      voucher = await repository.validateVoucher(code, plan.id);
    } on ApiException catch (e) {
      voucher = null;
      voucherError = e.message;
    } catch (_) {
      voucher = null;
      voucherError = MembershipStrings.voucherError;
    }
    applyingVoucher = false;
    notifyListeners();
  }

  /// Creates the PayOS order; returns null (with [createError]) on failure.
  Future<PaymentOrder?> createPayment() async {
    final plan = selected;
    if (plan == null || creating) return null;
    creating = true;
    createError = null;
    notifyListeners();
    PaymentOrder? order;
    try {
      order = await repository.createPayment(
        plan.id,
        voucherCode: voucher?.code,
      );
    } on ApiException catch (e) {
      createError = e.message;
    } catch (_) {
      createError = MembershipStrings.createError;
    }
    creating = false;
    notifyListeners();
    return order;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
