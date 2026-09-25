enum ChatMode {
  explain('explain', 'Explain'),
  solve('solve', 'Solve'),
  quiz('quiz', 'Quiz me');

  const ChatMode(this.code, this.label);

  final String code;
  final String label;

  static ChatMode fromCode(String code) =>
      values.firstWhere((mode) => mode.code == code, orElse: () => explain);
}

enum ChatRole { student, pebby }

enum ReportReason {
  wrong('wrong', 'It’s wrong'),
  harmful('harmful', 'It’s harmful or unsafe'),
  offensive('offensive', 'It’s rude or offensive'),
  other('other', 'Something else');

  const ReportReason(this.code, this.label);

  final String code;
  final String label;
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.mode,
    required this.title,
    required this.updatedAt,
  });

  final String id;
  final ChatMode mode;
  final String title;
  final DateTime updatedAt;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.body,
    this.rating = 0,
  });

  final int id;
  final ChatRole role;
  final String body;
  final int rating;

  bool get isPebby => role == ChatRole.pebby;

  ChatMessage copyWith({int? rating}) => ChatMessage(
    id: id,
    role: role,
    body: body,
    rating: rating ?? this.rating,
  );
}

class ChatExchange {
  const ChatExchange({
    required this.thread,
    required this.question,
    required this.reply,
  });

  final ChatThread thread;
  final ChatMessage question;
  final ChatMessage reply;
}

enum ChatFailure { unavailable, network, signedOut, limitReached, unknown }

class ChatException implements Exception {
  const ChatException(this.failure);

  final ChatFailure failure;

  @override
  String toString() => 'ChatException($failure)';
}
