import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';
import 'flows.dart';

Future<void> logOut(WidgetTester tester) async {
  await tester.tapText('Me');
  await tester.scrollTo(find.text('Log out'));
  await tester.tapText('Log out');
  await tester.waitFor(find.text('Log out?'));
  await tester.tapOn(find.text('Log out'));
  await tester.waitFor(find.text('Get started'));
}

Future<void> logIn(WidgetTester tester, String email, String secret) async {
  await tester.tapText('Log in');
  await tester.tapText('Continue with email');
  await tester.waitFor(find.text('Log in to pick up where you left off.'));
  await tester.fill('Email', email);
  await tester.enterPassword(secret);
  await tester.tapText('Log in');
}
