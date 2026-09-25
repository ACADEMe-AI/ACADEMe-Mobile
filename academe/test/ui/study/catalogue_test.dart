import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/study/study_actions.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:academe/ui/study/widgets/chapter_screen.dart';
import 'package:academe/ui/study/widgets/courses_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

const _light = PlannedChapter(
  id: 'cbse-10-science-9',
  subject: 'science',
  subjectName: 'Science',
  number: 9,
  title: 'Light – Reflection and Refraction',
  unit: 'Natural Phenomena',
  lessons: [
    PlannedLesson(
      id: 'deck-1',
      position: 1,
      title: 'Reflection',
      isAvailable: true,
    ),
    PlannedLesson(
      id: 'deck-2',
      position: 2,
      title: 'Spherical mirrors',
      isAvailable: true,
    ),
    PlannedLesson(
      id: 'cbse-10-science-9-3',
      position: 3,
      title: 'Refraction',
      isAvailable: false,
    ),
  ],
);

const _reactions = PlannedChapter(
  id: 'cbse-10-science-1',
  subject: 'science',
  subjectName: 'Science',
  number: 1,
  title: 'Chemical Reactions and Equations',
  lessons: [
    PlannedLesson(
      id: 'cbse-10-science-1-1',
      position: 1,
      title: 'Chemical equations',
      isAvailable: false,
    ),
    PlannedLesson(
      id: 'cbse-10-science-1-2',
      position: 2,
      title: 'Types of reactions',
      isAvailable: false,
    ),
  ],
);

const _numbers = PlannedChapter(
  id: 'cbse-10-maths-1',
  subject: 'maths',
  subjectName: 'Maths',
  number: 1,
  title: 'Real Numbers',
);

void main() {
  late FakeStudyRepository study;
  late StudyViewModel viewModel;
  late List<String> opened;
  late StudyActions actions;

  setUp(() {
    study = FakeStudyRepository()..chapterList = [_numbers, _reactions, _light];
    viewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: FakeProfileRepository(
        const Profile(classLevel: 10, board: Board.cbse),
      ),
    );
    opened = [];
    actions = StudyActions(
      openChapter: (id) => opened.add('chapter:$id'),
      openLesson: (id) => opened.add('lesson:$id'),
      openChapterTest: (id) => opened.add('test:$id'),
      openReview: (id) => opened.add('review:$id'),
      openFolder: (id) => opened.add('folder:$id'),
      addToFolder: (ids) => opened.add('add:${ids.join()}'),
    );
  });

  tearDown(() => viewModel.dispose());

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

  test('the catalogue lists every chapter, written or not', () async {
    await viewModel.load.execute();

    expect(viewModel.subjects, [
      (id: 'maths', name: 'Maths'),
      (id: 'science', name: 'Science'),
    ]);
    expect(viewModel.subject, 'science');
    expect([for (final c in viewModel.chapters) c.number], [1, 9]);
    final reactions = viewModel.chapter('cbse-10-science-1')!;
    expect(reactions.isComingSoon, isTrue);
    expect(reactions.isDone, isFalse);
    expect(reactions.lessonsPlanned, 2);
    final light = viewModel.chapter('cbse-10-science-9')!;
    expect(light.lessons, hasLength(2));
    expect(light.lessonsComing, 1);
    expect(
      [for (final o in light.outline) (o.title, o.lesson?.id)],
      [
        ('Reflection', 'deck-1'),
        ('Spherical mirrors', 'deck-2'),
        ('Refraction', null),
      ],
    );
    expect(viewModel.continueLesson?.id, 'deck-1');

    viewModel.selectSubject('maths');
    expect(viewModel.chapters.single.isComingSoon, isTrue);
    expect(viewModel.continueLesson, isNull);
    viewModel.selectFilter(ChapterFilter.done);
    expect(viewModel.chapters, isEmpty);
  });

  testWidgets('Courses greys out chapters that are coming soon', (
    tester,
  ) async {
    await viewModel.load.execute();
    await pump(tester, CoursesView(viewModel: viewModel, actions: actions));

    expect(find.text('Coming soon · 2 lessons'), findsOneWidget);
    expect(find.text('0 of 2 lessons · 1 coming soon'), findsOneWidget);
    await tester.tap(find.text('Chemical Reactions and Equations'));
    await tester.tap(find.text('Light – Reflection and Refraction'));
    expect(opened, ['chapter:cbse-10-science-9']);

    await tester.tap(find.text('Maths'));
    await tester.pumpAndSettle();
    expect(find.text('Real Numbers'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('a chapter lists its unwritten lessons, greyed', (tester) async {
    await viewModel.load.execute();
    await pump(
      tester,
      ChapterScreen(
        viewModel: viewModel,
        chapterId: 'cbse-10-science-9',
        actions: actions,
      ),
    );

    expect(find.text('0 of 2 lessons done · 1 coming soon'), findsOneWidget);
    expect(find.text('Refraction'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
    await tester.tap(find.text('Refraction'));
    await tester.tap(find.text('Spherical mirrors').last);
    expect(opened, ['lesson:deck-2']);
  });

  testWidgets('a chapter with no lessons yet has nothing to start', (
    tester,
  ) async {
    await viewModel.load.execute();
    await pump(
      tester,
      ChapterScreen(
        viewModel: viewModel,
        chapterId: 'cbse-10-science-1',
        actions: actions,
      ),
    );

    expect(find.text('Chemical equations'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(2));
    expect(find.text('Chapter test'), findsNothing);
    expect(find.text('Next lesson'), findsNothing);
  });
}
