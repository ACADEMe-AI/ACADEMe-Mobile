import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/number_wheel.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/me/widgets/appearance_screen.dart';
import 'package:academe/ui/me/widgets/delete_account_screen.dart';
import 'package:academe/ui/me/widgets/language_sheet.dart';
import 'package:academe/ui/me/widgets/me_screen.dart';
import 'package:academe/ui/me/widgets/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../helpers/app_fonts.dart';

void main() {
  late FakeAuthRepository auth;
  late MeViewModel viewModel;
  late AppearanceRepository appearance;

  Future<void> pump(WidgetTester tester, Widget Function() page) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    auth = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
    appearance = AppearanceRepository(store: FakeAppearanceStore());
    viewModel = MeViewModel(
      authRepository: auth,
      profileRepository: FakeProfileRepository(
        const Profile(
          language: AppLanguage.english,
          classLevel: 10,
          board: Board.cbse,
          xp: 100,
        ),
      ),
      preferencesStore: FakePreferencesStore(),
      appearance: appearance,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      PebbyStandIn(
        child: ListenableBuilder(
          listenable: appearance,
          builder: (context, _) => MaterialApp(
            theme: AppTheme.dark(
              palette: appearance.isDark ? AppPalette.dark : AppPalette.light,
            ),
            home: Scaffold(body: page()),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('Me lists the settings as plain rows, log out last', (
    tester,
  ) async {
    var loggedOut = 0;
    await pump(
      tester,
      () => MeScreen(
        viewModel: viewModel,
        onClassAndBoard: () {},
        onLanguage: () {},
        onAppearance: () {},
        onNotifications: () {},
        onAccount: () {},
        onHelp: () {},
        onPrivacy: () {},
        onLogOut: () => loggedOut++,
      ),
    );

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('Class 10 · CBSE'), findsWidgets);
    expect(find.text('App language'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Reminders and daily goal'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Lv 2'), findsOneWidget);
    expect(find.text('150 XP to Lv 3'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Log out'), 200);
    await tester.tap(find.text('Log out'));
    await tester.pump(AppKeycap.pressDuration);
    expect(loggedOut, 1);
    expectOnlyAppFonts(tester);
  });

  testWidgets('the language drawer returns the picked language on OK', (
    tester,
  ) async {
    AppLanguage? picked;
    await pump(
      tester,
      () => Builder(
        builder: (context) => TextButton(
          onPressed: () async => picked = await LanguageSheet.show(
            context,
            current: AppLanguage.english,
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('More languages coming soon'), findsOneWidget);
    await tester.tap(find.text('తెలుగు'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK · Switch to తెలుగు'));
    await tester.pumpAndSettle();
    expect(picked, AppLanguage.telugu);
  });

  testWidgets('time and goal are fields that open a wheel sheet', (
    tester,
  ) async {
    await pump(tester, () => NotificationsScreen(viewModel: viewModel));
    Finder wheel(String label) => find.byWidgetPredicate(
      (widget) => widget is NumberWheel && widget.semanticsLabel == label,
    );
    expect(find.text('Remind me at'), findsNothing);
    expect(wheel('Hour'), findsNothing);

    await tester.tap(find.text('Remind me to study'));
    await tester.pumpAndSettle();
    expect(viewModel.preferences.remindsToStudy, isTrue);
    expect(find.text('9:00 pm'), findsOneWidget);

    await tester.tap(find.text('Remind me at'));
    await tester.pumpAndSettle();
    expect(wheel('Hour'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(wheel('Hour'), findsNothing);

    await tester.tap(find.text('Study each day'));
    await tester.pumpAndSettle();
    expect(wheel('Daily goal in minutes'), findsOneWidget);
    await tester.drag(wheel('Daily goal in minutes'), const Offset(0, -48));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(viewModel.preferences.dailyGoalMinutes, 30);
    expect(find.text('30 min'), findsOneWidget);
  });

  testWidgets('delete needs the word DELETE', (tester) async {
    var deleted = 0;
    await pump(
      tester,
      () =>
          DeleteAccountScreen(viewModel: viewModel, onDeleted: () => deleted++),
    );
    await tester.tap(find.text('Delete my account'));
    await tester.pump(AppKeycap.pressDuration);
    expect(auth.deletions, 0);

    await tester.tap(find.text('I don’t use it enough'));
    await tester.pump();
    await tester.scrollUntilVisible(find.byType(TextField), 200);
    await tester.enterText(find.byType(TextField), 'delete');
    await tester.pump();
    await tester.tap(find.text('Delete my account'));
    await tester.pumpAndSettle();
    expect(auth.deletions, 1);
    expect(auth.deletionReasons.single, 'I don’t use it enough');
    expect(deleted, 1);
  });

  testWidgets('appearance is its own screen; picking Dark turns the '
      'palette dark', (tester) async {
    final picks = <bool>[];
    await pump(
      tester,
      () => AppearanceScreen(viewModel: viewModel, onPick: picks.add),
    );
    expect(find.text('Appearance'), findsOneWidget);
    await tester.tap(find.text('Light'));
    expect(picks, isEmpty);
    await tester.tap(find.text('Dark'));
    expect(picks, [true]);

    await viewModel.setDark(true);
    await tester.pumpAndSettle();
    final context = tester.element(find.text('Dark'));
    expect(context.palette.surface, AppColors.splash);
  });
}
