import '../../domain/models/feedback.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/feedback_api_service.dart';
import 'authorizer.dart';

abstract class FeedbackRepository {
  Future<Result<void>> submit({
    required FeedbackCategory category,
    required String message,
  });
}

class FeedbackRepositoryRemote extends FeedbackRepository {
  FeedbackRepositoryRemote({
    required FeedbackApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final FeedbackApiService _api;
  final Authorizer _authorizer;

  @override
  Future<Result<void>> submit({
    required FeedbackCategory category,
    required String message,
  }) => _authorizer.authorized(
    (token) =>
        _api.submit(accessToken: token, category: category, message: message),
  );
}

String feedbackFailureMessage(Object error) {
  if (error is! ApiException) {
    return 'Couldn’t send that. Try again.';
  }
  return switch (error.code) {
    'too_many_requests' => switch (error.details['scope']) {
      'week' =>
        'You’ve sent the most feedback we can take this week. Try again next week.',
      _ =>
        'You’ve sent the most feedback we can take today. Try again tomorrow.',
    },
    'invalid_feedback' => 'Write at least 10 characters so we can help.',
    ApiException.network =>
      'You’re offline. Check your connection and try again.',
    _ => 'Couldn’t send that. Try again.',
  };
}
