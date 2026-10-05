import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/deck.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/home/view_models/home_view_model.dart';
import 'package:academe/ui/home/widgets/home_screen.dart';
import 'package:academe/ui/study/view_models/study_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_hint_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';
import '../../../testing/fakes/fake_study_repository.dart';

void main() {
  late FakeProfileRepository profiles;
  late FakeStudyRepository studies;
  late List<String> opened;

  Future<HomeViewModel> pumpHome(
    WidgetTester tester, {
    Profile profile = const Profile(),
    bool opensSetup = false,
    List<SubjectProgress> progress = const [],
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
    studies = FakeStudyRepository()..subjectList = progress;
    final study = StudyViewModel(
      studyRepository: studies,
      profileRepository: profiles,
    );
    addTearDown(study.dispose);
    await study.load.execute();
    opened = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: HomeScreen(
            viewModel: viewModel,
            opensSetup: opensSetup,
            study: study,
            onOpenSubject: opened.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return viewModel;
  }

  testWidgets('Class 11 picks a stream on cards, then the extras', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: const Profile(
        language: AppLanguage.english,
        birthYear: 2009,
        classLevel: 11,
        board: Board.cbse,
      ),
    );
    await tester.tap(find.text('Your subjects').first);
    await tester.pumpAndSettle();

    expect(find.text('What do you study in Class 11?'), findsOneWidget);
    expect(find.text('Physics, Chemistry, Maths'), findsOneWidget);
    await tester.tap(find.text('Choose Science · PCM'));
    await tester.pumpAndSettle();

    expect(find.text('Anything else?'), findsOneWidget);
    expect(
      find.text('Science · PCM. Your main subjects are in.'),
      findsOneWidget,
    );
    expect(find.text('MAIN'), findsOneWidget);
    expect(find.text('OPTIONAL'), findsOneWidget);
    await tester.tap(find.text('Computer Science'));
    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();

    expect(profiles.updates.last.subjects, [
      'physics',
      'chemistry',
      'maths',
      'english',
      'computer-science',
    ]);
  });

  testWidgets('Home lists only picked subjects with next lessons', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: const Profile(
        language: AppLanguage.english,
        birthYear: 2011,
        classLevel: 10,
        board: Board.cbse,
        subjects: ['science', 'english'],
        setupDone: true,
      ),
      progress: const [
        SubjectProgress(id: 'maths', name: 'Maths', chapters: 14),
        SubjectProgress(
          id: 'science',
          name: 'Science',
          chapters: 14,
          lessonsAvailable: 2,
          lessonsDone: 1,
        ),
        SubjectProgress(id: 'english', name: 'English', chapters: 9),
      ],
    );
    await tester.scrollUntilVisible(find.text('English'), 200);

    expect(find.text('Maths'), findsNothing);
    expect(find.text('Next: Ch 9 · Reflection'), findsOneWidget);
    expect(find.text('Lessons coming soon'), findsOneWidget);
    expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
    expect(find.text('Pick your subjects'), findsNothing);

    await tester.tap(find.text('Science'));
    expect(opened, ['science']);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Your subjects'), findsWidgets);
    await tester.tap(find.text('Maths').last);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(profiles.updates.last.subjects, ['maths', 'science', 'english']);
  });

  testWidgets('no picks yet: every subject and a one-time card', (
    tester,
  ) async {
    await pumpHome(
      tester,
      profile: const Profile(
        language: AppLanguage.english,
        birthYear: 2011,
        classLevel: 10,
        board: Board.cbse,
        setupDone: true,
        xp: 100,
      ),
      progress: const [
        SubjectProgress(id: 'maths', name: 'Maths'),
        SubjectProgress(id: 'science', name: 'Science'),
      ],
    );
    expect(find.text('Pick your subjects'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Science'), 200);
    expect(find.text('Maths'), findsOneWidget);

    await tester.tap(find.text('Pick your subjects'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(profiles.updates.last.subjects, ['maths', 'science', 'english']);
    expect(find.text('Pick your subjects'), findsNothing);
    expect(find.text('125 XP'), findsOneWidget);
  });
}
