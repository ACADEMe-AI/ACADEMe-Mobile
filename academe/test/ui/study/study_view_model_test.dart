import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

void main() {
  test('chapters group lessons; continue resumes the started one', () async {
    final study = FakeStudyRepository()
      ..deckList = [
        FakeStudyRepository.summaryOf(
          FakeStudyRepository.reflection,
          isDone: true,
          kept: 2,
        ),
        FakeStudyRepository.summaryOf(
          FakeStudyRepository.mirrors,
          resumeCard: 1,
        ),
      ]
      ..results = [
        const ChapterResult(
          chapterId: 'cbse-10-science-9',
          correct: 3,
          total: 4,
        ),
      ];
    final viewModel = StudyViewModel(
      studyRepository: study,
      profileRepository: FakeProfileRepository(
        const Profile(classLevel: 10, board: Board.cbse),
      ),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    expect(viewModel.syllabusLabel, 'Class 10 · CBSE');
    expect(viewModel.subjects, [(id: 'science', name: 'Science')]);
    final chapter = viewModel.chapters.single;
    expect(chapter.lessons, hasLength(2));
    expect(chapter.lessonsDone, 1);
    expect(chapter.kept, 2);
    expect(chapter.result?.percent, 75);
    expect(chapter.resume.id, FakeStudyRepository.mirrors.id);
    expect(viewModel.continueLesson?.id, FakeStudyRepository.mirrors.id);
    expect(
      viewModel.nextAfter(FakeStudyRepository.reflection.id)?.id,
      FakeStudyRepository.mirrors.id,
    );

    viewModel.selectFilter(ChapterFilter.done);
    expect(viewModel.chapters, isEmpty);
    viewModel.selectFilter(ChapterFilter.inProgress);
    expect(viewModel.chapters, hasLength(1));
  });

  test('without a class and board there is nothing to show', () async {
    final viewModel = StudyViewModel(
      studyRepository: FakeStudyRepository()..deckList = const [],
      profileRepository: FakeProfileRepository(),
    );
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();

    expect(viewModel.hasSyllabus, isFalse);
    expect(viewModel.continueLesson, isNull);
  });
}
