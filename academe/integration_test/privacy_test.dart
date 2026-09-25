import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('Privacy and terms links open the browser', (tester) async {
    await newStudent(tester, 'privacy');
    await tester.tapText('Me');
    await tester.scrollTo(find.text('Privacy and terms'));
    await tester.tapText('Privacy and terms');
    await tester.waitFor(find.text('Privacy policy'));
    await tester.shot('privacy');
    final links = {
      'Privacy policy': 'https://academe.cc/privacy',
      'Terms of use': 'https://academe.cc/terms',
      'Get a copy of my data': 'https://academe.cc/support',
      'Grievance Officer': 'https://academe.cc/support#grievance',
    };
    for (final MapEntry(key: label, value: url) in links.entries) {
      await tester.scrollTo(find.text(label));
      bridge('check-url $url');
      await tester.tapText(label);
      await tester.pause(const Duration(seconds: 6));
      await tester.waitFor(find.text('Privacy policy'));
    }
    await tester.scrollTo(find.text('support@academe.cc'));
    await tester.shot('privacy-bottom');
  });
}
