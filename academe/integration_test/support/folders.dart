import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';

const primerTitle = 'Get a nudge before your test';

Future<void> createFolder(
  WidgetTester tester,
  String name, {
  bool dismissPrimer = true,
}) async {
  await tester.tapText('Study');
  await tester.tapText('Folders');
  await tester.tapText('New folder');
  await tester.fill('Name', name);
  await tester.tapText('Add a date');
  await tester.tapText('OK');
  await tester.waitGone(find.text('Add a date'));
  await tester.shot('folder-sheet');
  await tester.tapText('Create');
  await tester.waitFor(find.text('What’s this folder for?'));
  if (dismissPrimer && await tester.appears(find.text(primerTitle))) {
    await tester.tapText('Not now');
    await tester.waitGone(find.text(primerTitle));
  }
}
