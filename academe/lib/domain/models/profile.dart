import 'app_language.dart';
import 'board.dart';

class Profile {
  const Profile({
    this.language,
    this.birthYear,
    this.classLevel,
    this.board,
    this.subjects,
    this.setupDone = false,
    this.xp = 0,
  });

  static const setupReward = 100;
  static const subjectsReward = 25;
  static const firstClass = 6;
  static const lastClass = 12;
  static const firstSeniorClass = 11;

  final AppLanguage? language;
  final int? birthYear;
  final int? classLevel;
  final Board? board;
  final List<String>? subjects;
  final bool setupDone;
  final int xp;

  bool get hasSyllabus => classLevel != null && board != null;
  bool get hasPicks => subjects != null;
  bool get isSenior => (classLevel ?? 0) >= firstSeniorClass;

  String? get syllabusLabel => hasSyllabus
      ? 'Class $classLevel · ${board!.code}'
      : classLevel == null
      ? null
      : 'Class $classLevel';

  bool studies(String subject) => subjects?.contains(subject) ?? true;
}

class ProfileUpdate {
  const ProfileUpdate({
    this.language,
    this.birthYear,
    this.classLevel,
    this.board,
    this.subjects,
  });

  final AppLanguage? language;
  final int? birthYear;
  final int? classLevel;
  final Board? board;
  final List<String>? subjects;
}
