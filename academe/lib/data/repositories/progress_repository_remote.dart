import '../../domain/models/progress_summary.dart';
import '../../utils/result.dart';
import '../services/progress_api_service.dart';
import 'authorizer.dart';
import 'progress_repository.dart';

class ProgressRepositoryRemote extends ProgressRepository {
  ProgressRepositoryRemote({
    required ProgressApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final ProgressApiService _api;
  final Authorizer _authorizer;

  @override
  Future<Result<ProgressSummary>> load() =>
      _authorizer.authorized((token) => _api.fetch(accessToken: token));
}
