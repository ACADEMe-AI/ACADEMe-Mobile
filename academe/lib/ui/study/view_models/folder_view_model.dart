import 'package:flutter/foundation.dart';

import '../../../data/repositories/folder_repository.dart';
import '../../../domain/models/folder.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef FolderEdit = ({String name, DateTime? dueOn, bool reminds});

class FolderViewModel extends ChangeNotifier {
  FolderViewModel({
    required FolderRepository folderRepository,
    required this.folderId,
  }) : _repository = folderRepository {
    load = Command0(_load)..addListener(notifyListeners);
    edit = Command1(_edit)..addListener(notifyListeners);
    delete = Command0(() => _repository.delete(folderId))
      ..addListener(notifyListeners);
    _repository.addListener(_onChanged);
  }

  final FolderRepository _repository;
  final String folderId;

  late final Command0<void> load;
  late final Command1<FolderSummary, FolderEdit> edit;
  late final Command0<void> delete;

  FolderDetail? _detail;

  FolderDetail? get detail => _detail;

  List<String> get chapterIds => [
    for (final c in _detail?.chapters ?? const <FolderChapter>[]) c.chapterId,
  ];

  void _onChanged() {
    if (!delete.isCompleted) load.execute();
  }

  Future<Result<void>> _load() async {
    final result = await _repository.folder(folderId);
    if (result case Ok(:final value)) _detail = value;
    return result;
  }

  Future<Result<FolderSummary>> _edit(FolderEdit edit) => _repository.update(
    folderId,
    name: edit.name.trim(),
    dueOn: edit.dueOn,
    reminds: edit.reminds,
  );

  Future<void> addChapters(List<String> chapterIds) async {
    if (chapterIds.isEmpty) return;
    await _repository.addChapters(folderId, chapterIds);
  }

  Future<void> addNote(String text) async {
    if (text.trim().isEmpty) return;
    await _repository.addNote(folderId, text.trim());
  }

  Future<void> addTodo(String title) async {
    if (title.trim().isEmpty) return;
    await _repository.addTodo(folderId, title.trim());
  }

  Future<void> toggleTodo(StudyTask task) async {
    final todoId = task.todoId;
    if (task.kind != TaskKind.todo || todoId == null) return;
    await _repository.setTodoDone(folderId, todoId, !task.isDone);
  }

  Future<void> removeTodo(int todoId) =>
      _repository.deleteTodo(folderId, todoId);

  Future<void> removeItem(int itemId) =>
      _repository.deleteItem(folderId, itemId);

  @override
  void dispose() {
    _repository.removeListener(_onChanged);
    for (final command in <Command<Object?>>[load, edit, delete]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
