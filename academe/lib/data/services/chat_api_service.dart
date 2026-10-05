import '../../domain/models/chat.dart';
import '../../utils/result.dart';
import '../model/api_models.dart';
import 'api_client.dart';

class ChatApiService {
  ChatApiService(this._api);

  final ApiClient _api;

  static const _replyTimeout = Duration(seconds: 60);

  Future<Result<List<ChatThread>>> threads(String accessToken) => _api.send(
    'GET',
    '/chat/threads',
    accessToken: accessToken,
    parse: (json) => [
      for (final item in json['threads']! as List<Object?>)
        chatThreadFromJson(item! as Map<String, Object?>),
    ],
  );

  Future<Result<List<ChatMessage>>> messages(
    String accessToken,
    String threadId,
  ) => _api.send(
    'GET',
    '/chat/threads/$threadId/messages',
    accessToken: accessToken,
    parse: (json) => [
      for (final item in json['messages']! as List<Object?>)
        chatMessageFromJson(item! as Map<String, Object?>),
    ],
  );

  Future<Result<ChatExchange>> send(
    String accessToken, {
    required String? threadId,
    required ChatMode mode,
    required String text,
  }) => _api.send(
    'POST',
    '/chat/messages',
    accessToken: accessToken,
    timeout: _replyTimeout,
    body: {'threadId': threadId, 'mode': mode.code, 'text': text},
    parse: (json) => ChatExchange(
      thread: chatThreadFromJson(json['thread']! as Map<String, Object?>),
      question: chatMessageFromJson(json['question']! as Map<String, Object?>),
      reply: chatMessageFromJson(json['reply']! as Map<String, Object?>),
    ),
  );

  Future<Result<ChatMessage>> regenerate(
    String accessToken,
    String threadId,
    ChatMode mode,
  ) => _api.send(
    'POST',
    '/chat/threads/$threadId/retry',
    accessToken: accessToken,
    timeout: _replyTimeout,
    body: {'mode': mode.code},
    parse: chatMessageFromJson,
  );

  Future<Result<void>> rate(String accessToken, int messageId, int rating) =>
      _api.send(
        'PUT',
        '/chat/messages/$messageId/rating',
        accessToken: accessToken,
        body: {'rating': rating},
        parse: (_) {},
      );

  Future<Result<void>> report(
    String accessToken,
    int messageId,
    ReportReason reason,
  ) => _api.send(
    'POST',
    '/chat/messages/$messageId/report',
    accessToken: accessToken,
    body: {'reason': reason.code},
    parse: (_) {},
  );
}
