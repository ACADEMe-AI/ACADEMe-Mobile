import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/folders.dart';

void main() {
  setUpJourney();

  testWidgets('primer, OS dialog denied, Settings, granted on resume', (
    tester,
  ) async {
    await newStudent(tester, 'notifydeny');
    await createFolder(tester, 'Science test', dismissPrimer: false);
    await tester.waitFor(find.text(primerTitle));
    await tester.shot('primer');
    bridge('deny');
    await tester.tapText('Allow');
    await tester.waitGone(find.text(primerTitle));
    await tester.pause(const Duration(seconds: 3));
    await tester.tapOn(find.byTooltip('Back'));
    await tester.tapText('Me');
    await tester.scrollTo(find.text('Reminders and daily goal'));
    await tester.tapText('Reminders and daily goal');
    await tester.waitFor(find.text('Not allowed'));
    await tester.waitFor(find.text('Turn on in Settings'));
    await tester.shot('denied');
    bridge('grant-from-settings');
    await tester.tapText('Turn on in Settings');
    await tester.waitFor(
      find.text('Allowed'),
      timeout: const Duration(seconds: 30),
    );
    await tester.shot('allowed-after-resume');
  });
}
