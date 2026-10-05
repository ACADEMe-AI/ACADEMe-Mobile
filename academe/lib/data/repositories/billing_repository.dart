import 'package:flutter/foundation.dart';

import '../../domain/models/pro.dart';
import '../../utils/result.dart';

abstract class BillingRepository extends ChangeNotifier {
  static const playSubscriptionsUrl =
      'https://play.google.com/store/account/subscriptions'
      '?sku=academe_pro&package=com.academe.flutter';

  bool get isAvailable;

  ProPlan get plan;

  bool get isPro;

  String get manageUrl;

  Future<Result<ProPlan>> refresh();

  Future<Result<List<ProOffer>>> offers();

  Future<Result<PurchaseOutcome>> purchase(ProPeriod period);

  Future<Result<bool>> restore();

  Future<void> identify(String? accountId);
}
