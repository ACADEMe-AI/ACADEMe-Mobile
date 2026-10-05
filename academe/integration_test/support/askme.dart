import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';

Future<void> ask(WidgetTester tester, String question) async {
  await tester.fill('Ask anything…', question);
  await tester.tapIcon(Icons.arrow_upward_rounded);
  await tester.waitFor(find.text(question));
}

Future<void> waitForReply(WidgetTester tester, {int count = 1}) async {
  final end = DateTime.now().add(const Duration(seconds: 120));
  while (DateTime.now().isBefore(end)) {
    await tester.pause(const Duration(milliseconds: 500));
    if (find.byTooltip('Helpful').evaluate().length >= count) return;
  }
  await tester.shot('timeout');
  fail('No reply from Pebby. On screen: ${tester.visibleTexts()}');
}
