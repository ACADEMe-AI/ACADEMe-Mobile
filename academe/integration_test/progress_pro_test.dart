import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

Future<void> openMe(WidgetTester tester) async {
  await tester.tapText('Me');
  await tester.waitFor(find.text('ACADEMe Pro'));
}

void main() {
  setUpJourney();

  testWidgets('My Progress unlocks after Test Store purchase', (tester) async {
    final email = uniqueEmail('progress');
    await launchFresh(tester);
    await signUpWithEmail(tester, email: email);
    await completeSetup(tester);
    await tester.waitFor(find.text('Class 10 · CBSE'));
    await openMe(tester);
    await tester.tapText('My Progress');
    await tester.waitFor(find.text('My Progress is part of Pro'));
    await tester.shot('progress-hold');
    await tester.tapText('Go Pro · 3× limits');
    await tester.waitFor(find.text('Ask, scan and check as much as you like.'));
    await tester.tapText('Monthly');
    await tester.tapText('Continue');
    await tester.host('rc-buy', until: find.text('Welcome to ACADEMe Pro'));
    await tester.waitFor(
      find.text('Manage'),
      timeout: const Duration(seconds: 30),
    );
    await tester.tapText('My Progress');
    await tester.waitFor(find.text('My Progress'));
    expect(find.text('My Progress is part of Pro'), findsNothing);
    expect(find.textContaining('Your streak, level and XP'), findsOneWidget);
    await tester.shot('progress-pro');
  });
}
