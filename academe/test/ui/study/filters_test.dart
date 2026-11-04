import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/study/study_actions.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:academe/ui/study/widgets/add_chapters_screen.dart';
import 'package:academe/ui/study/widgets/courses_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

final _light = PlannedChapter(
  id: 'cbse-10-science-9',
  subject: 'science',
  subjectName: 'Science',
  number: 9,
  title: 'Light – Reflection and Refraction',
  revisionDue: 2,
  lastStudiedAt: DateTime(2026, 10, 3),
  lessons: const [
    PlannedLesson(
      id: 'deck-1',
      position: 1,
      title: 'Reflection',
      isAvailable: true,
      minutes: 4,
    ),
  ],
);

const _reactions = PlannedChapter(
  id: 'cbse-10-science-1',
  subject: 'science',
  subjectName: 'Science',
  number: 1,
  title: 'Chemical Reactions and Equations',
  marks: 5,
  lessons: [
    PlannedLesson(
      id: 'cbse-10-science-1-1',
      position: 1,
      title: 'Chemical equations',
      isAvailable: false,
    ),
  ],
);

const _periodic = PlannedChapter(
  id: 'cbse-10-science-14',
  subject: 'science',
  subjectName: 'Science',
  number: 14,
  title: 'Periodic Classification of Elements',
  isFormativeOnly: true,
);

const _numbers = PlannedChapter(
  id: 'cbse-10-maths-1',
  subject: 'maths',
  subjectName: 'Maths',
  number: 1,
  title: 'Real Numbers',
);

const _progress = [
  SubjectProgress(id: 'maths', name: 'Maths'),
  SubjectProgress(id: 'science', name: 'Science'),
  SubjectProgress(id: 'english', name: 'English'),
];

void main() {
  late StudyViewModel viewModel;

  Future<void> start({List<String>? picks}) async {
    final study = FakeStudyRepository()
      ..chapterList = [_numbers, _reactions, _light, _periodic]
      ..subjectList = _progress;
    viewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: FakeProfileRepository(
        Profile(classLevel: 10, board: Board.cbse, subjects: picks),
      ),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();
  }

  List<int> numbers() => [for (final c in viewModel.chapters) c.number];

  test('only picked subjects show; no picks shows every subject', () async {
    await start(picks: ['science', 'english']);
    expect([for (final s in viewModel.subjects) s.id], ['science']);
    expect(
      [for (final r in viewModel.subjectRows) r.id],
      ['science', 'english'],
    );

    await start();
    expect([for (final s in viewModel.subjects) s.id], ['maths', 'science']);
    expect(viewModel.subjectRows.length, 3);
  });

  test('filters hide chapters and sorts reorder them', () async {
    await start();
    viewModel.selectSubject('science');
    expect(numbers(), [1, 9, 14]);

    viewModel.setFilters(const ChapterFilters().toggle(ChapterFlag.boardOnly));
    expect(numbers(), [1, 9]);
    viewModel.setFilters(viewModel.filters.toggle(ChapterFlag.ready));
    expect(numbers(), [9]);
    expect(viewModel.filters.count, 2);

    viewModel.setFilters(
      const ChapterFilters().toggle(ChapterFlag.revisionDue),
    );
    expect(numbers(), [9]);

    viewModel.setFilters(const ChapterFilters().sortBy(ChapterSort.marks));
    expect(numbers(), [1, 9, 14]);
    viewModel.setFilters(const ChapterFilters().sortBy(ChapterSort.recent));
    expect(numbers(), [9, 1, 14]);
    expect(
      viewModel.countWith(const ChapterFilters().toggle(ChapterFlag.ready)),
      1,
    );
  });

  group('screens', () {
    Future<void> pump(WidgetTester tester, Widget page) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        PebbyStandIn(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: Scaffold(body: page),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final actions = StudyActions(
      openChapter: (_) {},
      openLesson: (_) {},
      openChapterTest: (_) {},
      openReview: (_) {},
      openFolder: (_) {},
      addToFolder: (_) {},
    );

    testWidgets('the Filters key opens the sheet; chips clear filters', (
      tester,
    ) async {
      await start(picks: ['science', 'english']);
      await pump(tester, CoursesView(viewModel: viewModel, actions: actions));

      expect(find.text('Maths'), findsNothing);
      expect(find.text('Periodic Classification of Elements'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Show 3 chapters'), findsOneWidget);
      await tester.tap(find.text('Board exam only'));
      await tester.pumpAndSettle();
      expect(find.text('Show 2 chapters'), findsOneWidget);
      await tester.tap(find.text('Ready to study'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show 1 chapter'));
      await tester.pumpAndSettle();

      expect(find.text('Board exam'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1 chapter'), findsOneWidget);
      expect(find.text('Periodic Classification of Elements'), findsNothing);
      expect(find.text('Chemical Reactions and Equations'), findsNothing);

      await tester.tap(find.text('Ready'));
      await tester.pumpAndSettle();
      expect(find.text('Chemical Reactions and Equations'), findsOneWidget);
      expect(find.text('Ready'), findsNothing);
    });

    testWidgets('Clear and sort in the sheet', (tester) async {
      await start();
      viewModel
        ..selectSubject('science')
        ..setFilters(const ChapterFilters().toggle(ChapterFlag.boardOnly));
      await pump(tester, CoursesView(viewModel: viewModel, actions: actions));

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.tap(find.text('Most marks'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show 3 chapters'));
      await tester.pumpAndSettle();

      expect(viewModel.filters.flags, isEmpty);
      expect(viewModel.filters.sort, ChapterSort.marks);
      expect(find.text('Most marks'), findsOneWidget);
    });

    testWidgets(
      'Add chapters offers ready picked subjects and the Filters key',
      (tester) async {
        await start(picks: ['maths', 'science', 'english']);
        await pump(
          tester,
          AddChaptersScreen(viewModel: viewModel, alreadyIn: const []),
        );

        expect(find.text('Science'), findsOneWidget);
        expect(find.text('Maths'), findsNothing);
        expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
        expect(
          find.text('Ch 9 · Light – Reflection and Refraction'),
          findsOneWidget,
        );
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Revision due'));
        await tester.pumpAndSettle();
        expect(find.text('Show 1 chapter'), findsOneWidget);
      },
    );
  });
}
