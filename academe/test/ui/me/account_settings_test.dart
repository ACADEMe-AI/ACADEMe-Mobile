import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/data/repositories/billing_repository.dart';
import 'package:academe/domain/models/account.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/widgets/auth_failure_text.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/me/widgets/account_screen.dart';
import 'package:academe/ui/me/widgets/delete_account_screen.dart';
import 'package:academe/ui/me/widgets/password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_billing_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';

const emailOnly = Account(
  id: 'account-1',
  firstName: 'Maya',
  lastName: 'Rao',
  email: 'maya@example.com',
);

const googleOnly = Account(
  id: 'account-2',
  firstName: 'Ada',
  lastName: 'Lovelace',
  email: 'ada@gmail.com',
  hasPassword: false,
  googleEmail: 'ada@gmail.com',
);

const linked = Account(
  id: 'account-1',
  firstName: 'Maya',
  lastName: 'Rao',
  email: 'maya@example.com',
  googleEmail: 'maya.rao@gmail.com',
);

void main() {
  late FakeAuthRepository auth;
  late MeViewModel viewModel;

  Future<void> pump(
    WidgetTester tester,
    Account account,
    Widget Function() page, {
    BillingRepository? billing,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    auth = FakeAuthRepository(signedIn: account);
    viewModel = MeViewModel(
      authRepository: auth,
      profileRepository: FakeProfileRepository(),
      preferencesStore: FakePreferencesStore(),
      appearance: AppearanceRepository(store: FakeAppearanceStore()),
      billing: billing,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(body: page()),
        ),
      ),
    );
    await tester.pump();
  }

  Widget account() =>
      AccountScreen(viewModel: viewModel, onDeleteAccount: () {});

  group('Account sign-in rows', () {
    testWidgets('an email account can change its password and link Google', (
      tester,
    ) async {
      await pump(tester, emailOnly, account);
      expect(find.text('maya@example.com'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      expect(find.text('Link Google'), findsOneWidget);
      expect(find.text('Not linked'), findsOneWidget);
      expect(find.textContaining('coming soon'), findsNothing);

      await tester.tap(find.text('Link Google'));
      await tester.pumpAndSettle();
      expect(auth.googleLinks, 1);
      expect(find.text('ada@gmail.com'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(
        find.text('Google linked. You can log in with it now.'),
        findsOneWidget,
      );
    });

    testWidgets('linking a Google account that is taken says so', (
      tester,
    ) async {
      await pump(tester, emailOnly, account);
      auth.nextFailure = const AuthException(AuthFailure.googleTaken);
      await tester.tap(find.text('Link Google'));
      await tester.pumpAndSettle();
      expect(find.text('Not linked'), findsOneWidget);
      expect(
        find.text('That Google account is linked to another ACADEMe account.'),
        findsOneWidget,
      );
    });

    testWidgets('closing the Google picker shows nothing', (tester) async {
      await pump(tester, emailOnly, account);
      auth.nextFailure = const AuthException(AuthFailure.canceled);
      await tester.tap(find.text('Link Google'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Not linked'), findsOneWidget);
    });

    testWidgets('a linked account with a password can unlink Google', (
      tester,
    ) async {
      await pump(tester, linked, account);
      expect(find.text('maya.rao@gmail.com'), findsOneWidget);

      await tester.tap(find.text('Google'));
      await tester.pumpAndSettle();
      expect(find.text('Unlink Google?'), findsOneWidget);
      await tester.tap(find.text('Keep Google'));
      await tester.pumpAndSettle();
      expect(auth.googleUnlinks, 0);

      await tester.tap(find.text('Google'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlink'));
      await tester.pumpAndSettle();
      expect(auth.googleUnlinks, 1);
      expect(find.text('Not linked'), findsOneWidget);
      expect(
        find.text('Google unlinked. Log in with your email and password.'),
        findsOneWidget,
      );
    });

    testWidgets('a Google-only account must set a password before unlinking', (
      tester,
    ) async {
      await pump(tester, googleOnly, account);
      expect(find.text('Set a password'), findsOneWidget);
      expect(find.text('Change password'), findsNothing);

      await tester.tap(find.text('Google'));
      await tester.pumpAndSettle();
      expect(find.text('Unlink Google?'), findsNothing);
      expect(find.text(AuthFailure.passwordRequired.message), findsOneWidget);
      expect(auth.googleUnlinks, 0);
    });
  });

  group('Password screen', () {
    Future<void> type(WidgetTester tester, String label, String text) async {
      await tester.enterText(find.widgetWithText(TextField, label), text);
      await tester.pump();
    }

    testWidgets('changing needs the current password and 8+ characters', (
      tester,
    ) async {
      await pump(tester, emailOnly, account);
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      expect(find.text('Current password'), findsOneWidget);

      await type(tester, 'New password', 'marigold1');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(auth.passwordChanges, isEmpty);

      await type(tester, 'Current password', 'sunflower');
      await type(tester, 'New password', 'short');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(auth.passwordChanges, isEmpty);

      await type(tester, 'New password', 'marigold1');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(auth.passwordChanges, [('sunflower', 'marigold1')]);
      expect(find.byType(PasswordScreen), findsNothing);
      expect(find.text(PasswordScreen.changedMessage), findsOneWidget);
    });

    testWidgets('a wrong current password keeps the screen open', (
      tester,
    ) async {
      await pump(tester, emailOnly, () => PasswordScreen(viewModel: viewModel));
      await type(tester, 'Current password', 'guess');
      await type(tester, 'New password', 'marigold1');
      auth.nextFailure = const AuthException(AuthFailure.wrongPassword);
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(find.byType(PasswordScreen), findsOneWidget);
      expect(find.text("That isn't your current password."), findsOneWidget);
    });

    testWidgets('a Google-only account sets a password without the current '
        'one', (tester) async {
      await pump(tester, googleOnly, account);
      await tester.tap(find.text('Set a password'));
      await tester.pumpAndSettle();
      expect(find.text('Current password'), findsNothing);
      expect(find.text('Set a password'), findsOneWidget);

      await type(tester, 'New password', 'marigold1');
      await tester.tap(find.text('Save password'));
      await tester.pumpAndSettle();
      expect(auth.passwordChanges, [(null, 'marigold1')]);
      expect(find.text(PasswordScreen.setMessage), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
    });
  });

  group('Delete account subscription notice', () {
    Widget delete() =>
        DeleteAccountScreen(viewModel: viewModel, onDeleted: () {});

    testWidgets('a free student sees the notice without the link', (
      tester,
    ) async {
      await pump(tester, emailOnly, delete, billing: FakeBillingRepository());
      expect(find.text(DeleteAccountScreen.subscriptionNotice), findsOneWidget);
      expect(find.text('Manage subscription'), findsNothing);
    });

    testWidgets('a Pro student also gets Manage subscription', (tester) async {
      await pump(
        tester,
        emailOnly,
        delete,
        billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
      );
      expect(find.text(DeleteAccountScreen.subscriptionNotice), findsOneWidget);
      expect(find.text('Manage subscription'), findsOneWidget);
      expect(
        viewModel.manageSubscriptionUrl,
        BillingRepository.playSubscriptionsUrl,
      );
    });

    testWidgets('Manage subscription appears once Pro arrives', (tester) async {
      final billing = FakeBillingRepository()..restoresPro = true;
      await pump(tester, emailOnly, delete, billing: billing);
      expect(find.text('Manage subscription'), findsNothing);
      await billing.restore();
      await tester.pump();
      expect(find.text('Manage subscription'), findsOneWidget);
    });
  });
}
