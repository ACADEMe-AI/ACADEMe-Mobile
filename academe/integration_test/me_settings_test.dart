import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('every Me settings screen opens and closes', (tester) async {
    await newStudent(tester, 'me');
    await tester.tapText('Me');
    await tester.waitFor(find.text('Asha Rao'));
    await tester.shot('me');
    final screens = {
      'Class and board': 'Class and board',
      'Appearance': 'Dark mode is easier on your eyes at night.',
      'Reminders and daily goal': 'Reminders and goal',
      'Account': 'Delete my account',
      'Help and feedback': 'Suggest a feature',
      'Privacy and terms': 'Privacy policy',
    };
    for (final MapEntry(key: row, value: marker) in screens.entries) {
      await tester.scrollTo(find.text(row));
      await tester.tapText(row);
      await tester.waitFor(find.text(marker));
      await tester.shot(row.toLowerCase().replaceAll(' ', '-'));
      await tester.tapOn(find.byTooltip('Back'));
      await tester.waitFor(find.text('Reminders and daily goal'));
    }
    await tester.scrollTo(find.text('App language'));
    await tester.tapText('App language');
    await tester.waitFor(find.text('English'));
    await tester.shot('language-sheet');
    await tester.binding.handlePopRoute();
    await tester.pause();
  });
}
