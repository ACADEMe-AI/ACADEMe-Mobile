import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/domain/models/streak.dart';
import 'package:academe/ui/home/widgets/home_greeting.dart';
import 'package:academe/ui/study/widgets/chapter_screen.dart';
import 'package:academe/ui/study/widgets/deck_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';
import '../../helpers/shell_app.dart';

void main() {
  const profile = Profile(classLevel: 10, board: Board.cbse, setupDone: true);
  late FakeProfileRepository profiles;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    profiles = FakeProfileRepository(profile);
    final studies = FakeStudyRepository()
      ..subjectList = const [SubjectProgress(id: 'science', name: 'Science')]
      ..deckList = [
        FakeStudyRepository.summaryOf(
          FakeStudyRepository.reflection,
          isDone: true,
        ),
        FakeStudyRepository.summaryOf(FakeStudyRepository.mirrors),
      ];
    await pumpShellApp(tester, studies: studies, profiles: profiles);
  }

  Future<void> finishMirrors(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('R/2'));
    await tester.pump();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
  }

  testWidgets('a lesson opened from Courses goes back to its chapter', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spherical mirrors'));
    await finishMirrors(tester);

    await tester.tap(find.text('Back to chapter'));
    await tester.pumpAndSettle();
    expect(find.byType(DeckScreen), findsNothing);
    expect(find.byType(ChapterScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ChapterScreen), findsNothing);
    expect(find.text('Courses'), findsOneWidget);
  });

  testWidgets('a lesson opened from its chapter pops back to it', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next lesson'));
    await finishMirrors(tester);

    await tester.tap(find.text('Back to chapter'));
    await tester.pumpAndSettle();
    expect(find.byType(ChapterScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ChapterScreen), findsNothing);
  });

  testWidgets('finishing a lesson lights the streak on Home at once', (
    tester,
  ) async {
    await pumpApp(tester);
    String streakOnHome() => tester
        .widget<HomeGreeting>(find.byType(HomeGreeting))
        .streak
        .current
        .toString();
    expect(streakOnHome(), '0');

    await tester.tap(find.text('Study'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spherical mirrors'));
    profiles.nextLoad = const Profile(
      classLevel: 10,
      board: Board.cbse,
      setupDone: true,
      xp: 5,
      streak: Streak(current: 1, longest: 1, isTodayCounted: true),
    );
    await finishMirrors(tester);
    await tester.tap(find.text('Back to chapter'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(streakOnHome(), '1');
    expect(
      find.descendant(of: find.byType(HomeGreeting), matching: find.text('1')),
      findsOneWidget,
    );
  });
}
