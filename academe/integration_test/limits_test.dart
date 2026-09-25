import 'package:flutter_test/flutter_test.dart';

import 'support/askme.dart';
import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('paywall without billing, then the ASKMe free limit sheet', (
    tester,
  ) async {
    await newStudent(tester, 'limits');
    await tester.tapText('Me');
    await tester.waitFor(find.text('Free plan · go unlimited with Pro'));
    await tester.shot('pro-card');
    await tester.tapText('Go Pro');
    await tester.waitFor(find.text('Ask, scan and check as much as you like.'));
    await tester.waitFor(
      find.text('Purchases aren’t available on this device'),
    );
    await tester.shot('paywall-unavailable');
    await tester.tapOn(find.byTooltip('Close'));
    await tester.tapText('ASKMe');
    await ask(tester, 'What is 2 + 2? One word.');
    await waitForReply(tester);
    await ask(tester, 'What is 3 + 3? One word.');
    await waitForReply(tester, count: 2);
    await ask(tester, 'What is 4 + 4? One word.');
    await tester.tapText('Go Pro', timeout: const Duration(seconds: 60));
    await tester.waitFor(find.text('That’s today’s free questions'));
    await tester.shot('limit-sheet');
    await tester.tapText('Go Pro');
    await tester.waitFor(find.text('ACADEMe Pro'));
    await tester.shot('paywall-from-limit');
    await tester.tapOn(find.byTooltip('Close'));
    await tester.waitFor(find.text('What is 4 + 4? One word.'));
  });
}
