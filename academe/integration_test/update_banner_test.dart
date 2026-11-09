import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('soft update banner appears and can be dismissed', (tester) async {
    await newStudent(tester, 'update-banner');
    // Server default message when ACADEME_UPDATE_MESSAGE is unset.
    // ui_test.sh sets ACADEME_RECOMMENDED_BUILD above APP_BUILD for this journey.
    await tester.waitFor(
      find.text('Update ACADEMe from Google Play to keep studying.'),
    );
    await tester.shot('update-banner');
    await tester.tapOn(find.byTooltip('Not now'));
    await tester.waitGone(
      find.text('Update ACADEMe from Google Play to keep studying.'),
    );
  });
}
