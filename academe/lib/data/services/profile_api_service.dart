import '../../domain/models/board.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/subject.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import 'api_client.dart';

class ProfileApiService {
  ProfileApiService(this._api);

  final ApiClient _api;

  Future<Result<Profile>> profile(String accessToken) => _api.send(
    'GET',
    '/me/profile',
    accessToken: accessToken,
    parse: profileFromJson,
  );

  Future<Result<Profile>> update(String accessToken, ProfileUpdate update) =>
      _api.send(
        'PATCH',
        '/me/profile',
        accessToken: accessToken,
        body: profileUpdateToJson(update),
        parse: profileFromJson,
      );

  Future<Result<List<Subject>>> subjects({
    required int classLevel,
    required Board board,
  }) => _api.send(
    'GET',
    '/catalog/subjects?class=$classLevel&board=${board.code}',
    parse: (json) => [
      for (final item in json['subjects']! as List<Object?>)
        subjectFromJson(item! as Map<String, Object?>),
    ],
  );
}
