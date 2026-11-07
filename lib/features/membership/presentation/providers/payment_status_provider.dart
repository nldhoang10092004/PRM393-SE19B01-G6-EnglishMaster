import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/membership_repository.dart';
import '../../data/models/membership_models.dart';
import '../../membership_strings.dart';

enum PaymentPhase { waiting, paid, canceled, expired }

/// Polls the order status until it leaves PENDING or the countdown ends.
class PaymentStatusProvider extends ChangeNotifier {
  PaymentStatusProvider(
    this.repository,
    this.orderId, {
    this.lifetime = const Duration(minutes: 15),
    this.pollInterval = const Duration(seconds: 3),
    this.tick = const Duration(seconds: 1),
    this.onPaid,
  }) : remaining = lifetime;

  final MembershipRepository repository;
  final int orderId;
  final Duration lifetime;
  final Duration pollInterval;
  final Duration tick;
  final VoidCallback? onPaid;

  PaymentPhase phase = PaymentPhase.waiting;
  Duration remaining;
  PaymentStatus? result;
  bool checking = false;
  String? message;

  Timer? _poll;
  Timer? _clock;
  bool _disposed = false;

  bool get isWaiting => phase == PaymentPhase.waiting;

  /// "mm:ss" of the remaining time.
  String get countdownText {
    final s = remaining.inSeconds < 0 ? 0 : remaining.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void start() {
    if (_poll != null || !isWaiting) return;
    _poll = Timer.periodic(pollInterval, (_) => check(silent: true));
    _clock = Timer.periodic(tick, (_) {
      remaining -= tick;
      if (remaining <= Duration.zero) {
        remaining = Duration.zero;
        _finish(PaymentPhase.expired);
      } else {
        notifyListeners();
      }
    });
  }

  /// Asks the server once; [silent] hides the "not paid yet" hint.
  Future<void> check({bool silent = false}) async {
    if (checking || !isWaiting) return;
    checking = true;
    if (!silent) {
      message = null;
      notifyListeners();
    }
    try {
      final status = await repository.status(orderId);
      if (!isWaiting) return;
      switch (status.state) {
        case PaymentState.paid:
          result = status;
          _finish(PaymentPhase.paid);
          onPaid?.call();
        case PaymentState.canceled:
          result = status;
          _finish(PaymentPhase.canceled);
        case PaymentState.pending:
          if (!silent) message = MembershipStrings.notPaidYet;
      }
    } catch (_) {
      if (!silent) message = MembershipStrings.notPaidYet;
    } finally {
      checking = false;
      notifyListeners();
    }
  }

  void _finish(PaymentPhase next) {
    phase = next;
    _stopTimers();
    notifyListeners();
  }

  void _stopTimers() {
    _poll?.cancel();
    _clock?.cancel();
    _poll = null;
    _clock = null;
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTimers();
    super.dispose();
  }
}
