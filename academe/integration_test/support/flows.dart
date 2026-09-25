import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';

Future<void> signUpWithEmail(
  WidgetTester tester, {
  required String email,
  String firstName = 'Asha',
  String lastName = 'Rao',
}) async {
  await tester.tapText('Get started');
  await tester.tapText('Continue with email');
  await tester.tapText('Hi Pebby!', timeout: const Duration(seconds: 30));
  await tester.fill('First name', firstName);
  await tester.tapText('Continue');
  await tester.fill('Last name', lastName);
  await tester.tapText('Continue');
  await tester.fill('Email', email);
  await tester.tapText('Continue');
  await tester.enterPassword(password);
  await tester.tapText('Create account');
  await tester.tapText("Let's go", timeout: const Duration(seconds: 40));
}

Future<void> completeSetup(WidgetTester tester) async {
  await tester.waitFor(
    find.text('Which language do you learn in?'),
    timeout: const Duration(seconds: 40),
  );
  await tester.shot('setup-language');
  await tester.tapText('English');
  await tester.tapText('Choose English');
  await tester.waitFor(find.text('When were you born?'));
  await tester.tapText('Continue');
  await tester.waitFor(find.text('Spin to your class'));
  await tester.tapText('10');
  await tester.tapText('I’m in Class 10');
  await tester.waitFor(find.text('Which board?'));
  await tester.tapText('CBSE');
  await tester.tapText('Finish setup');
  await tester.waitGone(find.text('Which board?'));
  await tester.pause(const Duration(seconds: 3));
}

Future<void> newStudent(WidgetTester tester, String journey) async {
  await launchFresh(tester);
  await signUpWithEmail(tester, email: uniqueEmail(journey));
  await completeSetup(tester);
  await tester.waitFor(find.text('Class 10 · CBSE'));
  if (await tester.appears(find.text('Got it'))) {
    await tester.tapText('Got it');
  }
}

extension Passwords on WidgetTester {
  Future<void> enterPassword(String value) async {
    final field = find.byType(TextField).hitTestable();
    await waitFor(field);
    await tap(field.last, warnIfMissed: false);
    await enterText(field.last, value);
    await pause(const Duration(milliseconds: 300));
  }
}
