import 'package:flutter/foundation.dart';

import '../../domain/models/folder.dart';
import '../../utils/result.dart';

abstract class FolderRepository extends ChangeNotifier {
  Future<Result<List<FolderSummary>>> folders();

  Future<Result<FolderDetail>> folder(String id);

  Future<Result<TodayPlan>> today();

  Future<Result<FolderSummary>> create({required String name, DateTime? dueOn});

  Future<Result<FolderSummary>> update(
    String id, {
    required String name,
    required DateTime? dueOn,
    required bool reminds,
  });

  Future<Result<void>> delete(String id);

  Future<Result<void>> addChapters(String id, List<String> chapterIds);

  Future<Result<void>> addNote(String id, String text);

  Future<Result<void>> deleteItem(String id, int itemId);

  Future<Result<void>> addTodo(String id, String title);

  Future<Result<void>> setTodoDone(String id, int todoId, bool done);

  Future<Result<void>> deleteTodo(String id, int todoId);

  void studyChanged() => notifyListeners();
}
