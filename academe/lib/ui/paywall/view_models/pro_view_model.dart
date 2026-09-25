import 'package:flutter/foundation.dart';

import '../../../data/repositories/billing_repository.dart';
import '../../../domain/models/pro.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class ProViewModel extends ChangeNotifier {
  ProViewModel({required BillingRepository billingRepository})
    : _billing = billingRepository {
    _billing.addListener(notifyListeners);
    load = Command0(_load)..addListener(notifyListeners);
    purchase = Command0(_purchase)..addListener(notifyListeners);
    restore = Command0(_restore)..addListener(notifyListeners);
  }

  final BillingRepository _billing;

  late final Command0<void> load;
  late final Command0<PurchaseOutcome> purchase;
  late final Command0<bool> restore;

  ProPeriod _selected = ProPeriod.annual;
  List<ProOffer> _offers = ProOffer.defaults;

  ProPeriod get selected => _selected;
  bool get isAvailable => _billing.isAvailable;
  bool get isPro => _billing.isPro;
  ProPlan get plan => _billing.plan;
  String get manageUrl => _billing.manageUrl;
  bool get isBusy => purchase.isRunning || restore.isRunning;

  ProOffer offerFor(ProPeriod period) => _offers.firstWhere(
    (offer) => offer.period == period,
    orElse: () => ProOffer.defaults.firstWhere((o) => o.period == period),
  );

  String? get notice {
    if (purchase.result case Ok(value: PurchaseOutcome.pending)) {
      return 'Your payment is pending. Pro turns on as soon as Google Play '
          'confirms it.';
    }
    if (restore.result case Ok(value: false)) {
      return 'No ACADEMe Pro purchase was found on this Google account.';
    }
    for (final Command<Object?> command in [purchase, restore]) {
      if (command.result case Error(:final error)) {
        return switch (error) {
          BillingException(failure: BillingFailure.network) =>
            'No connection. Check your internet and try again.',
          BillingException(failure: BillingFailure.notAllowed) =>
            'Purchases are turned off for this Google account.',
          BillingException(failure: BillingFailure.unavailable) =>
            'Purchases aren’t available on this device.',
          _ => 'Google Play couldn’t finish that. Try again.',
        };
      }
    }
    return null;
  }

  void select(ProPeriod period) {
    if (_selected == period) return;
    _selected = period;
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final plan = _billing.refresh();
    if (_billing.isAvailable) {
      final offers = await _billing.offers();
      if (offers case Ok(:final value) when value.isNotEmpty) {
        _offers = [
          for (final fallback in ProOffer.defaults)
            value.firstWhere(
              (offer) => offer.period == fallback.period,
              orElse: () => fallback,
            ),
        ];
      }
    }
    await plan;
    return Result.ok(null);
  }

  Future<Result<PurchaseOutcome>> _purchase() {
    restore.clearResult();
    return _billing.purchase(_selected);
  }

  Future<Result<bool>> _restore() {
    purchase.clearResult();
    return _billing.restore();
  }

  @override
  void dispose() {
    _billing.removeListener(notifyListeners);
    for (final command in [load, purchase, restore]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
