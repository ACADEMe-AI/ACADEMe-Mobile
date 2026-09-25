import 'package:academe/domain/models/auth_method.dart';
import 'package:academe/ui/auth/view_models/sign_up_view_model.dart';
import 'package:academe/ui/auth/widgets/sign_up_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  testWidgets('Pebby reacts through an email sign-up to the celebration', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: SignUpScreen(
          viewModel: SignUpViewModel(
            authRepository: FakeAuthRepository(),
            method: AuthMethod.email,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    double pose() => tester.widget<Pebby>(find.byType(Pebby)).pose;
    bool fieldHasFocus() => tester
        .widget<EditableText>(find.byType(EditableText))
        .focusNode
        .hasFocus;
    Future<void> tapPrimary() async {
      await tester.pump();
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();
    }

    expect(find.text("Hi, I'm Pebby!"), findsOneWidget);
    expect(pose(), PebbyPose.wave);
    expectOnlyAppFonts(tester);
    await tapPrimary();

    expect(
      find.text('Before we start, what should I call you?'),
      findsOneWidget,
    );
    expect(pose(), PebbyPose.happy);
    expect(fieldHasFocus(), isTrue, reason: 'the keyboard opens on step one');
    await tester.enterText(find.byType(TextField), 'Maya');
    await tester.pump();
    expect(pose(), PebbyPose.focused);
    await tapPrimary();

    expect(
      find.text('Nice to meet you, Maya! And your last name?'),
      findsOneWidget,
    );
    expect(fieldHasFocus(), isTrue, reason: 'the keyboard follows each step');
    await tester.enterText(find.byType(TextField), 'Rao');
    await tapPrimary();

    await tester.enterText(find.byType(TextField), 'maya@school');
    await tapPrimary();
    expect(find.text("That doesn't look like an email yet."), findsOneWidget);
    expect(pose(), PebbyPose.encourage);
    await tester.enterText(find.byType(TextField), 'maya@school.in');
    await tapPrimary();

    expect(find.text('Create a password'), findsOneWidget);
    expect(pose(), PebbyPose.coverEyes);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(pose(), PebbyPose.shy);
    await tester.enterText(find.byType(TextField), 'long enough');
    await tapPrimary();

    expect(find.text("You're in, Maya!"), findsOneWidget);
    expect(pose(), PebbyPose.celebrateBig);
    expect(find.text("Let's go"), findsOneWidget);
  });
}
