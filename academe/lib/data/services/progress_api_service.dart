import '../../domain/models/progress_summary.dart';
import '../../utils/result.dart';
import 'api_client.dart';

class ProgressApiService {
  ProgressApiService(this._api);

  final ApiClient _api;

  Future<Result<ProgressSummary>> fetch({required String accessToken}) =>
      _api.send(
        'GET',
        '/me/progress',
        accessToken: accessToken,
        parse: ProgressSummary.fromJson,
      );
}
