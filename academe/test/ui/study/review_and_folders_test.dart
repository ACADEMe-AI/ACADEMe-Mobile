import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/folder.dart';
import 'package:academe/ui/study/view_models/folder_view_model.dart';
import 'package:academe/ui/study/view_models/folders_view_model.dart';
import 'package:academe/ui/study/view_models/review_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

void main() {
  test('revision reveals, rates and finishes', () async {
    final study = FakeStudyRepository()
      ..reviewItems = [
        for (final card in [1, 3])
          ReviewItem(
            deckId: 'deck-1',
            card: card,
            isMissed: card == 3,
            lessonTitle: 'Reflection',
            chapterTitle: 'Light',
            content: FakeStudyRepository.reflection.cards[card],
          ),
      ];
    final folders = FakeFolderRepository();
    final viewModel = ReviewViewModel(
      studyRepository: study,
      folderRepository: folders,
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    await viewModel.rate(ReviewRating.knew);
    expect(study.ratings, isEmpty);
    viewModel.reveal();
    await viewModel.rate(ReviewRating.knew);
    viewModel.reveal();
    await viewModel.rate(ReviewRating.again);

    expect(viewModel.isFinished, isTrue);
    expect(viewModel.countOf(ReviewRating.knew), 1);
    expect(study.ratings, [
      ('deck-1', 1, ReviewRating.knew),
      ('deck-1', 3, ReviewRating.again),
    ]);
    expect(folders.changes, 1);
  });

  test('a new folder shows up in the list', () async {
    final folders = FakeFolderRepository();
    final viewModel = FoldersViewModel(folderRepository: folders);
    addTearDown(viewModel.dispose);

    await viewModel.create.execute((name: '  Science test ', dueOn: null));
    await viewModel.load.execute();

    expect(viewModel.folders.single.name, 'Science test');
  });

  test('a folder adds chapters, notes and to-dos, and ticks to-dos', () async {
    final folders = FakeFolderRepository()
      ..details['f1'] = const FolderDetail(
        summary: FolderSummary(
          id: 'f1',
          name: 'Science test',
          dueOn: null,
          reminds: true,
          items: 1,
          todayLeft: 1,
          progress: 0,
        ),
        chapters: [
          FolderChapter(
            itemId: 1,
            chapterId: 'cbse-10-science-9',
            subject: 'science',
            number: 10,
            title: 'Light',
            lessons: 3,
            lessonsDone: 0,
          ),
        ],
        notes: [],
        today: [],
        plan: [],
      );
    final viewModel = FolderViewModel(
      folderRepository: folders,
      folderId: 'f1',
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    expect(viewModel.chapterIds, ['cbse-10-science-9']);
    await viewModel.addChapters(['cbse-10-maths-3']);
    await viewModel.addNote('  Class notes ');
    await viewModel.addTodo('   ');
    await viewModel.addTodo('Learn ray diagrams');
    await viewModel.toggleTodo(
      const StudyTask(
        kind: TaskKind.todo,
        title: 'Learn ray diagrams',
        subtitle: '',
        minutes: 0,
        isDone: false,
        todoId: 7,
      ),
    );

    expect(folders.added.single.$1, 'f1');
    expect(folders.added.single.$2, ['cbse-10-maths-3']);
    expect(folders.notes, [('f1', 'Class notes')]);
    expect(folders.todos, [('f1', 'Learn ray diagrams')]);
    expect(folders.toggles, [('f1', 7, true)]);
  });
}
