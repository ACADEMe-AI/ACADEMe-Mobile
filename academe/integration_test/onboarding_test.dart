import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('welcome, email sign-up and setup land on Home', (tester) async {
    await launchFresh(tester);
    await tester.waitFor(find.text('Get started'));
    await tester.shot('welcome');
    await signUpWithEmail(tester, email: uniqueEmail('onboarding'));
    await tester.shot('signed-up');
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await tester.waitFor(find.text('Hi, Asha!'));
    await tester.waitFor(find.text('Your subjects'));
    await tester.shot('home');
  });
}
