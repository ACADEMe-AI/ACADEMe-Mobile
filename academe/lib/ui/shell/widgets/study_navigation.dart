import 'package:flutter/material.dart';

import '../../../domain/models/folder.dart';
import '../../../utils/result.dart';
import '../../scan/widgets/scan_flow_screen.dart';
import '../../study/study_actions.dart';
import '../../study/widgets/chapter_screen.dart';
import '../../study/widgets/deck_screen.dart';
import '../../study/widgets/folder_picker_sheet.dart';
import '../../study/widgets/folder_screen.dart';
import '../../study/widgets/folder_sheets.dart';
import '../../study/widgets/review_screen.dart';
import 'app_shell.dart';

mixin StudyNavigation on State<AppShell> {
  late final studyActions = StudyActions(
    openChapter: openChapter,
    openLesson: openLesson,
    openChapterTest: openChapterTest,
    openReview: openReview,
    openFolder: openFolder,
    addToFolder: addToFolder,
  );

  void askAbout(String question);

  void showMessage(String message);

  Future<void> _push(Widget page, {bool replace = false}) async {
    final route = MaterialPageRoute<void>(builder: (_) => page);
    final navigator = Navigator.of(context);
    await (replace ? navigator.pushReplacement(route) : navigator.push(route));
    if (mounted) await widget.study.load.execute();
  }

  void openChapter(String chapterId) => _push(
    ChapterScreen(
      viewModel: widget.study,
      chapterId: chapterId,
      actions: studyActions,
    ),
  );

  void openLesson(String deckId, {bool replace = false}) {
    final next = widget.study.nextAfter(deckId);
    _push(
      DeckScreen(
        viewModel: widget.factory.lesson(deckId),
        onAsk: askAbout,
        nextTitle: next?.title,
        onNext: next == null ? null : () => openLesson(next.id, replace: true),
      ),
      replace: replace,
    );
  }

  void openChapterTest(String chapterId) {
    final chapter = widget.study.chapter(chapterId);
    if (chapter == null) return;
    _push(
      DeckScreen(
        viewModel: widget.factory.chapterTest(chapter),
        onAsk: askAbout,
        onRevise: () => _push(
          ReviewScreen(viewModel: widget.factory.review(chapterId)),
          replace: true,
        ),
        onAddToFolder: () => addToFolder([chapterId]),
      ),
    );
  }

  void openReview(String? chapterId) =>
      _push(ReviewScreen(viewModel: widget.factory.review(chapterId)));

  void openFolder(String folderId) => _push(
    FolderScreen(
      viewModel: widget.factory.folder(folderId),
      study: widget.study,
      actions: studyActions,
      onReminders: widget.onRemindersWanted,
      onScanNotes: (id, name) => scanNotes((id: id, name: name)),
    ),
  );

  void scanNotes(FolderChoice folder);

  Future<FolderSummary?> newFolder({bool opens = true}) async {
    final edit = await FolderSheet.show(context);
    if (edit == null || !mounted) return null;
    await widget.folders.create.execute((name: edit.name, dueOn: edit.dueOn));
    final result = widget.folders.create.result;
    if (result is! Ok<FolderSummary>) {
      showMessage('Couldn’t make the folder. Try again.');
      return null;
    }
    if (edit.dueOn != null) widget.onRemindersWanted?.call();
    if (opens) openFolder(result.value.id);
    return result.value;
  }

  Future<FolderChoice?> pickFolder() async {
    await widget.folders.load.execute();
    if (!mounted) return null;
    final picked = await FolderPickerSheet.show(
      context,
      folders: widget.folders.folders,
    );
    if (picked == null || !mounted) return null;
    if (picked == FolderPickerSheet.newFolder) {
      final created = await newFolder(opens: false);
      return created == null ? null : (id: created.id, name: created.name);
    }
    final name = widget.folders.folders
        .where((f) => f.id == picked)
        .firstOrNull
        ?.name;
    return (id: picked, name: name ?? 'your folder');
  }

  Future<void> addToFolder(List<String> chapterIds) async {
    final picked = await pickFolder();
    if (picked == null) return;
    final folder = widget.factory.folder(picked.id);
    await folder.addChapters(chapterIds);
    folder.dispose();
    showMessage('Added to ${picked.name}');
  }
}
