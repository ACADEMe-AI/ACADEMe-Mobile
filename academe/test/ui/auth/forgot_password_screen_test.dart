import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/view_models/forgot_password_view_model.dart';
import 'package:academe/ui/auth/widgets/forgot_password_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeAuthRepository repository;
  String? sentTo;

  Future<void> pumpForgot(WidgetTester tester, {String email = ''}) async {
    repository = FakeAuthRepository();
    sentTo = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: ForgotPasswordScreen(
          viewModel: ForgotPasswordViewModel(
            authRepository: repository,
            email: email,
          ),
          onCodeSent: (email) => sentTo = email,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double pose(WidgetTester tester) =>
      tester.widget<Pebby>(find.byType(Pebby)).pose;

  AppButton sendButton(WidgetTester tester) =>
      tester.widget<AppButton>(find.widgetWithText(AppButton, 'Send code'));

  testWidgets('sends a code to the typed email', (tester) async {
    await pumpForgot(tester);
    expectOnlyAppFonts(tester);
    expect(find.text('Forgot your\npassword?'), findsOneWidget);
    expect(sendButton(tester).isEnabled, isFalse);
    expect(pose(tester), PebbyPose.happy);

    await tester.enterText(find.byType(TextField), 'maya@school');
    await tester.pump();
    expect(sendButton(tester).isEnabled, isFalse);
    expect(pose(tester), PebbyPose.focused);

    await tester.enterText(find.byType(TextField), ' maya@school.in ');
    await tester.pump();
    await tester.tap(find.widgetWithText(AppButton, 'Send code'));
    await tester.pumpAndSettle();

    expect(repository.resetRequests, ['maya@school.in']);
    expect(sentTo, 'maya@school.in');
  });

  testWidgets('starts with the email from log in', (tester) async {
    await pumpForgot(tester, email: 'ada@school.in');
    expect(find.text('ada@school.in'), findsOneWidget);
    expect(sendButton(tester).isEnabled, isTrue);
  });

  testWidgets('too many requests is shown until the email changes', (
    tester,
  ) async {
    await pumpForgot(tester, email: 'ada@school.in');
    repository.nextFailure = const AuthException(AuthFailure.tooManyRequests);

    await tester.tap(find.widgetWithText(AppButton, 'Send code'));
    await tester.pumpAndSettle();

    expect(find.textContaining("That's a lot of tries"), findsOneWidget);
    expect(pose(tester), PebbyPose.encourage);
    expect(sentTo, isNull);

    await tester.enterText(find.byType(TextField), 'ada@school.co');
    await tester.pump();
    expect(find.textContaining("That's a lot of tries"), findsNothing);
  });
}
