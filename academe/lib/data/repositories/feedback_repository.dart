import '../../domain/models/feedback.dart';
import '../../l10n/generated/app_localizations.dart';
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

String feedbackFailureMessage(Object error, AppLocalizations l10n) {
  if (error is! ApiException) {
    return l10n.feedbackFailGeneric;
  }
  return switch (error.code) {
    'too_many_requests' => switch (error.details['scope']) {
      'week' => l10n.feedbackFailWeek,
      _ => l10n.feedbackFailDay,
    },
    'invalid_feedback' => l10n.feedbackFailTooShort,
    ApiException.network => l10n.feedbackFailOffline,
    _ => l10n.feedbackFailGeneric,
  };
}
