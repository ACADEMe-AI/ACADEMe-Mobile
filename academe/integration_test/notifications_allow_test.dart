import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/folders.dart';

void main() {
  setUpJourney();

  testWidgets('primer Allow then OS Allow shows Allowed in Me', (tester) async {
    await newStudent(tester, 'notifyallow');
    await createFolder(tester, 'Maths test', dismissPrimer: false);
    await tester.waitFor(find.text(primerTitle));
    await tester.tapText('Allow');
    await tester.pause(const Duration(seconds: 2));
    bridge('shot os-dialog');
    bridge('allow');
    await tester.waitGone(find.text(primerTitle));
    await tester.pause(const Duration(seconds: 3));
    await tester.tapOn(find.byTooltip('Back'));
    await tester.tapText('Me');
    await tester.scrollTo(find.text('Reminders and daily goal'));
    await tester.tapText('Reminders and daily goal');
    await tester.waitFor(find.text('Allowed'));
    await tester.shot('allowed');
  });
}
