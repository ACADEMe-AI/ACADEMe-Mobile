import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../config/environment.dart';
import '../../domain/models/pro.dart';
import '../../utils/result.dart';

abstract interface class PurchasesService {
  bool get isAvailable;

  Future<Result<StoreCustomer>> logIn(String appUserId);

  Future<Result<void>> logOut();

  Future<Result<List<ProOffer>>> offers();

  Future<Result<(PurchaseOutcome, StoreCustomer)>> purchase(ProPeriod period);

  Future<Result<StoreCustomer>> restore();

  void listen(void Function(StoreCustomer customer) onChanged);
}

class RevenueCatPurchasesService implements PurchasesService {
  RevenueCatPurchasesService({
    required String apiKey,
    this.entitlement = Environment.revenueCatEntitlement,
  }) : _apiKey = apiKey;

  static const offering = 'default';

  final String _apiKey;
  final String entitlement;
  Future<void>? _configured;
  void Function(StoreCustomer customer)? _onChanged;
  final Map<ProPeriod, Package> _packages = {};

  @override
  bool get isAvailable => _apiKey.isNotEmpty;

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    if (!isAvailable) {
      return Result.error(const BillingException(BillingFailure.unavailable));
    }
    try {
      await _configure(null);
      return Result.ok(await action());
    } on PlatformException catch (error) {
      return Result.error(BillingException(_failureOf(error)));
    }
  }

  Future<void> _configure(String? appUserId) => _configured ??=
      Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = appUserId,
      ).then((_) {
        if (_onChanged case final onChanged?) {
          Purchases.addCustomerInfoUpdateListener(
            (info) => onChanged(customerOf(info)),
          );
        }
      });

  static BillingFailure _failureOf(PlatformException error) =>
      switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.networkError => BillingFailure.network,
        PurchasesErrorCode.purchaseNotAllowedError ||
        PurchasesErrorCode.insufficientPermissionsError =>
          BillingFailure.notAllowed,
        PurchasesErrorCode.productAlreadyPurchasedError =>
          BillingFailure.alreadyOwned,
        PurchasesErrorCode.storeProblemError ||
        PurchasesErrorCode.productNotAvailableForPurchaseError ||
        PurchasesErrorCode.configurationError => BillingFailure.store,
        _ => BillingFailure.unknown,
      };

  StoreCustomer customerOf(CustomerInfo info) => StoreCustomer(
    isPro: info.entitlements.active.containsKey(entitlement),
    managementUrl: info.managementURL,
  );

  static Map<ProPeriod, Package> packagesOf(Offering? offering) => {
    for (final package in offering?.availablePackages ?? const <Package>[])
      ?_periodOf(package): package,
  };

  static ProPeriod? _periodOf(Package package) => switch ((
    package.packageType,
    package.storeProduct.subscriptionPeriod,
  )) {
    (PackageType.monthly, _) ||
    (PackageType.custom, 'P1M') => ProPeriod.monthly,
    (PackageType.annual, _) || (PackageType.custom, 'P1Y') => ProPeriod.annual,
    _ => null,
  };

  static ProOffer _offer(ProPeriod period, StoreProduct product) {
    final intro = product.defaultOption?.introPhase?.price.formatted;
    return ProOffer(
      period: period,
      price: product.priceString,
      introPrice: intro ?? product.introductoryPrice?.priceString,
      monthlyPrice: period == ProPeriod.annual
          ? product.pricePerMonthString
          : null,
    );
  }

  @override
  Future<Result<StoreCustomer>> logIn(String appUserId) async {
    if (isAvailable && _configured == null) {
      try {
        await _configure(appUserId);
      } on PlatformException catch (error) {
        return Result.error(BillingException(_failureOf(error)));
      }
      return _run(() async => customerOf(await Purchases.getCustomerInfo()));
    }
    return _run(
      () async => customerOf((await Purchases.logIn(appUserId)).customerInfo),
    );
  }

  @override
  Future<Result<void>> logOut() async {
    if (_configured == null) return Result.ok(null);
    return _logOut();
  }

  Future<Result<void>> _logOut() => _run(() async {
    if (!await Purchases.isAnonymous) await Purchases.logOut();
  });

  @override
  Future<Result<List<ProOffer>>> offers() => _run(() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.getOffering(offering) ?? offerings.current;
    _packages
      ..clear()
      ..addAll(packagesOf(current));
    return [
      for (final MapEntry(:key, :value) in _packages.entries)
        _offer(key, value.storeProduct),
    ];
  });

  @override
  Future<Result<(PurchaseOutcome, StoreCustomer)>> purchase(
    ProPeriod period,
  ) async {
    if (_packages[period] == null) {
      final loaded = await offers();
      if (loaded is Error<List<ProOffer>>) return Result.error(loaded.error);
    }
    final package = _packages[period];
    if (package == null) {
      return Result.error(const BillingException(BillingFailure.store));
    }
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return Result.ok((
        PurchaseOutcome.purchased,
        customerOf(result.customerInfo),
      ));
    } on PlatformException catch (error) {
      return switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.purchaseCancelledError => Result.ok((
          PurchaseOutcome.cancelled,
          StoreCustomer.none,
        )),
        PurchasesErrorCode.paymentPendingError => Result.ok((
          PurchaseOutcome.pending,
          StoreCustomer.none,
        )),
        _ => Result.error(BillingException(_failureOf(error))),
      };
    }
  }

  @override
  Future<Result<StoreCustomer>> restore() =>
      _run(() async => customerOf(await Purchases.restorePurchases()));

  @override
  void listen(void Function(StoreCustomer customer) onChanged) =>
      _onChanged = onChanged;
}
