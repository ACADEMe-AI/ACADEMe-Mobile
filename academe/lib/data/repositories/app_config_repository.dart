import '../../domain/models/app_config.dart';
import '../../utils/result.dart';
import '../services/app_config_api_service.dart';
import '../services/preferences_store.dart';

class AppConfigRepository {
  AppConfigRepository({
    required AppConfigApiService api,
    required PreferencesStore preferences,
  }) : _api = api,
       _preferences = preferences;

  final AppConfigApiService _api;
  final PreferencesStore _preferences;
  AppConfig? _cached;

  Future<Result<AppConfig>> load({bool refresh = false}) async {
    if (!refresh && _cached != null) {
      return Result.ok(_cached!);
    }
    final result = await _api.load();
    if (result case Ok(:final value)) {
      _cached = value;
    }
    return result;
  }

  Future<bool> shouldShowSoftBanner(AppConfig config) async {
    if (!config.shouldSoftUpdate) return false;
    final dismissed = await _preferences.softUpdateDismissedBuild();
    return dismissed < config.recommendedBuild;
  }

  Future<void> dismissSoftBanner(AppConfig config) =>
      _preferences.saveSoftUpdateDismissedBuild(config.recommendedBuild);
}
