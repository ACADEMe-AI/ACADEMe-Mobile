import 'package:academe/data/repositories/profile_repository.dart';
import 'package:academe/domain/models/auth_failure.dart';
import 'package:academe/domain/models/board.dart';
import 'package:academe/domain/models/profile.dart';
import 'package:academe/domain/models/subject.dart';
import 'package:academe/utils/result.dart';

class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository([this._profile = const Profile()]);

  Profile _profile;
  AuthException? nextFailure;
  final updates = <ProfileUpdate>[];

  static const subjectList = [
    Subject(id: 'maths', name: 'Maths'),
    Subject(id: 'science', name: 'Science'),
    Subject(id: 'english', name: 'English'),
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
  Future<Result<Profile>> load() async => _answer(_profile);

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
      setupDone: _profile.setupDone,
      xp: _profile.xp,
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
            setupDone: true,
            xp: next.xp + Profile.setupReward,
          )
        : next;
    notifyListeners();
    return Result.ok(_profile);
  }

  @override
  Future<Result<List<Subject>>> subjects({
    required int classLevel,
    required Board board,
  }) async => Result.ok(subjectList);
}
