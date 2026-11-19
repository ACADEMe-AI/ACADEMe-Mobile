import '../../domain/models/feedback.dart';
import '../../utils/result.dart';
import 'api_client.dart';

class FeedbackApiService {
  FeedbackApiService(this._api);

  final ApiClient _api;

  Future<Result<void>> submit({
    required String accessToken,
    required FeedbackCategory category,
    required String message,
  }) async {
    final result = await _api.send<Map<String, Object?>>(
      'POST',
      '/me/feedback',
      accessToken: accessToken,
      body: {'category': category.code, 'message': message},
      parse: (json) => json,
    );
    return switch (result) {
      Ok() => Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }
}
