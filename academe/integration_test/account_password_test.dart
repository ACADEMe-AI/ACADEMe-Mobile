import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/session.dart';

const changed = 'uitest-changed-9012';

void main() {
  setUpJourney();

  testWidgets('change password from Account, old one refused', (tester) async {
    final email = uniqueEmail('account');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await tester.tapText('Me');
    await tester.scrollTo(find.text('Account'));
    await tester.tapText('Account');
    await tester.waitFor(find.text('Link Google'));
    expect(find.textContaining('coming soon'), findsNothing);
    await tester.shot('account');
    await tester.tapText('Change password');
    await tester.fill('Current password', 'not-my-password-1');
    await tester.fill('New password', changed);
    await tester.tapText('Save password');
    await tester.waitFor(find.text("That isn't your current password."));
    await tester.shot('wrong-current');
    await tester.fill('Current password', password);
    await tester.tapText('Save password');
    await tester.waitFor(
      find.text('Password changed. Other devices have been logged out.'),
    );
    await tester.shot('changed');
    await tester.tapOn(find.byTooltip('Back'));
    await tester.tapText('Study');
    await tester.pause(const Duration(seconds: 3));
    expect(find.text('Get started'), findsNothing);
    await logOut(tester);
    await logIn(tester, email, password);
    await tester.waitFor(find.text("That email and password don't match."));
    await tester.enterPassword(changed);
    await tester.tapText('Log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 30),
    );
    await tester.shot('logged-in-changed');
  });
}
