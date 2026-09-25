import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/home/view_models/home_view_model.dart';
import 'package:academe/ui/home/widgets/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_hint_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeProfileRepository profiles;

  Future<HomeViewModel> pumpHome(
    WidgetTester tester, {
    Profile profile = const Profile(),
    bool opensSetup = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    profiles = FakeProfileRepository(profile);
    final viewModel = HomeViewModel(
      authRepository: FakeAuthRepository(),
      profileRepository: profiles,
      hintStore: FakeHintStore(),
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: HomeScreen(viewModel: viewModel, opensSetup: opensSetup),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return viewModel;
  }

  testWidgets('a new account sees the checklist and no subjects yet', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Set up your dashboard'), findsOneWidget);
    expect(find.text('0 / 100 XP'), findsOneWidget);
    expect(find.text('Setting up…'), findsNothing);
    expect(
      find.text('Set your class and board to see your subjects'),
      findsOneWidget,
    );
    expectOnlyAppFonts(tester);
  });

  testWidgets('the ask field and quick actions say what is coming', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Ask anything…'), findsOneWidget);
    await tester.tap(find.text('Solve homework'));
    await tester.pump();
    expect(find.text('Homework help is coming soon.'), findsOneWidget);

    await tester.tap(find.text('Check my answer'));
    await tester.pump();
    expect(find.text('Answer checking is coming soon.'), findsOneWidget);

    await tester.tap(find.text('Flashcards'));
    await tester.pump();
    expect(find.text('Flashcards are coming soon.'), findsOneWidget);
  });

  testWidgets('after sign-up the sheet rises, and Later closes it', (
    tester,
  ) async {
    await pumpHome(tester, opensSetup: true);
    await tester.pump(HomeScreen.setupDelay);
    await tester.pumpAndSettle();

    expect(find.text('Which language do you learn in?'), findsOneWidget);
    expect(find.text('SET UP · 1/4'), findsOneWidget);
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final setUp = tester.getRect(find.text('SET UP · 1/4'));
    final later = tester.getRect(find.text('Later'));
    expect(width - later.right, closeTo(setUp.left, 1));
    expect(later.center.dy, closeTo(setUp.center.dy, 1));

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Which language do you learn in?'), findsNothing);
    expect(find.text('Set up your dashboard'), findsOneWidget);
  });

  testWidgets('answering a task ticks it and fills the meter', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose English'));
    await tester.pumpAndSettle();

    expect(find.text('When were you born?'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(profiles.updates.single.language, AppLanguage.english);
    expect(find.text('25 / 100 XP'), findsOneWidget);
    expect(find.text('✓ 25 XP'), findsOneWidget);
  });

  testWidgets('the last task flies +100 into the XP chip and the card goes', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: const Profile(
        language: AppLanguage.hindi,
        birthYear: 2011,
        classLevel: 9,
      ),
    );
    expect(find.text('0 XP'), findsOneWidget);

    await tester.tap(find.text('Your board'));
    await tester.pumpAndSettle();
    expect(find.text('Finish setup'), findsOneWidget);
    await tester.tap(find.text('Finish setup'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(HomeScreen.rewardDelay);
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('+100'), findsOneWidget);
    expect(find.text('0 XP'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('+100'), findsNothing);
    expect(find.text('100 XP'), findsOneWidget);
    expect(find.text('Set up your dashboard'), findsNothing);
    expect(find.text('Class 9 · CBSE'), findsWidgets);
    expect(find.text('Maths'), findsOneWidget);
    expect(find.text('Ask Pebby anything'), findsOneWidget);
  });
}
