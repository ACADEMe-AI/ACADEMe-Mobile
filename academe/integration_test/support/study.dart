import 'package:academe/domain/models/deck.dart';
import 'package:academe/ui/study/widgets/courses_view.dart';
import 'package:academe/ui/study/widgets/deck_screen.dart';
import 'package:academe/ui/study/widgets/quiz_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';

class DeckRun {
  final seen = <Type>{};
  var right = 0;
  var wrong = 0;
  var kept = 0;
}

Future<void> openFirstChapter(WidgetTester tester) async {
  await tester.tapText('Study');
  await tester.waitFor(
    find.byType(ChapterRow),
    timeout: const Duration(seconds: 30),
  );
  await tester.shot('courses');
  await tester.tapOn(find.byType(ChapterRow).first);
  await tester.waitFor(find.text('Chapter test'));
}

Future<DeckRun> playDeck(
  WidgetTester tester, {
  bool keepOne = true,
  bool missOne = true,
  String name = 'lesson',
}) async {
  final run = DeckRun();
  await tester.waitFor(
    find.byType(DeckScreen),
    timeout: const Duration(seconds: 30),
  );
  for (var guard = 0; guard < 200; guard++) {
    final deck = find.byType(DeckScreen);
    if (deck.evaluate().isEmpty) break;
    final viewModel = tester.widget<DeckScreen>(deck).viewModel;
    if (!viewModel.isLoaded) {
      await tester.pause(const Duration(milliseconds: 300));
      continue;
    }
    if (viewModel.isFinished) break;
    final content = viewModel.current.content;
    if (run.seen.add(content.runtimeType)) {
      await tester.shot('$name-${content.runtimeType}');
    }
    if (keepOne && run.kept == 0 && content is ConceptCard) {
      await tester.tapText('Keep');
      await tester.waitFor(find.text('Kept'));
      run.kept++;
    }
    if (viewModel.needsCheck && content is QuizCard) {
      final isWrong = missOne && run.wrong == 0 && run.right > 0;
      final choice = isWrong
          ? (content.answer + 1) % content.options.length
          : content.answer;
      final options = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is QuizCardView && identical(w.card, content),
        ),
        matching: find.byType(OptionKey),
      );
      await tester.tapOn(options.at(choice));
      await tester.tapText('Check');
      await tester.waitFor(
        find.byIcon(
          isWrong ? Icons.cancel_rounded : Icons.check_circle_rounded,
        ),
      );
      isWrong ? run.wrong++ : run.right++;
      await tester.shot('$name-quiz-${isWrong ? 'wrong' : 'right'}-$guard');
      continue;
    }
    final index = viewModel.index;
    final label = RegExp(r'^(Start|Next|Finish|Show step \d+)$');
    await tester.tapOn(
      find.byWidgetPredicate((w) => w is Text && label.hasMatch(w.data ?? '')),
    );
    final end = DateTime.now().add(const Duration(seconds: 15));
    while (DateTime.now().isBefore(end) &&
        find.byType(DeckScreen).evaluate().isNotEmpty &&
        viewModel.index == index &&
        !viewModel.isFinished &&
        !viewModel.hasHiddenStep) {
      await tester.pause(const Duration(milliseconds: 200));
    }
  }
  await tester.pause(const Duration(seconds: 2));
  return run;
}
