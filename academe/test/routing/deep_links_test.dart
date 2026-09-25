import 'dart:async';

import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/data/repositories/reminder_repository.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/routing/deep_links.dart';
import 'package:academe/routing/router.dart';
import 'package:academe/routing/routes.dart';
import 'package:academe/ui/auth/widgets/forgot_password_screen.dart';
import 'package:academe/ui/auth/widgets/new_password_screen.dart';
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
  test('reads the link token from every reset link shape', () {
    const cases = {
      'https://academe.cc/reset-password?c=abc': 'abc',
      '/reset-password?c=abc': 'abc',
      'academe://reset?c=abc': 'abc',
      '/?c=abc': 'abc',
      'https://academe.cc/reset-password': null,
      'https://academe.cc/reset-password?c=': null,
      'https://evil.example/reset-password?c=abc': null,
      'academe://open': null,
      'https://academe.cc/open': null,
      '/': null,
      '/login/forgot': null,
      null: null,
    };
    cases.forEach((route, token) {
      expect(resetLinkToken(route), token, reason: '$route');
    });
  });

  test('lets only reset links through while the app is open', () async {
    final filter = DeepLinkFilter();
    Future<bool> isSwallowed(String link) =>
        filter.didPushRouteInformation(RouteInformation(uri: Uri.parse(link)));

    expect(await isSwallowed('https://academe.cc/reset-password?c=abc'), false);
    expect(await isSwallowed('academe://reset?c=abc'), false);
    expect(await isSwallowed('academe://open'), true);
    expect(await isSwallowed('https://academe.cc/open'), true);
  });

  group('opening a reset link', () {
    late FakeAuthRepository auth;

    Future<void> pumpApp(WidgetTester tester, String initialRoute) async {
      auth = FakeAuthRepository();
      final appearance = AppearanceRepository(store: FakeAppearanceStore());
      final folders = FakeFolderRepository();
      await tester.pumpWidget(
        PebbyStandIn(
          child: MaterialApp(
            theme: AppTheme.dark(),
            initialRoute: initialRoute,
            onGenerateRoute: appRouter(
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
              restoredSession: Future.value(
                Result.error(const AuthException(AuthFailure.unknown)),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
    }

    Future<void> save(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField), 'moonflower');
      await tester.pump();
      await tester.tap(find.text('Save and log in'));
      await tester.pump();
    }

    testWidgets('opens New password and trades the link for a reset', (
      tester,
    ) async {
      await pumpApp(
        tester,
        'https://academe.cc/reset-password?c=${FakeAuthRepository.resetLink}',
      );
      expect(find.byType(NewPasswordScreen), findsOneWidget);

      await save(tester);

      expect(auth.linkRedemptions, [FakeAuthRepository.resetLink]);
      expect(auth.passwordResets, [('link-reset-token', 'moonflower')]);
      expect(auth.account, isNotNull);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('an expired link offers to ask for a new one', (tester) async {
      await pumpApp(tester, 'academe://reset?c=stale-link');

      await save(tester);
      await tester.pump(const Duration(seconds: 1));

      expect(auth.linkRedemptions, ['stale-link']);
      expect(auth.passwordResets, isEmpty);
      await tester.tap(find.text('Start again'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    for (final route in [
      '/reset-password?c=${FakeAuthRepository.resetLink}',
      '/?c=${FakeAuthRepository.resetLink}',
    ]) {
      testWidgets('a cold start from $route keeps New password on top', (
        tester,
      ) async {
        await pumpApp(tester, route);
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(NewPasswordScreen), findsOneWidget);

        await tester.binding.handlePopRoute();
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(NewPasswordScreen), findsNothing);
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });
    }

    testWidgets('a link opened while the app runs lands on New password', (
      tester,
    ) async {
      await pumpApp(tester, Routes.splash);
      await tester.pump(const Duration(seconds: 5));
      expect(find.byType(WelcomeScreen), findsOneWidget);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.pushNamed(
          '/reset-password?c=${FakeAuthRepository.resetLink}',
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(NewPasswordScreen), findsOneWidget);
    });
  });
}
