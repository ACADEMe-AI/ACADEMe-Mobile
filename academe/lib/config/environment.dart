import 'package:flutter/foundation.dart';

abstract final class Environment {
  static final apiBaseUrl = Uri.parse(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: kReleaseMode
          ? 'https://api.academe.cc'
          : 'http://10.0.2.2:8080',
    ),
  );

  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static const revenueCatGoogleApiKey = String.fromEnvironment(
    'REVENUECAT_GOOGLE_API_KEY',
  );

  static const revenueCatAppleApiKey = String.fromEnvironment(
    'REVENUECAT_APPLE_API_KEY',
  );

  static const revenueCatEntitlement = String.fromEnvironment(
    'REVENUECAT_ENTITLEMENT',
    defaultValue: 'academe_pro',
  );

  static const buildNumber = int.fromEnvironment('APP_BUILD', defaultValue: 8);

  static const appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.1.2',
  );

  static String get displayVersion => 'ACADEMe $appVersion ($buildNumber)';

  static final playStoreUrl = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.academe.flutter',
  );

  static String get revenueCatApiKey => switch (defaultTargetPlatform) {
    TargetPlatform.android when !kIsWeb => revenueCatGoogleApiKey,
    TargetPlatform.iOS when !kIsWeb => revenueCatAppleApiKey,
    _ => '',
  };
}
