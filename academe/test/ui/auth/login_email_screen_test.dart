import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/view_models/login_view_model.dart';
import 'package:academe/ui/auth/widgets/login_email_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeAuthRepository repository;
  var loggedIn = false;

  Future<void> pumpLogin(WidgetTester tester) async {
    repository = FakeAuthRepository();
    loggedIn = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: LoginEmailScreen(
          viewModel: LoginViewModel(authRepository: repository),
          onLoggedIn: () => loggedIn = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double pose(WidgetTester tester) =>
      tester.widget<Pebby>(find.byType(Pebby)).pose;

  testWidgets('logs in, celebrates, then hands off', (tester) async {
    await pumpLogin(tester);
    final logIn = find.widgetWithText(AppButton, 'Log in');
    expectOnlyAppFonts(tester);

    await tester.tap(logIn);
    expect(repository.logIns, isEmpty);

    expect(pose(tester), PebbyPose.happy);
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(pose(tester), PebbyPose.focused);
    await tester.enterText(find.byType(TextField).first, ' ada@school.in ');
    await tester.tap(find.byType(TextField).last);
    await tester.pump();
    expect(pose(tester), PebbyPose.coverEyes);
    await tester.enterText(find.byType(TextField).last, 'hunter22');
    await tester.pump();
    await tester.tap(logIn);
    await tester.pump();

    expect(repository.logIns.single, ('ada@school.in', 'hunter22'));
    expect(pose(tester), PebbyPose.celebrateSmall);
    expect(loggedIn, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(loggedIn, isTrue);
  });

  testWidgets('a wrong password is shown and Pebby encourages', (tester) async {
    await pumpLogin(tester);
    repository.nextFailure = const AuthException(AuthFailure.wrongCredentials);

    await tester.enterText(find.byType(TextField).first, 'ada@school.in');
    await tester.enterText(find.byType(TextField).last, 'wrong one');
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(find.text("That email and password don't match."), findsOneWidget);
    expect(pose(tester), PebbyPose.encourage);
    expect(loggedIn, isFalse);

    await tester.enterText(find.byType(TextField).last, 'right one');
    await tester.pump();
    expect(find.text("That email and password don't match."), findsNothing);
  });
}
