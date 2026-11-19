import 'dart:io';

import 'package:academe/data/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Android notifications use the white status-bar icon', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    AndroidFlutterLocalNotificationsPlugin.registerWith();

    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    Object? initializeArguments;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'initialize') {
            initializeArguments = call.arguments;
            return true;
          }
          return true;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );

    await LocalNotificationService().isAllowed();

    expect(initializeArguments, isA<Map<Object?, Object?>>());
    final icon = (initializeArguments! as Map<Object?, Object?>)['defaultIcon'];
    expect(icon, 'ic_stat_academe');
    for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      expect(
        File(
          'android/app/src/main/res/drawable-$density/$icon.png',
        ).existsSync(),
        isTrue,
        reason: '$icon.png is missing for $density',
      );
    }
  });
}
