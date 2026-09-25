import '../../domain/models/scan.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/scan_api_service.dart';
import 'authorizer.dart';
import 'folder_repository.dart';
import 'scan_repository.dart';

class ScanRepositoryRemote extends ScanRepository {
  ScanRepositoryRemote({
    required ScanApiService api,
    required Authorizer authorizer,
    required FolderRepository folders,
  }) : _api = api,
       _authorizer = authorizer,
       _folders = folders;

  final ScanApiService _api;
  final Authorizer _authorizer;
  final FolderRepository _folders;

  Future<Result<T>> _call<T>(
    Future<Result<T>> Function(String token) call,
  ) async {
    final result = await _authorizer.authorized(call);
    return switch (result) {
      Ok() => result,
      Error(:final error) => Result.error(ScanException(_failureOf(error))),
    };
  }

  Future<Result<T>> _change<T>(
    Future<Result<T>> Function(String token) call,
  ) async {
    final result = await _call(call);
    if (result is Ok) notifyListeners();
    return result;
  }

  static ScanFailure _failureOf(Exception error) => switch (error) {
    ScanException(:final failure) => failure,
    ApiException(code: 'scan_unavailable') => ScanFailure.unavailable,
    ApiException(code: 'no_text') => ScanFailure.noText,
    ApiException(code: 'too_large') => ScanFailure.tooLarge,
    ApiException(code: 'pro_only') => ScanFailure.proOnly,
    ApiException(code: 'limit_reached', details: {'feature': 'check'}) =>
      ScanFailure.checkLimit,
    ApiException(code: 'limit_reached') => ScanFailure.scanLimit,
    ApiException(code: ApiException.network) => ScanFailure.network,
    _ => ScanFailure.unknown,
  };

  @override
  Future<Result<Scan>> read(ScanMode mode, List<String> pages) =>
      _change((t) => _api.read(t, mode, pages));

  @override
  Future<Result<List<Scan>>> scans() => _call(_api.scans);

  @override
  Future<Result<void>> linkThread(String id, String threadId) =>
      _change((t) => _api.linkThread(t, id, threadId));

  @override
  Future<Result<Marking>> check(String id, String question) =>
      _change((t) => _api.check(t, id, question));

  @override
  Future<Result<String?>> saveNotes(
    String id, {
    required String folderId,
    required bool makeLesson,
  }) async {
    final result = await _change(
      (t) => _api.saveNotes(t, id, folderId: folderId, makeLesson: makeLesson),
    );
    if (result is Ok) _folders.studyChanged();
    return result;
  }
}
