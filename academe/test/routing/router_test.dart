import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/routing/router.dart';
import 'package:academe/routing/routes.dart';
import 'package:academe/ui/auth/widgets/welcome_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/scan/scan_factory.dart';
import 'package:academe/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_appearance_store.dart';
import '../../testing/fakes/fake_auth_repository.dart';
import '../../testing/fakes/fake_billing_repository.dart';
import '../../testing/fakes/fake_chat_repository.dart';
import '../../testing/fakes/fake_folder_repository.dart';
import '../../testing/fakes/fake_hint_store.dart';
import '../../testing/fakes/fake_notification_service.dart';
import '../../testing/fakes/fake_photo_repository.dart';
import '../../testing/fakes/fake_preferences_store.dart';
import '../../testing/fakes/fake_profile_repository.dart';
import '../../testing/fakes/fake_scan_repository.dart';
import '../../testing/fakes/fake_study_repository.dart';

void main() {
  testWidgets('log out still leaves home after the theme changes', (
    tester,
  ) async {
    final auth = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
    final appearance = AppearanceRepository(store: FakeAppearanceStore());
    final folders = FakeFolderRepository();
    final router = appRouter(
      appearance: appearance,
      authRepository: auth,
      profileRepository: FakeProfileRepository(),
      chatRepository: FakeChatRepository(),
      billingRepository: FakeBillingRepository(),
      studyRepository: FakeStudyRepository(),
      folderRepository: folders,
      scans: ScanFactory(
        scanRepository: FakeScanRepository(),
        photoRepository: FakePhotoRepository(),
      ),
      reminders: ReminderRepository(
        notifications: FakeNotificationService(),
        folderRepository: folders,
        preferencesStore: FakePreferencesStore(),
        hintStore: FakeHintStore(),
      ),
      hintStore: FakeHintStore(),
      preferencesStore: FakePreferencesStore(),
      restoredSession: Future.value(Result.ok(FakeAuthRepository.ada)),
    );
    await tester.pumpWidget(
      PebbyStandIn(
        child: ListenableBuilder(
          listenable: appearance,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.dark(
              palette: appearance.isDark ? AppPalette.dark : AppPalette.light,
            ),
            initialRoute: Routes.home,
            onGenerateRoute: router,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await appearance.setDark(true);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Me'));
    await tester.pump(const Duration(seconds: 1));
    await tester.drag(
      find.ancestor(
        of: find.text('Appearance'),
        matching: find.byType(Scrollable),
      ),
      const Offset(0, -2000),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Log out'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Log out').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(auth.logOuts, 1);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
