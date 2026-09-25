import '../../domain/models/folder.dart';
import '../../utils/result.dart';
import '../model/folder_models.dart';
import 'api_client.dart';

class FolderApiService {
  FolderApiService(this._api, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final ApiClient _api;
  final DateTime Function() _now;

  String get _day {
    final now = _now();
    return 'today=${dayString(now)}&offset=${now.timeZoneOffset.inMinutes}';
  }

  Future<Result<List<FolderSummary>>> folders(String accessToken) => _api.send(
    'GET',
    '/folders?$_day',
    accessToken: accessToken,
    parse: (json) => [
      for (final f in json['folders']! as List<Object?>)
        folderSummaryFromJson(f! as Map<String, Object?>),
    ],
  );

  Future<Result<FolderDetail>> folder(String accessToken, String id) =>
      _api.send(
        'GET',
        '/folders/$id?$_day',
        accessToken: accessToken,
        parse: folderDetailFromJson,
      );

  Future<Result<TodayPlan>> today(String accessToken) => _api.send(
    'GET',
    '/today?$_day',
    accessToken: accessToken,
    parse: todayPlanFromJson,
  );

  Future<Result<FolderSummary>> create(
    String accessToken, {
    required String name,
    DateTime? dueOn,
  }) => _api.send(
    'POST',
    '/folders',
    accessToken: accessToken,
    body: {'name': name, 'dueOn': dueOn == null ? '' : dayString(dueOn)},
    parse: folderSummaryFromJson,
  );

  Future<Result<FolderSummary>> update(
    String accessToken,
    String id, {
    required String name,
    required DateTime? dueOn,
    required bool reminds,
  }) => _api.send(
    'PUT',
    '/folders/$id',
    accessToken: accessToken,
    body: {
      'name': name,
      'dueOn': dueOn == null ? '' : dayString(dueOn),
      'reminds': reminds,
    },
    parse: folderSummaryFromJson,
  );

  Future<Result<void>> delete(String accessToken, String id) =>
      _none('DELETE', '/folders/$id', accessToken, null);

  Future<Result<void>> addChapters(
    String accessToken,
    String id,
    List<String> chapterIds,
  ) => _none('POST', '/folders/$id/chapters', accessToken, {
    'chapterIds': chapterIds,
  });

  Future<Result<void>> addNote(String accessToken, String id, String text) =>
      _none('POST', '/folders/$id/notes', accessToken, {'text': text});

  Future<Result<void>> deleteItem(String accessToken, String id, int itemId) =>
      _none('DELETE', '/folders/$id/items/$itemId', accessToken, null);

  Future<Result<void>> addTodo(String accessToken, String id, String title) =>
      _none('POST', '/folders/$id/todos', accessToken, {'title': title});

  Future<Result<void>> setTodoDone(
    String accessToken,
    String id,
    int todoId,
    bool done,
  ) => _none('PUT', '/folders/$id/todos/$todoId', accessToken, {'done': done});

  Future<Result<void>> deleteTodo(String accessToken, String id, int todoId) =>
      _none('DELETE', '/folders/$id/todos/$todoId', accessToken, null);

  Future<Result<void>> _none(
    String method,
    String path,
    String accessToken,
    Map<String, Object?>? body,
  ) => _api.send(
    method,
    path,
    accessToken: accessToken,
    body: body,
    parse: (_) {},
  );
}
