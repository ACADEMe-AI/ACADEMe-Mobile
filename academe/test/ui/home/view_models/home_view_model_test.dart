import 'package:academe/data/services/hint_store.dart';
import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/home/view_models/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/fake_auth_repository.dart';
import '../../../../testing/fakes/fake_hint_store.dart';
import '../../../../testing/fakes/fake_profile_repository.dart';

void main() {
  late FakeProfileRepository profiles;
  late FakeHintStore hints;
  late HomeViewModel viewModel;

  Future<void> start([Profile profile = const Profile()]) async {
    profiles = FakeProfileRepository(profile);
    hints = FakeHintStore();
    viewModel = HomeViewModel(
      authRepository: FakeAuthRepository(),
      profileRepository: profiles,
      hintStore: hints,
    );
    addTearDown(viewModel.dispose);
    await pumpEventQueue();
  }

  test('a new account has five tasks, subjects last', () async {
    await start();
    expect(SetupTask.values.length, 5);
    expect(viewModel.doneCount, 0);
    expect(viewModel.showsChecklist, isTrue);
    expect(viewModel.nextTask(), SetupTask.language);
    expect(viewModel.showsPickSubjects, isFalse);
  });

  test('nextTask goes forward and wraps to skipped tasks', () async {
    await start(const Profile(birthYear: 2011, board: Board.cbse));
    expect(viewModel.nextTask(), SetupTask.language);
    expect(viewModel.nextTask(after: SetupTask.language), SetupTask.classLevel);
    expect(viewModel.nextTask(after: SetupTask.classLevel), SetupTask.language);
  });

  test('the subjects task opens only once class and board are set', () async {
    await start(const Profile(language: AppLanguage.english, birthYear: 2011));
    expect(viewModel.nextTask(after: SetupTask.classLevel), SetupTask.board);
    expect(viewModel.startAt(SetupTask.subjects), SetupTask.classLevel);
    await viewModel.save.execute(const ProfileUpdate(classLevel: 9));
    await viewModel.save.execute(const ProfileUpdate(board: Board.icse));
    expect(viewModel.nextTask(after: SetupTask.board), SetupTask.subjects);
    expect(viewModel.startAt(SetupTask.subjects), SetupTask.subjects);
  });

  test('the reward waits for the subjects step and adds its 25', () async {
    await start(
      const Profile(
        language: AppLanguage.hindi,
        birthYear: 2011,
        classLevel: 9,
      ),
    );
    await viewModel.save.execute(const ProfileUpdate(board: Board.cbse));
    expect(viewModel.nextTask(after: SetupTask.board), SetupTask.subjects);
    await viewModel.save.execute(
      const ProfileUpdate(subjects: ['maths', 'english']),
    );

    expect(viewModel.doneCount, 5);
    expect(viewModel.nextTask(after: SetupTask.subjects), isNull);
    expect(viewModel.pendingXp, 125);
    expect(viewModel.displayedXp, 0);
    viewModel.rewardLanded();
    expect(viewModel.displayedXp, 125);
    expect(viewModel.showsPickSubjects, isFalse);
  });

  test('a finished account without picks sees the card once', () async {
    await start(
      const Profile(
        language: AppLanguage.tamil,
        birthYear: 2010,
        classLevel: 10,
        board: Board.cbse,
        setupDone: true,
        xp: 100,
      ),
    );
    expect(viewModel.showsPickSubjects, isTrue);
    viewModel.dismissPickSubjects();
    await pumpEventQueue();
    expect(viewModel.showsPickSubjects, isFalse);
    expect(hints.seen, contains(Hint.pickSubjects));
  });

  test('the last task holds the reward until it lands', () async {
    await start(
      const Profile(
        language: AppLanguage.hindi,
        birthYear: 2011,
        classLevel: 9,
      ),
    );
    await viewModel.save.execute(const ProfileUpdate(board: Board.cbse));

    expect(viewModel.profile.setupDone, isTrue);
    expect(viewModel.isRewardPending, isTrue);
    expect(
      viewModel.showsChecklist,
      isTrue,
      reason: 'card stays for the flight',
    );
    expect(viewModel.displayedXp, 0);

    viewModel.rewardLanded();

    expect(viewModel.displayedXp, Profile.setupReward);
    expect(viewModel.showsChecklist, isFalse);
    expect(viewModel.showsAskHint, isTrue);

    viewModel.dismissAskHint();
    await pumpEventQueue();
    expect(viewModel.showsAskHint, isFalse);
    expect(hints.seen, contains(Hint.askPebby));
  });

  test('a finished account shows no checklist and its XP', () async {
    await start(
      const Profile(
        language: AppLanguage.tamil,
        birthYear: 2010,
        classLevel: 10,
        board: Board.cbse,
        setupDone: true,
        xp: 100,
      ),
    );
    expect(viewModel.showsChecklist, isFalse);
    expect(viewModel.displayedXp, 100);
  });
}
