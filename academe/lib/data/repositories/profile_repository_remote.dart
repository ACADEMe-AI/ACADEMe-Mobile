import '../../domain/models/auth_failure.dart';
import '../../domain/models/board.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/subject.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/profile_api_service.dart';
import 'authorizer.dart';
import 'profile_repository.dart';

class ProfileRepositoryRemote extends ProfileRepository {
  ProfileRepositoryRemote({
    required ProfileApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final ProfileApiService _api;
  final Authorizer _authorizer;
  final _subjects = <String, List<Subject>>{};

  Profile? _profile;

  @override
  Profile? get profile => _profile;

  @override
  Future<Result<Profile>> load() async =>
      _keep(await _authorizer.authorized(_api.profile));

  @override
  Future<Result<Profile>> update(ProfileUpdate update) async => _keep(
    await _authorizer.authorized((token) => _api.update(token, update)),
  );

  @override
  Future<Result<List<Subject>>> subjects({
    required int classLevel,
    required Board board,
  }) async {
    final key = '$classLevel-${board.code}';
    if (_subjects[key] case final cached?) return Result.ok(cached);
    final result = await _api.subjects(classLevel: classLevel, board: board);
    switch (result) {
      case Ok(:final value):
        _subjects[key] = value;
        return result;
      case Error(:final error):
        return Result.error(_failure(error));
    }
  }

  Result<Profile> _keep(Result<Profile> result) {
    switch (result) {
      case Ok(:final value):
        _profile = value;
        notifyListeners();
        return result;
      case Error(:final error):
        return Result.error(_failure(error));
    }
  }

  static AuthException _failure(Exception error) => switch (error) {
    AuthException() => error,
    ApiException(code: ApiException.network) => const AuthException(
      AuthFailure.network,
    ),
    ApiException(code: 'invalid_token') => const AuthException(
      AuthFailure.signedOut,
    ),
    _ => const AuthException(AuthFailure.unknown),
  };
}
