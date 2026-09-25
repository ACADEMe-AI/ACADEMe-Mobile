import 'package:academe/domain/models/chat.dart';
import 'package:academe/ui/askme/view_models/askme_view_model.dart';
import 'package:academe/ui/askme/widgets/askme_screen.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/core/ui/pebby_peek.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_chat_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeChatRepository chats;
  late AskMeViewModel viewModel;
  var wentBack = 0;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    chats = FakeChatRepository();
    viewModel = AskMeViewModel(chatRepository: chats);
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: AskMeScreen(
              viewModel: viewModel,
              name: 'Riya',
              syllabus: 'Class 10 · CBSE',
              onBack: () => wentBack++,
              onHistory: () {},
              onMakeFlashcards: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('empty state: Pebby reads, suggestions ask', (tester) async {
    await pump(tester);

    expect(find.byType(Pebby), findsOneWidget);
    expect(find.text('What are we studying, Riya?'), findsOneWidget);
    expect(find.text('Class 10 · CBSE'), findsOneWidget);
    expect(find.byTooltip('New chat'), findsOneWidget);

    await tester.tap(find.text('Explain reflection of light simply'));
    await tester.pump();
    expect(chats.sent.single.text, 'Explain reflection of light simply');
    expect(find.byType(PebbyPeek), findsWidgets);
    expect(find.text('Make flashcards'), findsOneWidget);
    expect(find.byTooltip('Helpful'), findsOneWidget);
    expect(find.byTooltip('Try again'), findsOneWidget);
    expectOnlyAppFonts(tester);
  });

  testWidgets('modes change the line, the suggestions and the follow-ups', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Quiz me'));
    await tester.pumpAndSettle();
    expect(find.text('Pebby asks, you answer, you earn XP.'), findsOneWidget);
    expect(find.text('Quiz me on Light'), findsOneWidget);
    expect(find.text('Why is the sky blue?'), findsNothing);

    await tester.tap(find.text('Solve'));
    await tester.pump();
    expect(viewModel.mode, ChatMode.solve);
    await viewModel.send.execute('2x = 6');
    await tester.pump();
    expect(find.text('Next step'), findsOneWidget);
    expect(find.text('Full solution'), findsOneWidget);
    expect(find.text('Make flashcards'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    expect(wentBack, 1);
  });

  testWidgets('without a tutor the student sees why', (tester) async {
    await pump(tester);
    chats.nextFailure = ChatFailure.unavailable;
    await viewModel.send.execute('Hello');
    await tester.pump();

    expect(find.text('Hello'), findsOneWidget);
    expect(
      find.text('ASKMe isn’t ready yet. Pebby will be here soon.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsNothing);
  });
}
