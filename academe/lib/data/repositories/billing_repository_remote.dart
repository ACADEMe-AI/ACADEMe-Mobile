import '../../domain/models/pro.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/billing_api_service.dart';
import '../services/purchases_service.dart';
import 'authorizer.dart';
import 'billing_repository.dart';

class BillingRepositoryRemote extends BillingRepository {
  BillingRepositoryRemote({
    required BillingApiService api,
    required Authorizer authorizer,
    required PurchasesService purchases,
  }) : _api = api,
       _authorizer = authorizer,
       _purchases = purchases {
    _purchases.listen(_setCustomer);
  }

  final BillingApiService _api;
  final Authorizer _authorizer;
  final PurchasesService _purchases;

  ProPlan _plan = ProPlan.free;
  StoreCustomer _customer = StoreCustomer.none;

  @override
  bool get isAvailable => _purchases.isAvailable;

  @override
  ProPlan get plan => _plan;

  @override
  bool get isPro => _plan.isPro || _customer.isPro;

  @override
  String get manageUrl =>
      _customer.managementUrl ?? BillingRepository.playSubscriptionsUrl;

  void _setCustomer(StoreCustomer customer) {
    _customer = customer;
    notifyListeners();
  }

  Future<Result<ProPlan>> _server(
    Future<Result<ProPlan>> Function(String token) call,
  ) async {
    final result = await _authorizer.authorized(call);
    switch (result) {
      case Ok(:final value):
        _plan = value;
        notifyListeners();
        return result;
      case Error(:final error):
        return Result.error(BillingException(_failureOf(error)));
    }
  }

  static BillingFailure _failureOf(Exception error) => switch (error) {
    BillingException(:final failure) => failure,
    ApiException(code: ApiException.network) => BillingFailure.network,
    ApiException(code: 'billing_unavailable') => BillingFailure.unavailable,
    _ => BillingFailure.unknown,
  };

  @override
  Future<Result<ProPlan>> refresh() => _server(_api.plan);

  @override
  Future<Result<List<ProOffer>>> offers() => _purchases.offers();

  @override
  Future<Result<PurchaseOutcome>> purchase(ProPeriod period) async {
    final result = await _purchases.purchase(period);
    switch (result) {
      case Error(:final error):
        return Result.error(error);
      case Ok(value: (final outcome, final customer)):
        if (outcome == PurchaseOutcome.purchased) {
          _setCustomer(customer);
          await _server(_api.sync);
        }
        return Result.ok(outcome);
    }
  }

  @override
  Future<Result<bool>> restore() async {
    final result = await _purchases.restore();
    switch (result) {
      case Error(:final error):
        return Result.error(error);
      case Ok(value: final customer):
        _setCustomer(customer);
        await _server(_api.sync);
        return Result.ok(isPro);
    }
  }

  @override
  Future<void> identify(String? accountId) async {
    if (accountId == null) {
      _plan = ProPlan.free;
      _setCustomer(StoreCustomer.none);
      await _purchases.logOut();
      return;
    }
    if (await _purchases.logIn(accountId) case Ok(value: final customer)) {
      _setCustomer(customer);
    }
    await refresh();
  }
}
