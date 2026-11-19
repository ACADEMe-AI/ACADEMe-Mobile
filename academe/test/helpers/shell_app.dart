import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/routing/router.dart';
import 'package:academe/routing/routes.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/core/ui/top_notice.dart';
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

import 'test_repositories.dart';

Future<void> pumpShellApp(
  WidgetTester tester, {
  FakeStudyRepository? studies,
  FakeFolderRepository? folders,
  FakeProfileRepository? profiles,
}) async {
  final folderRepository = folders ?? FakeFolderRepository();
  final authRepository = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
  final router = appRouter(
    appearance: AppearanceRepository(store: FakeAppearanceStore()),
    authRepository: authRepository,
    profileRepository:
        profiles ??
        FakeProfileRepository(
          const Profile(classLevel: 10, board: Board.cbse, setupDone: true),
        ),
    chatRepository: FakeChatRepository(),
    billingRepository: FakeBillingRepository(),
    studyRepository: studies ?? FakeStudyRepository(),
    folderRepository: folderRepository,
    scans: ScanFactory(
      scanRepository: FakeScanRepository(),
      photoRepository: FakePhotoRepository(),
    ),
    reminders: ReminderRepository(
      notifications: FakeNotificationService(),
      folderRepository: folderRepository,
      profileRepository: FakeProfileRepository(),
      preferencesStore: FakePreferencesStore(),
      hintStore: FakeHintStore(),
    ),
    hintStore: FakeHintStore(),
    preferencesStore: FakePreferencesStore(),
    appConfigRepository: testAppConfigRepository(),
    feedbackRepository: testFeedbackRepository(authRepository),
    progressRepository: testProgressRepository(),
    restoredSession: Future.value(Result.ok(FakeAuthRepository.ada)),
  );
  final notices = TopNoticeController();
  await tester.pumpWidget(
    PebbyStandIn(
      child: TopNoticeScope(
        controller: notices,
        child: MaterialApp(
          locale: AppLanguage.english.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          initialRoute: Routes.home,
          onGenerateRoute: router,
          builder: (context, child) => Stack(
            children: [child ?? const SizedBox.shrink(), const TopNoticeHost()],
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}
