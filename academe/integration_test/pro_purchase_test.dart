import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

Future<void> openMe(WidgetTester tester) async {
  await tester.tapText('Me');
  await tester.waitFor(find.text('ACADEMe Pro'));
}

void main() {
  setUpJourney();

  testWidgets('Test Store monthly purchase turns Pro on and survives restore', (
    tester,
  ) async {
    final email = uniqueEmail('pro');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await openMe(tester);
    await tester.shot('pro-card-free');
    await tester.tapText('Go Pro');
    await tester.waitFor(find.text('Ask, scan and check as much as you like.'));
    await tester.pause(const Duration(seconds: 3));
    expect(find.textContaining('Lifetime'), findsNothing);
    await tester.shot('paywall-test-store');
    await tester.tapText('Monthly');
    await tester.tapText('Continue');
    await tester.pause(const Duration(seconds: 3));
    bridge('shot test-store-dialog');
    await tester.host('rc-buy', until: find.text('Welcome to ACADEMe Pro'));
    await tester.shot('welcome-pro');
    await tester.waitFor(
      find.text('Manage'),
      timeout: const Duration(seconds: 30),
    );
    await tester.shot('pro-card-pro');
    await tester.scrollTo(find.text('Log out'));
    await tester.tapText('Log out');
    await tester.tapOn(find.text('Log out'));
    await tester.waitFor(find.text('Get started'));
    await tester.tapText('Log in');
    await tester.tapText('Continue with email');
    await tester.fill('Email', email);
    await tester.enterPassword(password);
    await tester.tapText('Log in');
    await tester.waitFor(
      find.text('Class 10 · CBSE'),
      timeout: const Duration(seconds: 30),
    );
    await openMe(tester);
    await tester.tapText('Manage', timeout: const Duration(seconds: 30));
    await tester.waitFor(find.text('You’re on Pro'));
    await tester.shot('manage');
    await tester.tapText('Restore purchases');
    await tester.pause(const Duration(seconds: 5));
    await tester.waitFor(find.text('You’re on Pro'));
    await tester.shot('restored');
  });
}
