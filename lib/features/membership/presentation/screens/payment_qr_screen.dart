import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/membership_repository.dart';
import '../../data/models/membership_models.dart';
import '../../membership_strings.dart';
import '../providers/membership_provider.dart';
import '../providers/payment_status_provider.dart';
import 'membership_screen.dart' show formatVnd;

/// Shows the PayOS QR and polls until the order is paid, canceled or expired.
class PaymentQrScreen extends StatelessWidget {
  const PaymentQrScreen({super.key, required this.order});
  final PaymentOrder order;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PaymentStatusProvider(
        context.read<MembershipRepository>(),
        order.orderId,
        onPaid: () => context.read<MembershipProvider>().refreshCurrent(),
      )..start(),
      child: _PaymentView(order: order),
    );
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView({required this.order});
  final PaymentOrder order;

  Future<void> _open(BuildContext context) async {
    var ok = false;
    try {
      ok = await launchUrl(
        Uri.parse(order.paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(MembershipStrings.openLinkError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PaymentStatusProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text(MembershipStrings.paymentTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: switch (state.phase) {
            PaymentPhase.waiting => _waiting(context, state),
            PaymentPhase.paid => _paid(context, state),
            PaymentPhase.canceled => _failure(
              context,
              MembershipStrings.canceledTitle,
              MembershipStrings.canceledBody,
            ),
            PaymentPhase.expired => _failure(
              context,
              MembershipStrings.expiredTitle,
              MembershipStrings.expiredBody,
            ),
          },
        ),
      ),
    );
  }

  Widget _waiting(BuildContext context, PaymentStatusProvider state) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(MembershipStrings.amount, style: theme.textTheme.labelLarge),
        Text(formatVnd(order.amount), style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: QrImageView(
            data: order.qrCode,
            size: 240,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(MembershipStrings.scanInstruction, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          '${MembershipStrings.orderDescription}: ${order.description}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          MembershipStrings.countdown(state.countdownText),
          key: const ValueKey('countdown'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text(MembershipStrings.waiting),
        if (state.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(state.message!, textAlign: TextAlign.center),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _open(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text(MembershipStrings.openPaymentPage),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: state.checking ? null : () => state.check(),
            child: state.checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(MembershipStrings.iHavePaid),
          ),
        ),
      ],
    );
  }

  Widget _paid(BuildContext context, PaymentStatusProvider state) {
    final end = context.watch<MembershipProvider>().current.endsAt;
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.green, size: 96),
        const SizedBox(height: 16),
        Text(
          MembershipStrings.paidTitle,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          end == null
              ? MembershipStrings.paidNoExpiry
              : MembershipStrings.newExpiry(
                  DateFormat('dd/MM/yyyy').format(end),
                ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(MembershipStrings.done),
        ),
      ],
    );
  }

  Widget _failure(BuildContext context, String title, String body) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 80,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(body, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(MembershipStrings.tryAgain),
        ),
      ],
    );
  }
}
