import 'package:academe/data/repositories/billing_repository.dart';
import 'package:academe/domain/models/pro.dart';
import 'package:academe/utils/result.dart';

class FakeBillingRepository extends BillingRepository {
  FakeBillingRepository({
    this.isAvailable = true,
    ProPlan plan = freePlan,
    this.offerList = const [],
  }) : _plan = plan;

  static const freePlan = ProPlan(
    isPro: false,
    limits: {
      ProFeature.askme: 10,
      ProFeature.scan: 3,
      ProFeature.check: 1,
      ProFeature.lessons: 0,
    },
  );

  static final proPlan = ProPlan(
    isPro: true,
    expiresAt: DateTime.utc(2026, 10, 25),
    autoRenew: true,
    period: ProPeriod.monthly,
    state: 'active',
  );

  @override
  final bool isAvailable;
  List<ProOffer> offerList;
  PurchaseOutcome outcome = PurchaseOutcome.purchased;
  BillingFailure? failure;
  bool restoresPro = false;
  final purchased = <ProPeriod>[];
  final identities = <String?>[];
  ProPlan _plan;

  @override
  ProPlan get plan => _plan;

  @override
  bool get isPro => _plan.isPro;

  @override
  String get manageUrl => BillingRepository.playSubscriptionsUrl;

  Result<T> _answer<T>(T Function() value) => switch (failure) {
    final failure? => Result.error(BillingException(failure)),
    null => Result.ok(value()),
  };

  @override
  Future<Result<ProPlan>> refresh() async => _answer(() => _plan);

  @override
  Future<Result<List<ProOffer>>> offers() async => _answer(() => offerList);

  @override
  Future<Result<PurchaseOutcome>> purchase(ProPeriod period) async {
    purchased.add(period);
    final result = _answer(() => outcome);
    if (result case Ok(value: PurchaseOutcome.purchased)) {
      _plan = proPlan;
      notifyListeners();
    }
    return result;
  }

  @override
  Future<Result<bool>> restore() async {
    final result = _answer(() => restoresPro);
    if (restoresPro) {
      _plan = proPlan;
      notifyListeners();
    }
    return result;
  }

  @override
  Future<void> identify(String? accountId) async => identities.add(accountId);
}
