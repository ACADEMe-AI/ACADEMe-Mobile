import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/folder.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/study/study_actions.dart';
import 'package:academe/ui/study/view_models/deck_view_model.dart';
import 'package:academe/ui/study/view_models/folder_view_model.dart';
import 'package:academe/ui/study/view_models/folders_view_model.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:academe/ui/study/widgets/deck_screen.dart';
import 'package:academe/ui/study/widgets/folder_screen.dart';
import 'package:academe/ui/study/widgets/study_screen.dart';
import 'package:academe/ui/study/widgets/swipe_deck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeStudyRepository study;
  late FakeFolderRepository folders;
  late FakeProfileRepository profiles;
  late List<String> opened;
  late StudyActions actions;

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(theme: AppTheme.dark(), home: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    study = FakeStudyRepository();
    folders = FakeFolderRepository();
    profiles = FakeProfileRepository(
      const Profile(classLevel: 10, board: Board.cbse),
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

  testWidgets('Study shows courses, then folders', (tester) async {
    final viewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: profiles,
    );
    final foldersViewModel = FoldersViewModel(folderRepository: folders);
    addTearDown(viewModel.dispose);
    addTearDown(foldersViewModel.dispose);
    await pump(
      tester,
      Scaffold(
        body: StudyScreen(
          viewModel: viewModel,
          folders: foldersViewModel,
          actions: actions,
          onNewFolder: () => opened.add('new'),
        ),
      ),
    );

    expect(find.text('Class 10 · CBSE'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    await tester.tap(find.text('Reflection'));
    await tester.tap(find.text('Light'));
    expect(opened, ['lesson:deck-1', 'chapter:cbse-10-science-9']);

    await tester.tap(find.text('Folders'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Make a folder'), findsOneWidget);
    await tester.tap(find.text('New folder'));
    expect(opened.last, 'new');
    expectOnlyAppFonts(tester);
  });

  testWidgets('a lesson: start, keep, reveal steps, a wrong answer, done', (
    tester,
  ) async {
    await pump(
      tester,
      DeckScreen(
        viewModel: DeckViewModel.lesson(
          studyRepository: study,
          profileRepository: profiles,
          folderRepository: folders,
          deckId: FakeStudyRepository.reflection.id,
        ),
        onAsk: (q) => opened.add('ask'),
      ),
    );

    expect(find.text('Use the laws of reflection'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Light travels straight'), findsOneWidget);
    expect(find.text('Measure from the normal.'), findsOneWidget);
    await tester.tap(find.text('Keep'));
    await tester.pumpAndSettle();
    expect(find.text('Kept'), findsOneWidget);
    await tester.tap(find.text('Ask Pebby'));
    expect(opened, ['ask']);

    await tester.fling(find.byType(SwipeDeck), const Offset(-400, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Find r when i = 30°'), findsOneWidget);
    await tester.tap(find.text('Show step 2'));
    await tester.pumpAndSettle();
    expect(find.text('r = 30°'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.fling(find.byType(SwipeDeck), const Offset(-400, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Angle of reflection at 35°?'), findsOneWidget);
    await tester.tap(find.text('55°'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Measured from the normal.'), findsOneWidget);
    expect(find.text('KEPT FOR YOU'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('The lesson in three lines'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson done!'), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);
    expect(study.completions, [(FakeStudyRepository.reflection.id, 0)]);
  });

  testWidgets('a right answer celebrates with praise and XP', (tester) async {
    await pump(
      tester,
      DeckScreen(
        viewModel: DeckViewModel.lesson(
          studyRepository: study,
          profileRepository: profiles,
          folderRepository: folders,
          deckId: FakeStudyRepository.reflection.id,
        ),
        onAsk: (_) {},
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.fling(find.byType(SwipeDeck), const Offset(-400, 0), 2000);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('35°'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('You got it!'), findsOneWidget);
    expect(find.text('+5 XP'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Not quite. Next: why.'), findsNothing);
  });

  testWidgets('a folder shows today, its chapters and adds a to-do', (
    tester,
  ) async {
    folders.details['f1'] = FolderDetail(
      summary: FolderSummary(
        id: 'f1',
        name: 'Science unit test',
        dueOn: DateTime.now().add(const Duration(days: 5)),
        reminds: true,
        items: 1,
        todayLeft: 1,
        progress: 40,
      ),
      chapters: const [
        FolderChapter(
          itemId: 1,
          chapterId: 'cbse-10-science-9',
          subject: 'science',
          number: 9,
          title: 'Light',
          lessons: 3,
          lessonsDone: 1,
        ),
      ],
      notes: const [],
      today: const [
        StudyTask(
          kind: TaskKind.lesson,
          title: 'Lesson: Mirror formula',
          subtitle: 'Ch 9 · Light',
          minutes: 7,
          isDone: false,
          deckId: 'deck-3',
        ),
      ],
      plan: const [],
    );
    final studyViewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: profiles,
    );
    addTearDown(studyViewModel.dispose);
    await pump(
      tester,
      FolderScreen(
        viewModel: FolderViewModel(folderRepository: folders, folderId: 'f1'),
        study: studyViewModel,
        actions: actions,
      ),
    );

    expect(find.text('Science unit test'), findsOneWidget);
    expect(find.text('40% ready'), findsOneWidget);
    expect(find.text('Today · 7 min'), findsOneWidget);
    await tester.tap(find.text('Lesson: Mirror formula'));
    await tester.tap(find.text('Ch 9 · Light').last);
    expect(opened, ['lesson:deck-3', 'chapter:cbse-10-science-9']);

    await tester.enterText(find.byType(TextField), 'Learn ray diagrams');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(folders.todos, [('f1', 'Learn ray diagrams')]);
  });
}
