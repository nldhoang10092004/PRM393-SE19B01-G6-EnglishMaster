import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/async_view.dart';
import '../../data/models/membership_models.dart';
import '../../membership_strings.dart';
import '../providers/membership_provider.dart';
import 'payment_qr_screen.dart';

/// Formats an amount in Vietnamese number style followed by the đ symbol.
String formatVnd(num amount) =>
    '${NumberFormat.decimalPattern('vi').format(amount.round())}đ';

/// Plans, voucher and checkout entry point.
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final _voucher = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MembershipProvider>().load();
    });
  }

  @override
  void dispose() {
    _voucher.dispose();
    super.dispose();
  }

  Future<void> _pay(MembershipProvider state) async {
    final order = await state.createPayment();
    if (!mounted) return;
    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.createError ?? MembershipStrings.createError),
        ),
      );
      return;
    }
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => PaymentQrScreen(order: order)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MembershipProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(MembershipStrings.title)),
      body: AsyncView(
        status: state.status,
        error: state.error,
        onRetry: state.load,
        builder: (context) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CurrentCard(info: state.current),
            const SizedBox(height: 20),
            Text(
              MembershipStrings.choosePlan,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (state.plans.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text(MembershipStrings.noPlans)),
              )
            else
              for (final plan in state.plans)
                _PlanCard(
                  plan: plan,
                  selected: state.selected?.id == plan.id,
                  best: state.bestValue?.id == plan.id,
                  onTap: () => state.select(plan),
                ),
            if (state.plans.isNotEmpty) ...[
              const SizedBox(height: 12),
              _VoucherBox(controller: _voucher, state: state),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.selected == null || state.creating
                    ? null
                    : () => _pay(state),
                child: state.creating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '${MembershipStrings.pay} · ${formatVnd(state.payable)}',
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.info});
  final MembershipInfo info;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final end = info.endsAt;
    final active = info.hasMembership && end != null;
    return Card(
      color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              active ? Icons.workspace_premium : Icons.lock_outline,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MembershipStrings.currentMembership,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    active
                        ? (info.planName ?? MembershipStrings.title)
                        : MembershipStrings.noMembership,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (active)
                    Text(
                      MembershipStrings.activeUntil(
                        DateFormat('dd/MM/yyyy').format(end),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.best,
    required this.onTap,
  });
  final MembershipPlan plan;
  final bool selected;
  final bool best;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        key: ValueKey('plan-${plan.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wrap keeps the badge on its own line on narrow screens.
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (best)
                          Chip(
                            label: const Text(MembershipStrings.bestValue),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: scheme.tertiaryContainer,
                          ),
                      ],
                    ),
                    Text(
                      '${MembershipStrings.duration(plan.durationDays)} · '
                      '${MembershipStrings.perDay(formatVnd(plan.pricePerDay))}',
                    ),
                  ],
                ),
              ),
              Text(
                formatVnd(plan.price),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoucherBox extends StatelessWidget {
  const _VoucherBox({required this.controller, required this.state});
  final TextEditingController controller;
  final MembershipProvider state;

  @override
  Widget build(BuildContext context) {
    final voucher = state.voucher;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('voucher-input'),
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: MembershipStrings.voucherLabel,
                  hintText: MembershipStrings.voucherHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: state.applyingVoucher
                  ? null
                  : () => state.applyVoucher(controller.text),
              child: const Text(MembershipStrings.apply),
            ),
          ],
        ),
        if (state.voucherError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              state.voucherError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (voucher != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${MembershipStrings.discount(formatVnd(voucher.discountAmount))} · '
                    '${MembershipStrings.finalPrice(formatVnd(voucher.finalPrice))}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clear();
                    state.clearVoucher();
                  },
                  child: const Text(MembershipStrings.removeVoucher),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
