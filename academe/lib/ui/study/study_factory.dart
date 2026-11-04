import '../../data/repositories/folder_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/study_repository.dart';
import 'view_models/deck_view_model.dart';
import 'view_models/folder_view_model.dart';
import 'view_models/review_view_model.dart';
import 'view_models/study_view_model.dart';

class StudyFactory {
  const StudyFactory({
    required this.studyRepository,
    required this.profileRepository,
    required this.folderRepository,
  });

  final StudyRepository studyRepository;
  final ProfileRepository profileRepository;
  final FolderRepository folderRepository;

  DeckViewModel lesson(String deckId) => DeckViewModel.lesson(
    studyRepository: studyRepository,
    profileRepository: profileRepository,
    folderRepository: folderRepository,
    deckId: deckId,
  );

  DeckViewModel chapterTest(StudyChapter chapter) => DeckViewModel.chapterTest(
    studyRepository: studyRepository,
    profileRepository: profileRepository,
    folderRepository: folderRepository,
    chapterId: chapter.id,
    deckIds: [for (final l in chapter.lessons) l.id],
    title: 'Ch ${chapter.number} test',
  );

  ReviewViewModel review(String? chapterId) => ReviewViewModel(
    studyRepository: studyRepository,
    folderRepository: folderRepository,
    chapterId: chapterId,
  );

  FolderViewModel folder(String id) =>
      FolderViewModel(folderRepository: folderRepository, folderId: id);
}
