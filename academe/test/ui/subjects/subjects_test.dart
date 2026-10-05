import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:academe/ui/me/widgets/class_board_screen.dart';
import 'package:academe/ui/subjects/view_models/subjects_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';

void main() {
  late FakeProfileRepository profiles;

  Future<SubjectsViewModel> picker(Profile profile) async {
    profiles = FakeProfileRepository(profile);
    final viewModel = SubjectsViewModel(profileRepository: profiles);
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();
    return viewModel;
  }

  test(
    'Class 6–10 starts with the usual subjects and English locked',
    () async {
      final viewModel = await picker(
        const Profile(classLevel: 8, board: Board.cbse),
      );
      expect(viewModel.stage, SubjectsStage.subjects);
      expect(viewModel.main.first.id, 'english');
      expect(viewModel.optional, isEmpty);
      expect(viewModel.picks, ['maths', 'science', 'english']);

      viewModel
        ..toggle('english')
        ..toggle('sanskrit')
        ..toggle('maths');
      expect(viewModel.picks, ['science', 'english', 'sanskrit']);

      await viewModel.save.execute();
      expect(profiles.updates.single.subjects, [
        'science',
        'english',
        'sanskrit',
      ]);
      expect(viewModel.savedSubjects?.length, 3);
    },
  );

  test('Class 11–12 picks a stream, then optional subjects', () async {
    final viewModel = await picker(
      const Profile(classLevel: 11, board: Board.icse),
    );
    expect(viewModel.stage, SubjectsStage.stream);
    expect(viewModel.focusedStream?.id, 'pcm');

    viewModel.chooseStream(FakeProfileRepository.streamList.first);
    expect(viewModel.stage, SubjectsStage.subjects);
    expect(viewModel.picks, ['physics', 'chemistry', 'maths', 'english']);
    viewModel.toggle('computer-science');

    viewModel.chooseStream(FakeProfileRepository.streamList.last);
    expect(viewModel.picks, [
      'physics',
      'chemistry',
      'maths',
      'biology',
      'english',
      'computer-science',
    ]);

    viewModel.showStreams();
    expect(viewModel.stage, SubjectsStage.stream);
  });

  test('saved picks bring back their stream', () async {
    final viewModel = await picker(
      const Profile(
        classLevel: 12,
        board: Board.cbse,
        subjects: ['physics', 'chemistry', 'biology', 'english'],
      ),
    );
    expect(viewModel.savedStream?.id, 'pcb');
    expect(viewModel.stage, SubjectsStage.subjects);
    expect(viewModel.streamIndex, 1);
    viewModel.reset(start: SubjectsStage.stream);
    expect(viewModel.stage, SubjectsStage.stream);
  });

  test('a failed load says so', () async {
    profiles = FakeProfileRepository(
      const Profile(classLevel: 9, board: Board.cbse),
    )..nextFailure = const AuthException(AuthFailure.network);
    final viewModel = SubjectsViewModel(profileRepository: profiles);
    addTearDown(viewModel.dispose);
    await viewModel.load.execute();
    expect(viewModel.load.hasError, isTrue);
    expect(viewModel.isReady, isFalse);
  });

  group('Me → Class and board', () {
    Future<void> pump(WidgetTester tester, Profile profile) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      profiles = FakeProfileRepository(profile);
      final viewModel = MeViewModel(
        authRepository: FakeAuthRepository(signedIn: FakeAuthRepository.ada),
        profileRepository: profiles,
        preferencesStore: FakePreferencesStore(),
        appearance: AppearanceRepository(store: FakeAppearanceStore()),
      );
      addTearDown(viewModel.dispose);
      await tester.pumpWidget(
        PebbyStandIn(
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: ClassBoardScreen(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the Subjects row opens the picker as a sheet', (tester) async {
      await pump(tester, const Profile(classLevel: 10, board: Board.cbse));
      await tester.scrollUntilVisible(find.text('All subjects'), 200);

      expect(find.text('Stream'), findsNothing);
      await tester.tap(find.text('All subjects'));
      await tester.pumpAndSettle();
      expect(find.text('Your subjects'), findsOneWidget);
      expect(find.text('Class 10 · CBSE'), findsOneWidget);
      await tester.tap(find.text('Sanskrit'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(profiles.updates.single.subjects, [
        'maths',
        'science',
        'english',
        'sanskrit',
      ]);
      expect(
        find.text('4 · Maths, Science, English, Sanskrit'),
        findsOneWidget,
      );
    });

    testWidgets('Class 11–12 also has a Stream row with swipe cards', (
      tester,
    ) async {
      await pump(tester, const Profile(classLevel: 12, board: Board.cbse));
      await tester.scrollUntilVisible(find.text('Not set'), 200);

      await tester.tap(find.text('Not set'));
      await tester.pumpAndSettle();
      expect(find.text('Your stream'), findsOneWidget);
      expect(find.text('Choose Science · PCM'), findsOneWidget);
      await tester.tap(find.text('Choose Science · PCM'));
      await tester.pumpAndSettle();

      expect(profiles.updates.single.subjects, [
        'physics',
        'chemistry',
        'maths',
        'english',
      ]);
      expect(find.text('Science · PCM'), findsOneWidget);
      expect(
        find.text('4 · Physics, Chemistry, Maths, English'),
        findsOneWidget,
      );
    });
  });
}
