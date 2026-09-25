import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/me/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_hint_store.dart';
import '../../../testing/fakes/fake_notification_service.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';

void main() {
  late ReminderRepository repository;

  Future<void> pump(
    WidgetTester tester,
    FakeNotificationService notifications,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    repository = ReminderRepository(
      notifications: notifications,
      folderRepository: FakeFolderRepository(),
      preferencesStore: FakePreferencesStore(),
      hintStore: FakeHintStore(),
    );
    final viewModel = MeViewModel(
      authRepository: FakeAuthRepository(signedIn: FakeAuthRepository.ada),
      profileRepository: FakeProfileRepository(),
      preferencesStore: FakePreferencesStore(),
      appearance: AppearanceRepository(store: FakeAppearanceStore()),
      reminders: repository,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(body: NotificationsScreen(viewModel: viewModel)),
        ),
      ),
    );
    await repository.checkAccess();
    await tester.pumpAndSettle();
  }

  testWidgets('allowed shows no call to action', (tester) async {
    await pump(tester, FakeNotificationService(isGranted: true));
    expect(find.text('Allowed'), findsOneWidget);
    expect(find.text('Turn on notifications'), findsNothing);
    expect(find.text('Turn on in Settings'), findsNothing);
  });

  testWidgets('never asked offers the system prompt', (tester) async {
    final notifications = FakeNotificationService();
    await pump(tester, notifications);
    expect(find.text('Not allowed'), findsOneWidget);

    await tester.tap(find.text('Turn on notifications'));
    await tester.pumpAndSettle();
    expect(notifications.permissionRequests, 1);
    expect(find.text('Allowed'), findsOneWidget);
  });

  testWidgets('denied opens the app notification settings', (tester) async {
    final notifications = FakeNotificationService(hasPrompt: false);
    await pump(tester, notifications);
    expect(find.text('Not allowed'), findsOneWidget);

    await tester.tap(find.text('Turn on in Settings'));
    expect(notifications.settingsOpened, 1);
    expect(notifications.permissionRequests, 0);

    notifications.isGranted = true;
    await repository.checkAccess();
    await tester.pumpAndSettle();
    expect(find.text('Allowed'), findsOneWidget);
  });
}
