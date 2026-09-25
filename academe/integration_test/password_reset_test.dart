import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

const newPassword = 'uitest-new-5678';

Future<void> logOut(WidgetTester tester) async {
  await tester.tapText('Me');
  await tester.scrollTo(find.text('Log out'));
  await tester.tapText('Log out');
  await tester.waitFor(find.text('Log out?'));
  await tester.tapOn(find.text('Log out'));
  await tester.waitFor(find.text('Get started'));
}

Future<void> logIn(WidgetTester tester, String email, String secret) async {
  await tester.tapText('Log in');
  await tester.tapText('Continue with email');
  await tester.waitFor(find.text('Log in to pick up where you left off.'));
  await tester.fill('Email', email);
  await tester.enterPassword(secret);
  await tester.tapText('Log in');
}

void main() {
  setUpJourney();

  testWidgets('forgot password, code from the server log, new password', (
    tester,
  ) async {
    final email = uniqueEmail('reset');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await logOut(tester);
    await tester.tapText('Log in');
    await tester.tapText('Continue with email');
    await tester.fill('Email', email);
    await tester.tapText('Forgot password?');
    await tester.waitFor(find.text('Send code'));
    expect(find.text(email), findsOneWidget);
    await tester.shot('forgot');
    await tester.tapText('Send code');
    await tester.waitFor(find.textContaining('a 6-digit code'));
    await tester.waitFor(find.textContaining('You can ask for a new code in'));
    await tester.shot('check-email');
    await tester.host('type-reset-code', until: find.text('Save and log in'));
    await tester.shot('new-password');
    await tester.enterPassword(newPassword);
    await tester.tapText('Save and log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 40),
    );
    await tester.shot('home-after-reset');
    await logOut(tester);
    await logIn(tester, email, password);
    await tester.waitFor(find.text("That email and password don't match."));
    await tester.shot('old-password-refused');
    await tester.enterPassword(newPassword);
    await tester.tapText('Log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 30),
    );
    await tester.shot('logged-in-new-password');
  });
}
