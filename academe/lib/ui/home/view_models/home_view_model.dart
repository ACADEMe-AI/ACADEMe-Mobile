import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/services/hint_store.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/board.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/subject.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum SetupTask { language, age, classLevel, board }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required HintStore hintStore,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _hintStore = hintStore {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    _profileRepository.addListener(_onProfileChanged);
    load.execute();
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final HintStore _hintStore;

  late final Command0<Profile> load;
  late final Command1<Profile, ProfileUpdate> save;

  static const xpPerTask = Profile.setupReward ~/ 4;

  List<Subject> _subjects = const [];
  bool _isRewardPending = false;
  bool _hasSeenAskHint = true;
  bool _showsAskHint = false;

  Account? get account => _authRepository.account;
  Profile get profile => _profileRepository.profile ?? const Profile();
  List<Subject> get subjects => _subjects;

  String? get syllabusLabel {
    final classLevel = profile.classLevel;
    if (classLevel == null) return null;
    final board = profile.board;
    return board == null
        ? 'Class $classLevel'
        : 'Class $classLevel · ${board.code}';
  }

  bool get isRewardPending => _isRewardPending;
  bool get showsChecklist => !profile.setupDone || _isRewardPending;
  bool get showsAskHint => _showsAskHint;

  int get displayedXp =>
      profile.xp - (_isRewardPending ? Profile.setupReward : 0);

  bool isDone(SetupTask task) => switch (task) {
    SetupTask.language => profile.language != null,
    SetupTask.age => profile.birthYear != null,
    SetupTask.classLevel => profile.classLevel != null,
    SetupTask.board => profile.board != null,
  };

  int get doneCount => SetupTask.values.where(isDone).length;

  SetupTask? nextTask({SetupTask? after}) {
    const tasks = SetupTask.values;
    final start = after == null ? 0 : after.index + 1;
    for (var offset = 0; offset < tasks.length; offset++) {
      final task = tasks[(start + offset) % tasks.length];
      if (task != after && !isDone(task)) return task;
    }
    return null;
  }

  void rewardLanded() {
    _isRewardPending = false;
    _showsAskHint = !_hasSeenAskHint;
    notifyListeners();
  }

  void dismissAskHint() {
    _showsAskHint = false;
    _hasSeenAskHint = true;
    notifyListeners();
    _hintStore.markSeen(Hint.askPebby);
  }

  Future<Result<Profile>> _load() async {
    _hasSeenAskHint = await _hintStore.hasSeen(Hint.askPebby);
    final result = await _profileRepository.load();
    if (result is Ok) await _refreshSubjects();
    return result;
  }

  Future<Result<Profile>> _save(ProfileUpdate update) async {
    final wasDone = profile.setupDone;
    final result = await _profileRepository.update(update);
    if (result is Ok) {
      if (!wasDone && profile.setupDone) _isRewardPending = true;
      await _refreshSubjects();
    }
    return result;
  }

  (int?, Board?) _syllabus = (null, null);

  Future<void> _onProfileChanged() async {
    final next = (profile.classLevel, profile.board);
    if (next == _syllabus) return;
    await _refreshSubjects();
    notifyListeners();
  }

  Future<void> _refreshSubjects() async {
    final current = profile;
    final classLevel = current.classLevel;
    final board = current.board;
    _syllabus = (classLevel, board);
    if (classLevel == null || board == null) {
      _subjects = const [];
      return;
    }
    final result = await _profileRepository.subjects(
      classLevel: classLevel,
      board: board,
    );
    if (result case Ok(:final value)) _subjects = value;
  }

  @override
  void dispose() {
    load
      ..removeListener(notifyListeners)
      ..dispose();
    save
      ..removeListener(notifyListeners)
      ..dispose();
    _profileRepository.removeListener(_onProfileChanged);
    super.dispose();
  }
}
