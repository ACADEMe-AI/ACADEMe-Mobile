import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/folders.dart';

void main() {
  setUpJourney();

  testWidgets('folder with a date, chapters and to-dos shows on Today', (
    tester,
  ) async {
    await newStudent(tester, 'folders');
    await createFolder(tester, 'Maths unit test');
    await tester.shot('folder-new');
    await tester.tapText('Add chapters');
    await tester.waitFor(find.text('Pick chapters'));
    await tester.tapText('Maths');
    await tester.tapOn(find.textContaining('Ch 1 ·'));
    await tester.tapText('Add 1 chapter');
    await tester.waitFor(find.textContaining('lessons done'));
    await tester.shot('folder-chapters');
    for (final todo in ['Revise formulas', 'Pack geometry box']) {
      await tester.scrollTo(find.widgetWithText(TextField, 'Add a to-do'));
      await tester.fill('Add a to-do', todo);
      await tester.tapOn(find.byTooltip('Add'));
      await tester.waitFor(find.text(todo));
    }
    await tester.tapText('Revise formulas');
    await tester.waitFor(find.byIcon(Icons.check_rounded));
    await tester.shot('todo-ticked');
    await tester.tapOn(find.byTooltip('Back'));
    await tester.tapText('Home');
    await tester.waitFor(find.textContaining('Today ·'));
    await tester.scrollTo(find.text('Pack geometry box'));
    await tester.shot('home-today');
  });
}
