import 'package:academe/data/services/purchases_service.dart';
import 'package:academe/domain/models/pro.dart';
import 'package:academe/utils/result.dart';

class FakePurchasesService implements PurchasesService {
  FakePurchasesService({this.isAvailable = true});

  @override
  final bool isAvailable;
  PurchaseOutcome outcome = PurchaseOutcome.purchased;
  StoreCustomer customer = const StoreCustomer(
    isPro: true,
    managementUrl: 'https://play.google.com/store/account/subscriptions',
  );
  BillingFailure? failure;
  final loggedIn = <String>[];
  int logOuts = 0;
  void Function(StoreCustomer customer)? listener;

  Result<T> _answer<T>(T Function() value) => switch (failure) {
    final failure? => Result.error(BillingException(failure)),
    null => Result.ok(value()),
  };

  @override
  Future<Result<StoreCustomer>> logIn(String appUserId) async {
    loggedIn.add(appUserId);
    return _answer(() => StoreCustomer.none);
  }

  @override
  Future<Result<void>> logOut() async {
    logOuts++;
    return Result.ok(null);
  }

  @override
  Future<Result<List<ProOffer>>> offers() async =>
      _answer(() => ProOffer.defaults);

  @override
  Future<Result<(PurchaseOutcome, StoreCustomer)>> purchase(
    ProPeriod period,
  ) async => _answer(
    () => (
      outcome,
      outcome == PurchaseOutcome.purchased ? customer : StoreCustomer.none,
    ),
  );

  @override
  Future<Result<StoreCustomer>> restore() async => _answer(() => customer);

  @override
  void listen(void Function(StoreCustomer customer) onChanged) =>
      listener = onChanged;
}
