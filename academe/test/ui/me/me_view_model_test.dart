import 'package:academe/data/repositories/appearance_repository.dart';
import 'package:academe/domain/models/app_language.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/ui/me/view_models/me_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_appearance_store.dart';
import '../../../testing/fakes/fake_auth_repository.dart';
import '../../../testing/fakes/fake_billing_repository.dart';
import '../../../testing/fakes/fake_preferences_store.dart';
import '../../../testing/fakes/fake_profile_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late FakePreferencesStore store;
  late FakeAppearanceStore appearanceStore;
  late MeViewModel viewModel;

  setUp(() async {
    auth = FakeAuthRepository(signedIn: FakeAuthRepository.ada);
    profiles = FakeProfileRepository(
      const Profile(
        language: AppLanguage.english,
        classLevel: 10,
        board: Board.cbse,
      ),
    );
    store = FakePreferencesStore();
    appearanceStore = FakeAppearanceStore();
    viewModel = MeViewModel(
      authRepository: auth,
      profileRepository: profiles,
      preferencesStore: store,
      appearance: AppearanceRepository(store: appearanceStore),
    );
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() => viewModel.dispose());

  test('switching to dark mode updates the label and is saved', () async {
    expect(viewModel.appearanceLabel, 'Light');
    await viewModel.setDark(true);
    expect(viewModel.isDark, isTrue);
    expect(viewModel.appearanceLabel, 'Dark');
    expect(appearanceStore.isDark, isTrue);
  });

  test('labels read from the profile and preferences', () {
    expect(viewModel.syllabusLabel, 'Class 10 · CBSE');
    expect(viewModel.language, AppLanguage.english);
    expect(viewModel.notificationsLabel, 'Off');
  });

  test('class, board and language are saved to the profile', () async {
    await viewModel.saveSyllabus.execute((classLevel: 11, board: Board.icse));
    expect(viewModel.syllabusLabel, 'Class 11 · ICSE');

    await viewModel.saveLanguage.execute(AppLanguage.telugu);
    expect(viewModel.language, AppLanguage.telugu);
    expect(profiles.updates.last.language, AppLanguage.telugu);
  });

  test('reminder and goal changes are stored', () async {
    await viewModel.updatePreferences(
      viewModel.preferences.copyWith(
        remindsToStudy: true,
        reminderHour: 19,
        reminderMinute: 30,
        dailyGoalMinutes: 45,
      ),
    );
    expect(viewModel.notificationsLabel, '7:30 pm');
    expect(store.stored.dailyGoalMinutes, 45);
  });

  test('name, log out and delete go through the account', () async {
    await viewModel.saveName.execute((first: 'Riya', last: 'Sharma'));
    expect(auth.nameUpdates.single, ('Riya', 'Sharma'));
    expect(viewModel.account?.firstName, 'Riya');

    await viewModel.deleteAccount.execute('Too many notifications');
    expect(auth.deletions, 1);
    expect(auth.deletionReasons.single, 'Too many notifications');
    expect(viewModel.deleteAccount.isCompleted, isTrue);
  });

  test('password and Google go through the account', () async {
    expect(viewModel.hasPassword, isTrue);
    expect(viewModel.googleEmail, isNull);
    expect(viewModel.isPro, isFalse);

    await viewModel.linkGoogle.execute();
    expect(viewModel.googleEmail, 'ada@gmail.com');
    await viewModel.unlinkGoogle.execute();
    expect(viewModel.googleEmail, isNull);

    await viewModel.changePassword.execute((
      current: 'sunflower',
      next: 'marigold1',
    ));
    expect(auth.passwordChanges.single, ('sunflower', 'marigold1'));
    expect(viewModel.changePassword.isCompleted, isTrue);
  });

  test('Pro comes from billing', () {
    final pro = MeViewModel(
      authRepository: auth,
      profileRepository: profiles,
      preferencesStore: store,
      appearance: AppearanceRepository(store: appearanceStore),
      billing: FakeBillingRepository(plan: FakeBillingRepository.proPlan),
    );
    addTearDown(pro.dispose);
    expect(pro.isPro, isTrue);
  });
}
