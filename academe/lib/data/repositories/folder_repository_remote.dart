import '../../domain/models/folder.dart';
import '../../utils/result.dart';
import '../services/folder_api_service.dart';
import 'authorizer.dart';
import 'folder_repository.dart';

class FolderRepositoryRemote extends FolderRepository {
  FolderRepositoryRemote({
    required FolderApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final FolderApiService _api;
  final Authorizer _authorizer;

  Future<Result<T>> _call<T>(Future<Result<T>> Function(String token) call) =>
      _authorizer.authorized(call);

  Future<Result<T>> _change<T>(
    Future<Result<T>> Function(String token) call,
  ) async {
    final result = await _call(call);
    if (result is Ok) notifyListeners();
    return result;
  }

  @override
  Future<Result<List<FolderSummary>>> folders() => _call(_api.folders);

  @override
  Future<Result<FolderDetail>> folder(String id) =>
      _call((t) => _api.folder(t, id));

  @override
  Future<Result<TodayPlan>> today() => _call(_api.today);

  @override
  Future<Result<FolderSummary>> create({
    required String name,
    DateTime? dueOn,
  }) => _change((t) => _api.create(t, name: name, dueOn: dueOn));

  @override
  Future<Result<FolderSummary>> update(
    String id, {
    required String name,
    required DateTime? dueOn,
    required bool reminds,
  }) => _change(
    (t) => _api.update(t, id, name: name, dueOn: dueOn, reminds: reminds),
  );

  @override
  Future<Result<void>> delete(String id) => _change((t) => _api.delete(t, id));

  @override
  Future<Result<void>> addChapters(String id, List<String> chapterIds) =>
      _change((t) => _api.addChapters(t, id, chapterIds));

  @override
  Future<Result<void>> addNote(String id, String text) =>
      _change((t) => _api.addNote(t, id, text));

  @override
  Future<Result<void>> deleteItem(String id, int itemId) =>
      _change((t) => _api.deleteItem(t, id, itemId));

  @override
  Future<Result<void>> addTodo(String id, String title) =>
      _change((t) => _api.addTodo(t, id, title));

  @override
  Future<Result<void>> setTodoDone(String id, int todoId, bool done) =>
      _change((t) => _api.setTodoDone(t, id, todoId, done));

  @override
  Future<Result<void>> deleteTodo(String id, int todoId) =>
      _change((t) => _api.deleteTodo(t, id, todoId));
}
