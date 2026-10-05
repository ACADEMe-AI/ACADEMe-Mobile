import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/hint_store.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/profile.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';
import '../../../utils/safe_notifier.dart';
import '../../subjects/view_models/subjects_view_model.dart';

enum SetupTask { language, age, classLevel, board, subjects }

class HomeViewModel extends ChangeNotifier with SafeNotifier {
  HomeViewModel({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required HintStore hintStore,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _hintStore = hintStore {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    _profileRepository.addListener(notifyListeners);
    load.execute();
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final HintStore _hintStore;

  late final Command0<Profile> load;
  late final Command1<Profile, ProfileUpdate> save;

  static const xpPerTask = Profile.subjectsReward;

  int _pendingXp = 0;
  bool _isRewardPending = false;
  bool _hasSeenAskHint = true;
  bool _showsAskHint = false;
  bool _hasSeenPickHint = true;

  Account? get account => _authRepository.account;
  Profile get profile => _profileRepository.profile ?? const Profile();
  String? get syllabusLabel => profile.syllabusLabel;

  bool get isRewardPending => _isRewardPending;
  int get pendingXp => _pendingXp;
  bool get showsChecklist => !profile.setupDone || _isRewardPending;
  bool get showsAskHint => _showsAskHint;
  bool get showsPickSubjects =>
      !showsChecklist &&
      profile.hasSyllabus &&
      !profile.hasPicks &&
      !_hasSeenPickHint;

  int get displayedXp => profile.xp - _pendingXp;

  bool isDone(SetupTask task) => switch (task) {
    SetupTask.language => profile.language != null,
    SetupTask.age => profile.birthYear != null,
    SetupTask.classLevel => profile.classLevel != null,
    SetupTask.board => profile.board != null,
    SetupTask.subjects => profile.hasPicks,
  };

  bool _isOpen(SetupTask task) =>
      task != SetupTask.subjects || profile.hasSyllabus;

  int get doneCount => SetupTask.values.where(isDone).length;

  SetupTask? nextTask({SetupTask? after}) {
    const tasks = SetupTask.values;
    final start = after == null ? 0 : after.index + 1;
    for (var offset = 0; offset < tasks.length; offset++) {
      final task = tasks[(start + offset) % tasks.length];
      if (task != after && !isDone(task) && _isOpen(task)) return task;
    }
    return null;
  }

  SetupTask startAt(SetupTask task) =>
      _isOpen(task) ? task : nextTask() ?? SetupTask.classLevel;

  SubjectsViewModel subjectsPicker() =>
      SubjectsViewModel(profileRepository: _profileRepository);

  void rewardLanded() {
    _isRewardPending = false;
    _pendingXp = 0;
    _showsAskHint = !_hasSeenAskHint;
    notifyListeners();
  }

  void dismissAskHint() {
    _showsAskHint = false;
    _hasSeenAskHint = true;
    notifyListeners();
    _hintStore.markSeen(Hint.askPebby);
  }

  void dismissPickSubjects() {
    _hasSeenPickHint = true;
    notifyListeners();
    _hintStore.markSeen(Hint.pickSubjects);
  }

  Future<Result<Profile>> _load() async {
    _hasSeenAskHint = await _hintStore.hasSeen(Hint.askPebby);
    _hasSeenPickHint = await _hintStore.hasSeen(Hint.pickSubjects);
    return _profileRepository.load();
  }

  Future<Result<Profile>> _save(ProfileUpdate update) async {
    final wasDone = profile.setupDone;
    final before = profile.xp;
    final result = await _profileRepository.update(update);
    if (result is Ok) {
      if (!wasDone && profile.setupDone) _isRewardPending = true;
      if (_isRewardPending) _pendingXp += profile.xp - before;
    }
    return result;
  }

  @override
  void dispose() {
    load
      ..removeListener(notifyListeners)
      ..dispose();
    save
      ..removeListener(notifyListeners)
      ..dispose();
    _profileRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
