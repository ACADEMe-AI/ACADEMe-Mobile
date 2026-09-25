import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/folder.dart';
import '../../domain/models/reminder.dart';
import '../../utils/result.dart';
import '../services/hint_store.dart';
import '../services/notification_service.dart';
import '../services/preferences_store.dart';
import 'folder_repository.dart';

class ReminderRepository extends ChangeNotifier {
  ReminderRepository({
    required NotificationService notifications,
    required FolderRepository folderRepository,
    required PreferencesStore preferencesStore,
    required HintStore hintStore,
    DateTime Function()? now,
  }) : _notifications = notifications,
       _folders = folderRepository,
       _preferences = preferencesStore,
       _hints = hintStore,
       _now = now ?? DateTime.now;

  final NotificationService _notifications;
  final FolderRepository _folders;
  final PreferencesStore _preferences;
  final HintStore _hints;
  final DateTime Function() _now;

  static const settle = Duration(milliseconds: 600);

  Timer? _pending;
  NotificationAccess _access = NotificationAccess.unknown;
  bool _wantsPrimer = false;

  NotificationAccess get access => _access;

  bool get wantsPrimer => _wantsPrimer;

  void start() => _folders.addListener(refreshSoon);

  void stop() {
    _folders.removeListener(refreshSoon);
    _pending?.cancel();
  }

  void refreshSoon() {
    _pending?.cancel();
    _pending = Timer(settle, refresh);
  }

  Future<void> refresh() async {
    await _readAccess();
    final preferences = await _preferences.read();
    final (folders, today) = await (_folders.folders(), _folders.today()).wait;
    final summaries = folders is Ok<List<FolderSummary>>
        ? folders.value
        : const <FolderSummary>[];
    final reminders = planReminders(
      now: _now(),
      preferences: preferences,
      folders: summaries,
      today: today is Ok<TodayPlan> ? today.value : TodayPlan.empty,
    );
    final hasSomethingToSend =
        reminders.isNotEmpty ||
        summaries.any((f) => f.reminds && f.dueOn != null);
    if (hasSomethingToSend &&
        _access == NotificationAccess.askable &&
        !_wantsPrimer &&
        !await _hints.hasSeen(Hint.notificationPrimer)) {
      _wantsPrimer = true;
      notifyListeners();
    }
    if (_access == NotificationAccess.allowed) {
      await _notifications.replaceAll(reminders);
    }
  }

  Future<void> checkAccess() async {
    final before = _access;
    await _readAccess();
    if (_access == NotificationAccess.allowed &&
        before != NotificationAccess.allowed &&
        before != NotificationAccess.unknown) {
      await refresh();
    }
  }

  Future<void> answerPrimer({required bool allow}) async {
    _wantsPrimer = false;
    notifyListeners();
    await _hints.markSeen(Hint.notificationPrimer);
    if (allow) await requestPermission();
  }

  Future<void> requestPermission() async {
    await _hints.markSeen(Hint.notificationPermission);
    await _notifications.requestPermission();
    await checkAccess();
  }

  Future<void> turnOn() async {
    if (_access == NotificationAccess.askable) return requestPermission();
    await _notifications.openSettings();
  }

  Future<void> _readAccess() async {
    final next = await _notifications.isAllowed()
        ? NotificationAccess.allowed
        : await _notifications.canRequest() &&
              !await _hints.hasSeen(Hint.notificationPermission)
        ? NotificationAccess.askable
        : NotificationAccess.blocked;
    if (next == _access) return;
    _access = next;
    notifyListeners();
  }
}
