import '../../domain/models/pro.dart';
import '../../utils/result.dart';
import '../model/billing_models.dart';
import 'api_client.dart';

class BillingApiService {
  BillingApiService(this._api);

  final ApiClient _api;

  Future<Result<ProPlan>> plan(String accessToken) => _api.send(
    'GET',
    '/me/plan',
    accessToken: accessToken,
    parse: proPlanFromJson,
  );

  Future<Result<ProPlan>> sync(String accessToken) => _api.send(
    'POST',
    '/billing/sync',
    accessToken: accessToken,
    parse: proPlanFromJson,
  );
}
