import 'package:academe/data/services/purchases_service.dart';
import 'package:academe/domain/models/pro.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _context = PresentedOfferingContext('default', null, null);

Package _package(String id, PackageType type, String product, String? period) =>
    Package(
      id,
      type,
      StoreProduct(
        product,
        'ACADEMe Pro',
        'ACADEMe Pro',
        1,
        '₹1',
        'INR',
        subscriptionPeriod: period,
      ),
      _context,
    );

EntitlementInfo _entitlement(String id) =>
    EntitlementInfo(id, true, true, '', '', 'monthly', true);

CustomerInfo _customer(Map<String, EntitlementInfo> active) => CustomerInfo(
  EntitlementInfos(active, active),
  const {},
  const [],
  const [],
  const [],
  '',
  '',
  const {},
  '',
);

void main() {
  test('only the monthly and annual packages become offers', () {
    final monthly = _package(
      '\$rc_monthly',
      PackageType.monthly,
      'monthly',
      'P1M',
    );
    final annual = _package('\$rc_annual', PackageType.annual, 'yearly', 'P1Y');
    final lifetime = _package(
      '\$rc_lifetime',
      PackageType.lifetime,
      'lifetime',
      null,
    );
    final offering = Offering(
      'default',
      '',
      const {},
      [lifetime, monthly, annual],
      lifetime: lifetime,
      monthly: monthly,
      annual: annual,
    );
    expect(RevenueCatPurchasesService.packagesOf(offering), {
      ProPeriod.monthly: monthly,
      ProPeriod.annual: annual,
    });
    expect(RevenueCatPurchasesService.packagesOf(null), isEmpty);
  });

  test('custom packages are matched by their billing period', () {
    final month = _package('month', PackageType.custom, 'monthly', 'P1M');
    final week = _package('week', PackageType.custom, 'weekly', 'P1W');
    final offering = Offering('default', '', const {}, [month, week]);
    expect(RevenueCatPurchasesService.packagesOf(offering), {
      ProPeriod.monthly: month,
    });
  });

  test('Pro follows the configured entitlement, academe_pro by default', () {
    final service = RevenueCatPurchasesService(apiKey: '');
    expect(service.entitlement, 'academe_pro');
    expect(
      service
          .customerOf(_customer({'academe_pro': _entitlement('academe_pro')}))
          .isPro,
      isTrue,
    );
    expect(
      service.customerOf(_customer({'pro': _entitlement('pro')})).isPro,
      isFalse,
    );
    final custom = RevenueCatPurchasesService(apiKey: '', entitlement: 'pro');
    expect(
      custom.customerOf(_customer({'pro': _entitlement('pro')})).isPro,
      isTrue,
    );
  });
}
