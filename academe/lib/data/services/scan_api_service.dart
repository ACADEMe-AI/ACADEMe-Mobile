import '../../domain/models/scan.dart';
import '../../utils/result.dart';
import '../model/scan_models.dart';
import 'api_client.dart';

class ScanApiService {
  ScanApiService(this._api);

  final ApiClient _api;

  static const _slow = Duration(minutes: 3);

  Future<Result<Scan>> read(
    String accessToken,
    ScanMode mode,
    List<String> pages,
  ) => _api.send(
    'POST',
    '/scans',
    accessToken: accessToken,
    fields: {'mode': mode.code},
    files: pages,
    timeout: _slow,
    parse: scanFromJson,
  );

  Future<Result<List<Scan>>> scans(String accessToken) => _api.send(
    'GET',
    '/scans',
    accessToken: accessToken,
    parse: (json) => [
      for (final s in json['scans']! as List<Object?>)
        scanFromJson(s! as Map<String, Object?>),
    ],
  );

  Future<Result<void>> linkThread(
    String accessToken,
    String id,
    String threadId,
  ) => _api.send(
    'PUT',
    '/scans/$id/thread',
    accessToken: accessToken,
    body: {'threadId': threadId},
    parse: (_) {},
  );

  Future<Result<Marking>> check(
    String accessToken,
    String id,
    String question,
  ) => _api.send(
    'POST',
    '/scans/$id/check',
    accessToken: accessToken,
    body: {'question': question},
    timeout: _slow,
    parse: markingFromJson,
  );

  Future<Result<String?>> saveNotes(
    String accessToken,
    String id, {
    required String folderId,
    required bool makeLesson,
  }) => _api.send(
    'POST',
    '/scans/$id/notes',
    accessToken: accessToken,
    body: {'folderId': folderId, 'makeLesson': makeLesson},
    timeout: _slow,
    parse: (json) => json['deckId'] as String?,
  );
}
