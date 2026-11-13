import '../../domain/models/app_config.dart';
import '../../utils/result.dart';
import 'api_client.dart';

class AppConfigApiService {
  AppConfigApiService(this._api);

  final ApiClient _api;

  Future<Result<AppConfig>> load() =>
      _api.send('GET', '/app/config', parse: AppConfig.fromJson);
}
