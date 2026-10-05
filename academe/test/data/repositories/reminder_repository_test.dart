import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/data/services/hint_store.dart';
import 'package:academe/domain/models/folder.dart';
import 'package:academe/domain/models/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_hint_store.dart';
import '../../../testing/fakes/fake_notification_service.dart';
import '../../../testing/fakes/fake_preferences_store.dart';

void main() {
  final now = DateTime(2026, 10, 5, 12);
  late FakeNotificationService notifications;
  late FakeFolderRepository folders;
  late FakeHintStore hints;
  late ReminderRepository repository;

  void build(FakeNotificationService service) {
    notifications = service;
    folders = FakeFolderRepository();
    hints = FakeHintStore();
    repository = ReminderRepository(
      notifications: notifications,
      folderRepository: folders,
      preferencesStore: FakePreferencesStore(),
      hintStore: hints,
      now: () => now,
    );
  }

  void addTest() => folders.summaries.add(
    FolderSummary(
      id: 'science',
      name: 'Science test',
      dueOn: DateTime(2026, 10, 8),
      reminds: true,
      items: 1,
      todayLeft: 1,
      progress: 0,
    ),
  );

  test('no primer while there is nothing to send', () async {
    build(FakeNotificationService());
    await repository.refresh();
    expect(repository.access, NotificationAccess.askable);
    expect(repository.wantsPrimer, isFalse);
    expect(notifications.permissionRequests, 0);
  });

  test('the first dated folder asks for the primer once', () async {
    build(FakeNotificationService());
    addTest();
    await repository.refresh();
    expect(repository.wantsPrimer, isTrue);
    expect(notifications.permissionRequests, 0);
    expect(notifications.scheduled, isEmpty);

    await repository.answerPrimer(allow: true);
    expect(repository.wantsPrimer, isFalse);
    expect(notifications.permissionRequests, 1);
    expect(repository.access, NotificationAccess.allowed);
    expect(notifications.scheduled, isNotEmpty);

    await repository.refresh();
    expect(repository.wantsPrimer, isFalse);
    expect(notifications.permissionRequests, 1);
  });

  test('not now never shows the primer again, Me can still ask', () async {
    build(FakeNotificationService());
    addTest();
    await repository.refresh();
    await repository.answerPrimer(allow: false);
    await repository.refresh();
    expect(repository.wantsPrimer, isFalse);
    expect(notifications.permissionRequests, 0);
    expect(hints.seen, contains(Hint.notificationPrimer));
    expect(repository.access, NotificationAccess.askable);

    await repository.turnOn();
    expect(notifications.permissionRequests, 1);
    expect(repository.access, NotificationAccess.allowed);
  });

  test('a denied prompt sends Me to the system settings', () async {
    build(FakeNotificationService(grantsOnRequest: false));
    addTest();
    await repository.refresh();
    await repository.answerPrimer(allow: true);
    expect(repository.access, NotificationAccess.blocked);

    await repository.turnOn();
    expect(notifications.permissionRequests, 1);
    expect(notifications.settingsOpened, 1);
  });

  test('turning it on in Settings reschedules on resume', () async {
    build(FakeNotificationService(grantsOnRequest: false));
    addTest();
    await repository.refresh();
    await repository.answerPrimer(allow: true);
    expect(notifications.scheduled, isEmpty);

    notifications.isGranted = true;
    await repository.checkAccess();
    expect(repository.access, NotificationAccess.allowed);
    expect(notifications.scheduled, isNotEmpty);
  });

  test('Android before 13 never shows the primer', () async {
    build(FakeNotificationService(isGranted: true, hasPrompt: false));
    addTest();
    await repository.refresh();
    expect(repository.wantsPrimer, isFalse);
    expect(repository.access, NotificationAccess.allowed);
    expect(notifications.scheduled, isNotEmpty);

    build(FakeNotificationService(hasPrompt: false));
    addTest();
    await repository.refresh();
    expect(repository.wantsPrimer, isFalse);
    expect(repository.access, NotificationAccess.blocked);
  });

  test(
    'an existing user who already allowed keeps reminders, no primer',
    () async {
      build(FakeNotificationService(isGranted: true));
      hints.seen.add(Hint.notificationPermission);
      addTest();
      await repository.refresh();
      expect(repository.wantsPrimer, isFalse);
      expect(repository.access, NotificationAccess.allowed);
      expect(notifications.scheduled, isNotEmpty);
      expect(notifications.permissionRequests, 0);
    },
  );

  test('an existing user who denied goes to Settings, no primer', () async {
    build(FakeNotificationService());
    hints.seen.add(Hint.notificationPermission);
    addTest();
    await repository.refresh();
    expect(repository.wantsPrimer, isFalse);
    expect(repository.access, NotificationAccess.blocked);
    expect(notifications.scheduled, isEmpty);

    await repository.turnOn();
    expect(notifications.permissionRequests, 0);
    expect(notifications.settingsOpened, 1);
  });

  test('resume while still denied schedules nothing', () async {
    build(FakeNotificationService(grantsOnRequest: false));
    addTest();
    await repository.refresh();
    await repository.answerPrimer(allow: true);
    await repository.checkAccess();
    expect(repository.access, NotificationAccess.blocked);
    expect(notifications.scheduled, isEmpty);
  });
}
