import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/ui/auth/view_models/reset_code_view_model.dart';
import 'package:academe/ui/auth/widgets/reset_code_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeAuthRepository repository;
  String? token;

  Future<void> pumpCode(WidgetTester tester) async {
    repository = FakeAuthRepository();
    token = null;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        builder: (context, child) => PebbyStandIn(child: child!),
        home: ResetCodeScreen(
          viewModel: ResetCodeViewModel(
            authRepository: repository,
            email: 'maya@school.in',
          ),
          onVerified: (value) => token = value,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Finder field() => find.byType(TextField);

  AppButton verifyButton(WidgetTester tester) =>
      tester.widget<AppButton>(find.byType(AppButton));

  testWidgets('six digits verify on their own', (tester) async {
    await pumpCode(tester);
    expectOnlyAppFonts(tester);
    expect(find.textContaining('maya@school.in'), findsOneWidget);
    expect(verifyButton(tester).isEnabled, isFalse);

    await tester.enterText(field(), '4829');
    await tester.pump();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
    expect(repository.codeChecks, isEmpty);

    await tester.enterText(field(), FakeAuthRepository.resetCode);
    await tester.pump();

    expect(repository.codeChecks.single, ('maya@school.in', '482913'));
    expect(token, 'reset-token');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a wrong code is shown until the code changes', (tester) async {
    await pumpCode(tester);

    await tester.enterText(field(), '111111');
    await tester.pump();

    expect(find.textContaining("That code isn't right"), findsOneWidget);
    expect(tester.widget<Pebby>(find.byType(Pebby)).pose, PebbyPose.encourage);
    expect(token, isNull);

    await tester.enterText(field(), '11111');
    await tester.pump();
    expect(find.textContaining("That code isn't right"), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('too many attempts locks the code until a new one is sent', (
    tester,
  ) async {
    await pumpCode(tester);
    repository.nextFailure = const AuthException(AuthFailure.tooManyAttempts);

    await tester.enterText(field(), '222222');
    await tester.pump();

    expect(find.textContaining('Too many wrong tries'), findsOneWidget);
    expect(verifyButton(tester).isEnabled, isFalse);
    expect(tester.widget<TextField>(field()).enabled, isFalse);

    await tester.ensureVisible(find.text('Send a new code'));
    await tester.tap(find.text('Send a new code'));
    await tester.pump();

    expect(repository.resetRequests, ['maya@school.in']);
    expect(find.textContaining('Too many wrong tries'), findsNothing);
    expect(find.textContaining('New code sent'), findsOneWidget);
    expect(tester.widget<TextField>(field()).controller!.text, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an expired code asks for a new one', (tester) async {
    await pumpCode(tester);
    repository.nextFailure = const AuthException(AuthFailure.codeExpired);

    await tester.enterText(field(), FakeAuthRepository.resetCode);
    await tester.pump();

    expect(find.textContaining('That code has expired'), findsOneWidget);
    expect(find.text('Send a new code'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a new code can be asked for after 30 seconds', (tester) async {
    await pumpCode(tester);
    expect(find.text('You can ask for a new code in 0:29'), findsOneWidget);
    expect(find.text('Send a new code'), findsNothing);

    await tester.pump(const Duration(seconds: 29));

    expect(find.text('Send a new code'), findsOneWidget);
    await tester.ensureVisible(find.text('Send a new code'));
    await tester.tap(find.text('Send a new code'));
    await tester.pump();
    expect(repository.resetRequests, hasLength(1));
    expect(find.text('New code sent. You can ask again in 0:30'), findsOne);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a pasted code is cleaned up and verified', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => call.method == 'Clipboard.getData'
          ? {'text': 'Your ACADEMe code is 482 913'}
          : null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpCode(tester);

    await tester.tap(find.text('Paste code'));
    await tester.pump();

    expect(repository.codeChecks.single.$2, '482913');
    expect(token, 'reset-token');
    await tester.pumpWidget(const SizedBox());
  });
}
