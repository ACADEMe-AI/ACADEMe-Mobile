import '../../domain/models/auth_failure.dart';
import '../../domain/models/chat.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import '../services/chat_api_service.dart';
import 'authorizer.dart';
import 'chat_repository.dart';

class ChatRepositoryRemote implements ChatRepository {
  ChatRepositoryRemote({
    required ChatApiService api,
    required Authorizer authorizer,
  }) : _api = api,
       _authorizer = authorizer;

  final ChatApiService _api;
  final Authorizer _authorizer;

  @override
  Future<Result<List<ChatThread>>> threads() => _call(_api.threads);

  @override
  Future<Result<List<ChatMessage>>> messages(String threadId) =>
      _call((token) => _api.messages(token, threadId));

  @override
  Future<Result<ChatExchange>> send({
    required String? threadId,
    required ChatMode mode,
    required String text,
  }) => _call(
    (token) => _api.send(token, threadId: threadId, mode: mode, text: text),
  );

  @override
  Future<Result<ChatMessage>> regenerate(String threadId, ChatMode mode) =>
      _call((token) => _api.regenerate(token, threadId, mode));

  @override
  Future<Result<void>> rate(int messageId, int rating) =>
      _call((token) => _api.rate(token, messageId, rating));

  @override
  Future<Result<void>> report(int messageId, ReportReason reason) =>
      _call((token) => _api.report(token, messageId, reason));

  Future<Result<T>> _call<T>(
    Future<Result<T>> Function(String accessToken) call,
  ) async {
    final result = await _authorizer.authorized(call);
    return switch (result) {
      Ok() => result,
      Error(:final error) => Result.error(ChatException(_failure(error))),
    };
  }

  static ChatFailure _failure(Exception error) => switch (error) {
    ChatException(:final failure) => failure,
    AuthException(failure: AuthFailure.signedOut) => ChatFailure.signedOut,
    ApiException(code: ApiException.network) => ChatFailure.network,
    ApiException(code: 'askme_unavailable') => ChatFailure.unavailable,
    ApiException(code: 'limit_reached') => ChatFailure.limitReached,
    ApiException(code: 'invalid_token') => ChatFailure.signedOut,
    _ => ChatFailure.unknown,
  };
}
