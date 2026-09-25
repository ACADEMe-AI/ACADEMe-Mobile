import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/session.dart';

const linked = 'uitest-linked-3456';

void main() {
  setUpJourney();

  testWidgets('academe://reset link opens New password over Home', (
    tester,
  ) async {
    final email = uniqueEmail('deeplink');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await tester.host(
      'open-reset-link $email',
      until: find.text('Save and log in'),
    );
    await tester.shot('new-password-from-link');
    await tester.enterPassword(linked);
    await tester.tapText('Save and log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 40),
    );
    await tester.host('reopen-reset-link', until: find.text('Save and log in'));
    await tester.enterPassword('uitest-again-7777');
    await tester.tapText('Save and log in');
    await tester.waitFor(find.text('Start again'));
    await tester.shot('link-expired');
    await tester.tapText('Start again');
    await tester.waitFor(find.text('Send code'));
    await tester.shot('forgot-after-expired');
    await tester.binding.handlePopRoute();
    await tester.pause(const Duration(seconds: 2));
    await logOut(tester);
    await logIn(tester, email, linked);
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 30),
    );
  });
}
