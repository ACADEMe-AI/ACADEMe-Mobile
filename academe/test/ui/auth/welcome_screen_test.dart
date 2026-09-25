import 'package:academe/domain/models/auth_method.dart';
import 'package:academe/ui/auth/widgets/welcome_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';

void main() {
  Future<void> pumpWelcome(
    WidgetTester tester, {
    ValueChanged<AuthMethod>? onSignUp,
    Future<bool> Function(AuthMethod)? onLogIn,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: WelcomeScreen(onSignUp: onSignUp, onLogIn: onLogIn),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('opens on the start actions', (tester) async {
    await pumpWelcome(tester);

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expectOnlyAppFonts(tester);
  });

  testWidgets('Get started swaps the sheet to the sign-up choices', (
    tester,
  ) async {
    final chosen = <AuthMethod>[];
    await pumpWelcome(tester, onSignUp: chosen.add);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsWidgets);
    expect(find.text('Continue with Apple'), findsNothing);
    expectOnlyAppFonts(tester);
    await tester.tap(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with email'));
    expect(chosen, [AuthMethod.google, AuthMethod.email]);
  });

  testWidgets('Log in swaps the sheet to the log-in choices', (tester) async {
    final chosen = <AuthMethod>[];
    await pumpWelcome(
      tester,
      onLogIn: (method) async {
        chosen.add(method);
        return false;
      },
    );

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with email'));

    expect(chosen, [AuthMethod.email]);
  });

  testWidgets('choosing Sign up on the log-in screen reopens as sign-up', (
    tester,
  ) async {
    await pumpWelcome(tester, onLogIn: (_) async => true);
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue with email'));
    await tester.pumpAndSettle();

    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('each sheet links to the other', (tester) async {
    await pumpWelcome(tester);
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Already have an account? '), findsOneWidget);
  });

  testWidgets('back closes the choices first', (tester) async {
    await pumpWelcome(tester);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Get started'), findsOneWidget);
  });
}
