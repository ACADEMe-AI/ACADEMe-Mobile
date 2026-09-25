import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/view_models/new_password_view_model.dart';
import 'package:academe/ui/auth/widgets/new_password_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeAuthRepository repository;
  var isDone = false;
  var startedOver = false;

  Future<void> pumpNewPassword(WidgetTester tester) async {
    repository = FakeAuthRepository();
    isDone = false;
    startedOver = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: NewPasswordScreen(
          viewModel: NewPasswordViewModel(
            authRepository: repository,
            resetToken: 'reset-token',
          ),
          onDone: () => isDone = true,
          onStartOver: () => startedOver = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double pose(WidgetTester tester) =>
      tester.widget<Pebby>(find.byType(Pebby)).pose;

  Finder save() => find.widgetWithText(AppButton, 'Save and log in');

  testWidgets('saves a long enough password and signs in', (tester) async {
    await pumpNewPassword(tester);
    expectOnlyAppFonts(tester);
    expect(tester.widget<AppButton>(save()).isEnabled, isFalse);
    expect(pose(tester), PebbyPose.coverEyes);

    await tester.enterText(find.byType(TextField), 'moon');
    await tester.pump();
    expect(tester.widget<AppButton>(save()).isEnabled, isFalse);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(pose(tester), PebbyPose.shy);

    await tester.enterText(find.byType(TextField), 'moonflower');
    await tester.pump();
    expect(tester.widget<AppButton>(save()).isEnabled, isTrue);
    await tester.tap(save());
    await tester.pump();

    expect(repository.passwordResets.single, ('reset-token', 'moonflower'));
    expect(repository.account, isNotNull);
    expect(pose(tester), PebbyPose.celebrateSmall);
    expect(isDone, isFalse);
    await tester.pump(const Duration(seconds: 1));
    expect(isDone, isTrue);
  });

  testWidgets('an expired reset offers to start again', (tester) async {
    await pumpNewPassword(tester);
    repository.nextFailure = const AuthException(AuthFailure.resetExpired);

    await tester.enterText(find.byType(TextField), 'moonflower');
    await tester.pump();
    await tester.tap(save());
    await tester.pumpAndSettle();

    expect(find.textContaining('This reset link timed out'), findsOneWidget);
    expect(pose(tester), PebbyPose.encourage);
    await tester.tap(find.widgetWithText(AppButton, 'Start again'));
    expect(startedOver, isTrue);
    expect(isDone, isFalse);
  });
}
