import 'package:academe/ui/study/widgets/courses_view.dart';
import 'package:academe/ui/study/widgets/pill_choices.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('Coming soon chapters show and do not open', (tester) async {
    await newStudent(tester, 'courses');
    await tester.tapText('Study');
    await tester.waitFor(find.byType(ChapterRow));
    final subjects = [
      for (final (_, label)
          in tester
              .widget<PillChoices<dynamic>>(
                find.byType(PillChoices<String>).first,
              )
              .choices)
        label,
    ];
    final soon = find.byWidgetPredicate(
      (w) => w is ChapterRow && w.chapter.isComingSoon,
    );
    final partly = find.byWidgetPredicate(
      (w) =>
          w is ChapterRow &&
          !w.chapter.isComingSoon &&
          w.chapter.lessonsComing > 0,
    );
    var sawSoon = false;
    var sawPartly = false;
    for (final subject in subjects) {
      await tester.tapText(subject);
      await tester.pause(const Duration(seconds: 1));
      if (!sawSoon && soon.evaluate().isNotEmpty) {
        await tester.scrollTo(soon.first);
        await tester.shot('coming-soon-$subject');
        await tester.tapOn(soon.first);
        await tester.pause();
        expect(find.text('Chapter test'), findsNothing);
        sawSoon = true;
      }
      if (!sawPartly && partly.evaluate().isNotEmpty) {
        await tester.scrollTo(partly.first);
        await tester.tapOn(partly.first);
        await tester.waitFor(find.textContaining('coming soon'));
        await tester.scrollTo(find.text('Coming soon'));
        await tester.shot('planned-lessons-$subject');
        await tester.tapOn(find.byTooltip('Back'));
        await tester.waitFor(find.byType(ChapterRow));
        sawPartly = true;
      }
      if (sawSoon && sawPartly) break;
    }
    expect(sawSoon || sawPartly, isTrue, reason: 'no Coming soon content');
  });
}
