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

  test('a new account has four tasks and no subjects', () async {
    await start();
    expect(viewModel.doneCount, 0);
    expect(viewModel.showsChecklist, isTrue);
    expect(viewModel.subjects, isEmpty);
    expect(viewModel.nextTask(), SetupTask.language);
  });

  test('nextTask goes forward and wraps to skipped tasks', () async {
    await start(const Profile(birthYear: 2011, board: Board.cbse));
    expect(viewModel.nextTask(), SetupTask.language);
    expect(viewModel.nextTask(after: SetupTask.language), SetupTask.classLevel);
    expect(viewModel.nextTask(after: SetupTask.classLevel), SetupTask.language);
  });

  test('subjects arrive once class and board are set', () async {
    await start();
    await viewModel.save.execute(const ProfileUpdate(classLevel: 9));
    expect(viewModel.subjects, isEmpty);
    await viewModel.save.execute(const ProfileUpdate(board: Board.icse));
    expect(viewModel.subjects, FakeProfileRepository.subjectList);
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
    expect(viewModel.subjects, isNotEmpty);
  });
}
