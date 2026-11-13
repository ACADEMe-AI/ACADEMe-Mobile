import '../../domain/models/folder.dart';

class StudyActions {
  const StudyActions({
    required this.openChapter,
    required this.openLesson,
    required this.openChapterTest,
    required this.openReview,
    required this.openFolder,
    required this.addToFolder,
  });

  final void Function(String chapterId) openChapter;
  final void Function(String deckId) openLesson;
  final void Function(String chapterId) openChapterTest;
  final void Function(String? chapterId) openReview;
  final void Function(String folderId) openFolder;
  final void Function(List<String> chapterIds) addToFolder;

  void openTask(StudyTask task) {
    switch (task.kind) {
      case TaskKind.lesson:
        if (task.deckId case final id?) openLesson(id);
      case TaskKind.test:
        if (task.chapterId case final id?) openChapterTest(id);
      case TaskKind.review:
        openReview(null);
      case TaskKind.todo:
        break;
    }
  }
}
