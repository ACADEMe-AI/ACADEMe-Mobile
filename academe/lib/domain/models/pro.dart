enum ProFeature {
  askme('askme'),
  scan('scan'),
  check('check'),
  lessons('lessons');

  const ProFeature(this.code);

  final String code;

  static ProFeature? fromCode(String? code) {
    for (final feature in values) {
      if (feature.code == code) return feature;
    }
    return null;
  }
}

enum ProPeriod { monthly, annual }

class ProPlan {
  const ProPlan({
    required this.isPro,
    this.expiresAt,
    this.autoRenew = false,
    this.period,
    this.state,
    this.limits = const {},
    this.usedToday = const {},
    this.resetsAt,
  });

  static const free = ProPlan(isPro: false);

  final bool isPro;
  final DateTime? expiresAt;
  final bool autoRenew;
  final ProPeriod? period;
  final String? state;
  final Map<ProFeature, int?> limits;
  final Map<ProFeature, int> usedToday;
  final DateTime? resetsAt;

  int? limitOf(ProFeature feature) => limits[feature];

  ProPlan copyWith({bool? isPro}) => ProPlan(
    isPro: isPro ?? this.isPro,
    expiresAt: expiresAt,
    autoRenew: autoRenew,
    period: period,
    state: state,
    limits: limits,
    usedToday: usedToday,
    resetsAt: resetsAt,
  );
}

class ProOffer {
  const ProOffer({
    required this.period,
    required this.price,
    this.introPrice,
    this.monthlyPrice,
  });

  final ProPeriod period;
  final String price;
  final String? introPrice;
  final String? monthlyPrice;

  static const defaults = [
    ProOffer(period: ProPeriod.monthly, price: '₹200', introPrice: '₹100'),
    ProOffer(period: ProPeriod.annual, price: '₹1,999', monthlyPrice: '₹167'),
  ];
}

enum PurchaseOutcome { purchased, pending, cancelled }

enum BillingFailure {
  unavailable,
  network,
  notAllowed,
  alreadyOwned,
  store,
  unknown,
}

class BillingException implements Exception {
  const BillingException(this.failure);

  final BillingFailure failure;

  @override
  String toString() => 'BillingException($failure)';
}

class StoreCustomer {
  const StoreCustomer({required this.isPro, this.managementUrl});

  static const none = StoreCustomer(isPro: false);

  final bool isPro;
  final String? managementUrl;
}
