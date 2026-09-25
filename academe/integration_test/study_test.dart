import 'package:academe/domain/models/deck.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/study.dart';

void main() {
  setUpJourney();

  testWidgets('play a lesson through every card type and the chapter test', (
    tester,
  ) async {
    await newStudent(tester, 'study');
    await openFirstChapter(tester);
    await tester.shot('chapter');
    await tester.tapText('Next lesson');
    final lesson = await playDeck(tester);
    expect(lesson.right, greaterThan(0));
    expect(lesson.wrong, 1);
    expect(lesson.kept, 1);
    expect(
      lesson.seen,
      containsAll([StartCard, ConceptCard, QuizCard, SummaryCard]),
    );
    await tester.waitFor(find.text('Back to chapter'));
    await tester.shot('lesson-done');
    await tester.tapText('Back to chapter');
    await tester.waitFor(find.text('1 to revise'));
    await tester.tapText('Chapter test');
    final test = await playDeck(tester, keepOne: false, name: 'test');
    expect(test.right + test.wrong, greaterThan(1));
    await tester.waitFor(find.text('Revise what you missed'));
    await tester.shot('chapter-report');
    await tester.tapText('Back to chapter');
    await tester.waitFor(find.textContaining('Last time'));
    await tester.shot('chapter-after-test');
  });
}
