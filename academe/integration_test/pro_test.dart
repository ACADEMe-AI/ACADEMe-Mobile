import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('the Pro card opens the paywall', (tester) async {
    await newStudent(tester, 'pro');
    await tester.tapText('Me');
    await tester.waitFor(find.text('ACADEMe Pro'));
    await tester.shot('me-pro-card');
    await tester.tapText('ACADEMe Pro');
    await tester.waitFor(find.text('Unlimited ASKMe questions'));
    await tester.shot('paywall');
    await tester.tapOn(find.byTooltip('Close'));
    await tester.waitFor(find.text('Learning'));
  });
}
