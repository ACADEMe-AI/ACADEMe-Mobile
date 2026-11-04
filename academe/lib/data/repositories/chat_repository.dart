import '../../domain/models/chat.dart';
import '../../utils/result.dart';

abstract class ChatRepository {
  Future<Result<List<ChatThread>>> threads();

  Future<Result<List<ChatMessage>>> messages(String threadId);

  Future<Result<ChatExchange>> send({
    required String? threadId,
    required ChatMode mode,
    required String text,
  });

  Future<Result<ChatMessage>> regenerate(String threadId, ChatMode mode);

  Future<Result<void>> rate(int messageId, int rating);

  Future<Result<void>> report(int messageId, ReportReason reason);
}
