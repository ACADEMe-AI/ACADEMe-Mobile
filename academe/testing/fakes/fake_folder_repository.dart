import 'package:academe/data/repositories/folder_repository.dart';
import 'package:academe/domain/models/folder.dart';
import 'package:academe/utils/result.dart';

class FakeFolderRepository extends FolderRepository {
  final summaries = <FolderSummary>[];
  final details = <String, FolderDetail>{};
  TodayPlan todayPlan = TodayPlan.empty;
  final added = <(String, List<String>)>[];
  final notes = <(String, String)>[];
  final todos = <(String, String)>[];
  final toggles = <(String, int, bool)>[];
  final deleted = <String>[];
  int changes = 0;

  @override
  void notifyListeners() {
    changes++;
    super.notifyListeners();
  }

  Result<void> _changed() {
    notifyListeners();
    return Result.ok(null);
  }

  @override
  Future<Result<List<FolderSummary>>> folders() async => Result.ok(summaries);

  @override
  Future<Result<FolderDetail>> folder(String id) async =>
      Result.ok(details[id]!);

  @override
  Future<Result<TodayPlan>> today() async => Result.ok(todayPlan);

  @override
  Future<Result<FolderSummary>> create({
    required String name,
    DateTime? dueOn,
  }) async {
    final folder = FolderSummary(
      id: 'folder-${summaries.length + 1}',
      name: name,
      dueOn: dueOn,
      reminds: true,
      items: 0,
      todayLeft: 0,
      progress: 0,
    );
    summaries.add(folder);
    notifyListeners();
    return Result.ok(folder);
  }

  @override
  Future<Result<FolderSummary>> update(
    String id, {
    required String name,
    required DateTime? dueOn,
    required bool reminds,
  }) async {
    notifyListeners();
    return Result.ok(
      FolderSummary(
        id: id,
        name: name,
        dueOn: dueOn,
        reminds: reminds,
        items: 0,
        todayLeft: 0,
        progress: 0,
      ),
    );
  }

  @override
  Future<Result<void>> delete(String id) async {
    deleted.add(id);
    return _changed();
  }

  @override
  Future<Result<void>> addChapters(String id, List<String> chapterIds) async {
    added.add((id, chapterIds));
    return _changed();
  }

  @override
  Future<Result<void>> addNote(String id, String text) async {
    notes.add((id, text));
    return _changed();
  }

  @override
  Future<Result<void>> deleteItem(String id, int itemId) async => _changed();

  @override
  Future<Result<void>> addTodo(String id, String title) async {
    todos.add((id, title));
    return _changed();
  }

  @override
  Future<Result<void>> setTodoDone(String id, int todoId, bool done) async {
    toggles.add((id, todoId, done));
    return _changed();
  }

  @override
  Future<Result<void>> deleteTodo(String id, int todoId) async => _changed();
}
