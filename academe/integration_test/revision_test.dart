import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/study.dart';

void main() {
  setUpJourney();

  testWidgets('kept and missed cards come back in revision', (tester) async {
    await newStudent(tester, 'revision');
    await tester.tapText('Flashcards');
    await tester.waitFor(find.text('Nothing to revise'));
    await tester.shot('empty-revision');
    await tester.tapOn(find.byTooltip('Back'));
    await openFirstChapter(tester);
    await tester.tapText('Next lesson');
    await playDeck(tester);
    await tester.tapText('Back to chapter');
    await tester.tapText('Kept cards');
    await tester.waitFor(find.text('Show answer'));
    await tester.shot('revision-card');
    for (var i = 0; i < 20; i++) {
      if (await tester.appears(
        find.text('Revision done'),
        timeout: Duration.zero,
      )) {
        break;
      }
      await tester.tapText('Show answer');
      await tester.tapText(i.isEven ? 'Knew it' : 'Didn’t know');
      await tester.pause();
    }
    await tester.waitFor(find.text('Revision done'));
    await tester.shot('revision-done');
    await tester.tapText('Done');
    await tester.waitFor(find.byIcon(Icons.bookmark_rounded));
  });
}
