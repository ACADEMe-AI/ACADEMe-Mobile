import 'package:academe/domain/models/chat.dart';
import 'package:academe/ui/askme/view_models/askme_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_chat_repository.dart';

void main() {
  late FakeChatRepository chats;
  late AskMeViewModel viewModel;

  setUp(() {
    chats = FakeChatRepository();
    viewModel = AskMeViewModel(chatRepository: chats);
  });

  tearDown(() => viewModel.dispose());

  test(
    'the first question starts a chat and keeps it for follow-ups',
    () async {
      await viewModel.send.execute('  What is light?  ');
      expect(viewModel.threadId, 'thread-1');
      expect(viewModel.messages.map((m) => m.role), [
        ChatRole.student,
        ChatRole.pebby,
      ]);

      viewModel.setMode(ChatMode.solve);
      await viewModel.send.execute('And refraction?');
      expect(chats.sent.last, (
        threadId: 'thread-1',
        mode: ChatMode.solve,
        text: 'And refraction?',
      ));
      expect(viewModel.messages, hasLength(4));
    },
  );

  test('a failed question is kept so it can be sent again', () async {
    chats.nextFailure = ChatFailure.network;
    await viewModel.send.execute('Why is the sky blue?');
    expect(viewModel.messages, isEmpty);
    expect(viewModel.unsent, 'Why is the sky blue?');
    expect(viewModel.failure, ChatFailure.network);

    await viewModel.resend();
    expect(viewModel.unsent, isNull);
    expect(viewModel.failure, isNull);
    expect(viewModel.messages.last.isPebby, isTrue);
  });

  test(
    'retry swaps the last answer; a failed retry keeps the old one',
    () async {
      await viewModel.send.execute('Explain mitosis');
      await viewModel.regenerate.execute();
      expect(viewModel.messages.last.body, 'Another way to see it');

      chats.nextFailure = ChatFailure.unavailable;
      await viewModel.regenerate.execute();
      expect(viewModel.messages.last.body, 'Another way to see it');
      expect(viewModel.failure, ChatFailure.unavailable);
    },
  );

  test('thumbs toggle, and quiz me switches mode', () async {
    await viewModel.send.execute('Explain photosynthesis');
    final reply = viewModel.messages.last;
    await viewModel.rate(reply, 1);
    expect(viewModel.messages.last.rating, 1);
    await viewModel.rate(viewModel.messages.last, 1);
    expect(viewModel.messages.last.rating, 0);
    expect(chats.ratings, [(reply.id, 1), (reply.id, 0)]);

    await viewModel.quizMe();
    expect(viewModel.mode, ChatMode.quiz);
    expect(chats.sent.last.mode, ChatMode.quiz);
  });

  test('opening a chat from history loads it; new chat clears it', () async {
    final thread = ChatThread(
      id: 'old',
      mode: ChatMode.solve,
      title: 'Linear equations',
      updatedAt: DateTime(2026, 9, 20),
    );
    chats.threadMessages['old'] = const [
      ChatMessage(id: 1, role: ChatRole.student, body: 'x + 2 = 5'),
      ChatMessage(id: 2, role: ChatRole.pebby, body: 'Hint: subtract 2'),
    ];
    await viewModel.open.execute(thread);
    expect(viewModel.threadId, 'old');
    expect(viewModel.mode, ChatMode.solve);
    expect(viewModel.messages, hasLength(2));

    viewModel.newChat();
    expect(viewModel.isEmpty, isTrue);
    expect(viewModel.threadId, isNull);
  });
}
