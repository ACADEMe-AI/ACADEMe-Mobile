import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/reminder.dart';

abstract class NotificationService {
  Future<bool> isAllowed();

  Future<bool> canRequest();

  Future<bool> requestPermission();

  Future<void> openSettings();

  Future<void> replaceAll(List<Reminder> reminders);
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static const _settings = MethodChannel('academe/notification_settings');

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'study_reminders',
      'Study reminders',
      channelDescription: 'Your plan for the day and test reminders',
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() => _ready ??= () async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }();

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> isAllowed() async {
    await _init();
    if (_android case final android?) {
      return await android.areNotificationsEnabled() ?? false;
    }
    if (_ios case final ios?) {
      return (await ios.checkPermissions())?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<bool> canRequest() async {
    try {
      return await _settings.invokeMethod<bool>('canRequest') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    if (_android case final android?) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (_ios case final ios?) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  @override
  Future<void> openSettings() async {
    try {
      await _settings.invokeMethod<void>('open');
    } on MissingPluginException {
      return;
    }
  }

  @override
  Future<void> replaceAll(List<Reminder> reminders) async {
    await _init();
    await _plugin.cancelAll();
    for (final r in reminders) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.from(r.at.toUtc(), tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
