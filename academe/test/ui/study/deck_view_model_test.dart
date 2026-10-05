import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/study/view_models/deck_view_model.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_folder_repository.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

void main() {
  late FakeStudyRepository study;
  late FakeFolderRepository folders;
  late FakeProfileRepository profiles;

  setUp(() {
    study = FakeStudyRepository();
    folders = FakeFolderRepository();
    profiles = FakeProfileRepository(
      const Profile(classLevel: 10, board: Board.cbse),
    );
  });

  DeckViewModel lesson() => DeckViewModel.lesson(
    studyRepository: study,
    profileRepository: profiles,
    folderRepository: folders,
    deckId: FakeStudyRepository.reflection.id,
  );

  test('a lesson steps through start, concept, example and a quiz', () async {
    final viewModel = lesson();
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    expect(viewModel.title, 'Reflection');
    expect(viewModel.current.content, isA<StartCard>());
    await viewModel.primary();
    expect(viewModel.current.content, isA<ConceptCard>());
    expect(study.positions.last, (FakeStudyRepository.reflection.id, 1));

    await viewModel.toggleKeep(1);
    expect(viewModel.isKept(1), isTrue);
    expect(study.kept, contains((FakeStudyRepository.reflection.id, 1)));

    await viewModel.primary();
    expect(viewModel.hasHiddenStep, isTrue);
    await viewModel.primary();
    expect(viewModel.revealedOf(2), 2);
    expect(viewModel.hasHiddenStep, isFalse);

    await viewModel.primary();
    expect(viewModel.needsCheck, isTrue);
    expect(viewModel.canGoForward, isFalse);
    viewModel.pick(1);
    await viewModel.primary();
    expect(viewModel.resultOf(3), isTrue);
    expect(viewModel.xpEarned, 5);
    expect(viewModel.streakAt(3), 1);
    expect(viewModel.xpAt(3), 5);
  });

  test('a wrong answer adds a why card and keeps the question', () async {
    final viewModel = lesson();
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();
    for (var i = 0; i < 3; i++) {
      await viewModel.forward();
    }
    viewModel.pick(0);
    await viewModel.check();

    expect(viewModel.resultOf(3), isFalse);
    expect(viewModel.isKept(3), isTrue);
    await viewModel.forward();
    expect(viewModel.step.isWhy, isTrue);
    await viewModel.forward();
    expect(viewModel.current.content, isA<SummaryCard>());
    await viewModel.forward();

    expect(viewModel.isFinished, isTrue);
    expect(study.completions, [(FakeStudyRepository.reflection.id, 0)]);
    expect(study.positions.last, (FakeStudyRepository.reflection.id, 0));
    expect(folders.changes, 1);
  });

  test('a chapter test asks every quiz from every lesson', () async {
    final studyViewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: profiles,
    );
    addTearDown(studyViewModel.dispose);
    await studyViewModel.load.execute();
    final chapter = studyViewModel.chapter('cbse-10-science-9')!;
    final viewModel = DeckViewModel.chapterTest(
      studyRepository: study,
      profileRepository: profiles,
      folderRepository: folders,
      chapterId: chapter.id,
      deckIds: [for (final l in chapter.lessons) l.id],
      title: 'Ch 9 test',
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    expect(viewModel.cards, hasLength(2));
    viewModel.pick(1);
    await viewModel.primary();
    await viewModel.primary();
    viewModel.pick(1);
    await viewModel.primary();
    await viewModel.primary();
    await viewModel.primary();

    expect(viewModel.isFinished, isTrue);
    expect(study.chapterScores, [('cbse-10-science-9', 1, 2)]);
    expect(viewModel.lessonScores, [
      (title: 'Reflection', correct: 1, total: 1),
      (title: 'Spherical mirrors', correct: 0, total: 1),
    ]);
  });
}
