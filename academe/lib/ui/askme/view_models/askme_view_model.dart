import 'package:flutter/foundation.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../domain/models/chat.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class AskMeViewModel extends ChangeNotifier {
  AskMeViewModel({required ChatRepository chatRepository})
    : _repository = chatRepository {
    send = Command1(_send)..addListener(notifyListeners);
    regenerate = Command0(_regenerate)..addListener(notifyListeners);
    loadThreads = Command0(_loadThreads)..addListener(notifyListeners);
    open = Command1(_open)..addListener(notifyListeners);
  }

  final ChatRepository _repository;

  late final Command1<void, String> send;
  late final Command0<void> regenerate;
  late final Command0<List<ChatThread>> loadThreads;
  late final Command1<void, ChatThread> open;

  ChatMode _mode = ChatMode.explain;
  String? _threadId;
  List<ChatMessage> _messages = const [];
  List<ChatThread> _threads = const [];
  String? _unsent;
  ChatFailure? _failure;
  int _localId = 0;

  ChatMode get mode => _mode;
  String? get threadId => _threadId;
  List<ChatMessage> get messages => _messages;
  List<ChatThread> get threads => _threads;
  bool get isEmpty => _messages.isEmpty && _unsent == null;
  bool get isThinking => send.isRunning || regenerate.isRunning;
  String? get unsent => _unsent;
  ChatFailure? get failure => _failure;

  void setMode(ChatMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void newChat() {
    _threadId = null;
    _messages = const [];
    _unsent = null;
    _failure = null;
    notifyListeners();
  }

  Future<void> quizMe() async {
    setMode(ChatMode.quiz);
    await send.execute('Quiz me on this.');
  }

  Future<void> resend() async {
    final text = _unsent;
    if (text == null) return;
    await send.execute(text);
  }

  Future<void> rate(ChatMessage message, int rating) async {
    final next = message.rating == rating ? 0 : rating;
    _replace(message.id, message.copyWith(rating: next));
    final result = await _repository.rate(message.id, next);
    if (result is Error) _replace(message.id, message);
  }

  Future<Result<void>> report(ChatMessage message, ReportReason reason) =>
      _repository.report(message.id, reason);

  Future<Result<void>> _send(String text) async {
    final question = text.trim();
    if (question.isEmpty) return Result.ok(null);
    _failure = null;
    _unsent = null;
    final local = ChatMessage(
      id: --_localId,
      role: ChatRole.student,
      body: question,
    );
    _messages = [..._messages, local];
    notifyListeners();
    final result = await _repository.send(
      threadId: _threadId,
      mode: _mode,
      text: question,
    );
    switch (result) {
      case Ok(:final value):
        _threadId = value.thread.id;
        _messages = [
          for (final m in _messages)
            if (m.id != local.id) m,
          value.question,
          value.reply,
        ];
      case Error(:final error):
        _messages = [
          for (final m in _messages)
            if (m.id != local.id) m,
        ];
        _unsent = question;
        _failure = _failureOf(error);
    }
    return result;
  }

  Future<Result<void>> _regenerate() async {
    final id = _threadId;
    if (id == null || _messages.isEmpty || !_messages.last.isPebby) {
      return Result.ok(null);
    }
    final previous = _messages.last;
    _messages = _messages.sublist(0, _messages.length - 1);
    _failure = null;
    notifyListeners();
    final result = await _repository.regenerate(id, _mode);
    switch (result) {
      case Ok(:final value):
        _messages = [..._messages, value];
      case Error(:final error):
        _messages = [..._messages, previous];
        _failure = _failureOf(error);
    }
    return result;
  }

  Future<Result<List<ChatThread>>> _loadThreads() async {
    final result = await _repository.threads();
    if (result case Ok(:final value)) _threads = value;
    return result;
  }

  Future<Result<void>> _open(ChatThread thread) async {
    final result = await _repository.messages(thread.id);
    if (result case Ok(:final value)) {
      _threadId = thread.id;
      _mode = thread.mode;
      _messages = value;
      _unsent = null;
      _failure = null;
    }
    return result;
  }

  void _replace(int id, ChatMessage message) {
    _messages = [for (final m in _messages) m.id == id ? message : m];
    notifyListeners();
  }

  static ChatFailure _failureOf(Exception error) =>
      error is ChatException ? error.failure : ChatFailure.unknown;

  @override
  void dispose() {
    for (final command in [send, regenerate, loadThreads, open]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
