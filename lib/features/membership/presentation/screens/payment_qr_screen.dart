import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_outlined_button.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/qr_gallery.dart';
import '../../../../core/widgets/outlined_card.dart';
import '../../../../core/widgets/pill_chip.dart';
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

class _PaymentView extends StatefulWidget {
  const _PaymentView({required this.order});
  final PaymentOrder order;

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  PaymentOrder get order => widget.order;
  bool _saving = false;
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    var message = MembershipStrings.saveQrError;
    try {
      message = await QrGallery.save(order.qrCode)
          ? MembershipStrings.savedQr
          : MembershipStrings.galleryPermission;
    } catch (_) {
      /* Friendly, localized error below. */
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
      appBar: const AppTopBar(title: Text(MembershipStrings.paymentTitle)),
      bottomNavigationBar: state.phase == PaymentPhase.waiting
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ChunkyOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          MembershipStrings.cancelOrder,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChunkyButton(
                        onPressed: state.checking ? null : () => state.check(),
                        child: Text(
                          state.checking
                              ? MembershipStrings.waiting
                              : MembershipStrings.iHavePaid,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: state.phase == PaymentPhase.waiting
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _waiting(context, state),
              )
            : _centered(switch (state.phase) {
                PaymentPhase.paid => _paid(context, state),
                PaymentPhase.canceled => _failure(
                  context,
                  MembershipStrings.canceledTitle,
                  MembershipStrings.canceledBody,
                ),
                _ => _failure(
                  context,
                  MembershipStrings.expiredTitle,
                  MembershipStrings.expiredBody,
                ),
              }),
      ),
    );
  }

  Widget _waiting(BuildContext context, PaymentStatusProvider state) {
    final theme = Theme.of(context);
    final p = AppPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedCard(
          radius: 28,
          edgeColor: p.outline,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Semantics(
                label: MembershipStrings.saveQr,
                button: true,
                child: GestureDetector(
                  key: const Key('payment_qr_image'),
                  onLongPress: _saving ? null : _save,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.qrPaper,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: order.qrCode,
                      size: 216,
                      backgroundColor: AppTheme.qrPaper,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.qrInk,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.qrInk,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                formatVnd(order.amount),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                order.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              Text(
                order.orderCode,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              ChunkyOutlinedButton.icon(
                key: const Key('save_payment_qr'),
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: const Text(MembershipStrings.saveQr),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(64, 44),
                  textStyle: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                MembershipStrings.saveQrHint,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedCard(
          color: p.primarySoft,
          borderColor: p.primarySoft,
          radius: 20,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.sync_rounded, color: p.onPrimarySoft),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  MembershipStrings.paymentHint,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: p.onPrimarySoft,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MembershipStrings.instructions,
                style: theme.textTheme.titleSmall,
              ),
              for (final step in MembershipStrings.paymentSteps)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(step, style: theme.textTheme.bodyMedium),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: PillChip(
            label: MembershipStrings.countdown(state.countdownText),
            icon: Icons.timer_outlined,
            key: const ValueKey('countdown'),
          ),
        ),
        if (state.message != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(state.message!, textAlign: TextAlign.center),
          ),
        const SizedBox(height: 12),
        ChunkyOutlinedButton.icon(
          onPressed: () => _open(context),
          icon: const Icon(Icons.open_in_new),
          label: const Text(MembershipStrings.openPaymentPage),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Result states sit in the middle of the screen, still scrollable when short.
  Widget _centered(Widget child) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: box.maxWidth - 40,
          minHeight: box.maxHeight - 40,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: child,
          ),
        ),
      ),
    ),
  );

  Widget _paid(BuildContext context, PaymentStatusProvider state) {
    final end = context.watch<MembershipProvider>().current.endsAt;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.tertiary,
          size: 96,
        ),
        const SizedBox(height: 16),
        Text(
          MembershipStrings.paidTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
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
        ChunkyButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(MembershipStrings.done),
        ),
      ],
    );
  }

  Widget _failure(BuildContext context, String title, String body) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        ChunkyButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(MembershipStrings.tryAgain),
        ),
      ],
    );
  }
}
