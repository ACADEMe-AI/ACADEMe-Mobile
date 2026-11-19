import 'package:academe/data/repositories/profile_repository.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/domain/models/study_stream.dart';
import 'package:academe/domain/models/subject.dart';
import 'package:academe/utils/result.dart';

class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository([this._profile = const Profile()]);

  Profile _profile;
  AuthException? nextFailure;
  Profile? nextLoad;
  final updates = <ProfileUpdate>[];

  static const english = Subject(id: 'english', name: 'English');
  static const maths = Subject(id: 'maths', name: 'Maths');
  static const physics = Subject(id: 'physics', name: 'Physics');
  static const chemistry = Subject(id: 'chemistry', name: 'Chemistry');
  static const biology = Subject(id: 'biology', name: 'Biology');
  static const computerScience = Subject(
    id: 'computer-science',
    name: 'Computer Science',
  );

  static const subjectList = [
    maths,
    Subject(id: 'science', name: 'Science'),
    english,
    Subject(id: 'sanskrit', name: 'Sanskrit'),
  ];

  static const seniorList = [
    physics,
    chemistry,
    maths,
    biology,
    english,
    computerScience,
  ];

  static const streamList = [
    StudyStream(
      id: 'pcm',
      name: 'Science · PCM',
      main: [english, physics, chemistry, maths],
      optional: [computerScience, biology],
    ),
    StudyStream(
      id: 'pcb',
      name: 'Science · PCB',
      main: [english, physics, chemistry, biology],
      optional: [maths, computerScience],
    ),
  ];

  @override
  Profile? get profile => _profile;

  Result<T> _answer<T>(T value) {
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Result.error(failure);
    }
    return Result.ok(value);
  }

  @override
  Future<Result<Profile>> load() async {
    final result = _answer(nextLoad ?? _profile);
    if (result case Ok(:final value)) {
      _profile = value;
      nextLoad = null;
      notifyListeners();
    }
    return result;
  }

  @override
  Future<Result<Profile>> update(ProfileUpdate update) async {
    final result = _answer(update);
    if (result is Error) return Result.error((result as Error).error);
    updates.add(update);
    final next = Profile(
      language: update.language ?? _profile.language,
      birthYear: update.birthYear ?? _profile.birthYear,
      classLevel: update.classLevel ?? _profile.classLevel,
      board: update.board ?? _profile.board,
      subjects: update.subjects ?? _profile.subjects,
      setupDone: _profile.setupDone,
      streak: _profile.streak,
      xp:
          _profile.xp +
          (update.subjects != null && !_profile.hasPicks
              ? Profile.subjectsReward
              : 0),
    );
    final complete =
        next.language != null &&
        next.birthYear != null &&
        next.classLevel != null &&
        next.board != null;
    _profile = complete && !next.setupDone
        ? Profile(
            language: next.language,
            birthYear: next.birthYear,
            classLevel: next.classLevel,
            board: next.board,
            subjects: next.subjects,
            setupDone: true,
            xp: next.xp + Profile.setupReward,
            streak: next.streak,
          )
        : next;
    notifyListeners();
    return Result.ok(_profile);
  }

  @override
  Future<Result<List<Subject>>> subjects({
    required int classLevel,
    required Board board,
  }) async => _answer(classLevel >= 11 ? seniorList : subjectList);

  @override
  Future<Result<List<StudyStream>>> streams({
    required int classLevel,
    required Board board,
  }) async => _answer(streamList);
}
