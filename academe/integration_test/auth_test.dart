import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('log out and log back in with email', (tester) async {
    final email = uniqueEmail('auth');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await tester.tapText('Me');
    await tester.scrollTo(find.text('Log out'));
    await tester.tapText('Log out');
    await tester.waitFor(find.text('Log out?'));
    await tester.shot('log-out-sheet');
    await tester.tapOn(find.text('Log out'));
    await tester.waitFor(find.text('Get started'));
    await tester.shot('logged-out');
    await tester.tapText('Log in');
    await tester.tapText('Continue with email');
    await tester.waitFor(find.text('Log in to pick up where you left off.'));
    await tester.fill('Email', email);
    await tester.enterPassword(password);
    await tester.tapText('Log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 30),
    );
    await tester.waitFor(find.text('Hi, Asha!'));
    await tester.shot('logged-in');
  });
}
