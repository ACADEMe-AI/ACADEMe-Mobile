import 'package:academe/data/repositories/chat_repository.dart';
import 'package:academe/domain/models/chat.dart';
import 'package:academe/utils/result.dart';

class FakeChatRepository implements ChatRepository {
  ChatFailure? nextFailure;
  final sent = <({String? threadId, ChatMode mode, String text})>[];
  final ratings = <(int, int)>[];
  final reports = <(int, ReportReason)>[];
  final threadList = <ChatThread>[];
  final threadMessages = <String, List<ChatMessage>>{};
  int _id = 0;

  Result<T> _answer<T>(T Function() value) {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Result.error(ChatException(failure));
    }
    return Result.ok(value());
  }

  @override
  Future<Result<List<ChatThread>>> threads() async => _answer(() => threadList);

  @override
  Future<Result<List<ChatMessage>>> messages(String threadId) async =>
      _answer(() => threadMessages[threadId] ?? const []);

  @override
  Future<Result<ChatExchange>> send({
    required String? threadId,
    required ChatMode mode,
    required String text,
  }) async => _answer(() {
    sent.add((threadId: threadId, mode: mode, text: text));
    return ChatExchange(
      thread: ChatThread(
        id: threadId ?? 'thread-1',
        mode: mode,
        title: text,
        updatedAt: DateTime(2026, 9, 25),
      ),
      question: ChatMessage(id: ++_id, role: ChatRole.student, body: text),
      reply: ChatMessage(
        id: ++_id,
        role: ChatRole.pebby,
        body: 'Pebby on **$text**',
      ),
    );
  });

  @override
  Future<Result<ChatMessage>> regenerate(
    String threadId,
    ChatMode mode,
  ) async => _answer(
    () => ChatMessage(
      id: ++_id,
      role: ChatRole.pebby,
      body: 'Another way to see it',
    ),
  );

  @override
  Future<Result<void>> rate(int messageId, int rating) async =>
      _answer(() => ratings.add((messageId, rating)));

  @override
  Future<Result<void>> report(int messageId, ReportReason reason) async =>
      _answer(() => reports.add((messageId, reason)));
}
