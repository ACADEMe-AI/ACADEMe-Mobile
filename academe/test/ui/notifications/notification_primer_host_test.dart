import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/domain/models/folder.dart';
import 'package:academe/domain/models/reminder.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/notifications/view_models/notification_primer_view_model.dart';
import 'package:academe/ui/notifications/widgets/notification_primer_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_hint_store.dart';
import '../../../testing/fakes/fake_notification_service.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeNotificationService notifications;
  late ReminderRepository repository;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    notifications = FakeNotificationService();
    final folders = FakeFolderRepository()
      ..summaries.add(
        FolderSummary(
          id: 'science',
          name: 'Science test',
          dueOn: DateTime.now().add(const Duration(days: 2)),
          reminds: true,
          items: 1,
          todayLeft: 1,
          progress: 0,
        ),
      );
    repository = ReminderRepository(
      notifications: notifications,
      folderRepository: folders,
      preferencesStore: FakePreferencesStore(),
      hintStore: FakeHintStore(),
    );
    final viewModel = NotificationPrimerViewModel(reminders: repository);
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: NotificationPrimerHost(
            viewModel: viewModel,
            child: const Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    await repository.refresh();
    await tester.pumpAndSettle();
  }

  testWidgets('Allow on the primer opens the system prompt', (tester) async {
    await pump(tester);
    expect(find.text('Get a nudge before your test'), findsOneWidget);
    expect(notifications.permissionRequests, 0);
    expectOnlyAppFonts(tester);

    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(find.text('Get a nudge before your test'), findsNothing);
    expect(notifications.permissionRequests, 1);
  });

  testWidgets('Not now closes the primer without the system prompt', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.text('Get a nudge before your test'), findsNothing);
    expect(notifications.permissionRequests, 0);
    expect(repository.wantsPrimer, isFalse);

    await repository.refresh();
    await tester.pumpAndSettle();
    expect(find.text('Get a nudge before your test'), findsNothing);
  });

  testWidgets('allowing in Settings reschedules when the app resumes', (
    tester,
  ) async {
    await pump(tester);
    notifications.grantsOnRequest = false;
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(repository.access, NotificationAccess.blocked);
    expect(notifications.scheduled, isEmpty);

    notifications.isGranted = true;
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
    expect(repository.access, NotificationAccess.allowed);
    expect(notifications.scheduled, isNotEmpty);
  });
}
