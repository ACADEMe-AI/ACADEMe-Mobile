import 'app_language.dart';
import 'board.dart';

class Profile {
  const Profile({
    this.language,
    this.birthYear,
    this.classLevel,
    this.board,
    this.setupDone = false,
    this.xp = 0,
  });

  static const setupReward = 100;
  static const firstClass = 6;
  static const lastClass = 12;

  final AppLanguage? language;
  final int? birthYear;
  final int? classLevel;
  final Board? board;
  final bool setupDone;
  final int xp;

  bool get hasSyllabus => classLevel != null && board != null;
}

class ProfileUpdate {
  const ProfileUpdate({
    this.language,
    this.birthYear,
    this.classLevel,
    this.board,
  });

  final AppLanguage? language;
  final int? birthYear;
  final int? classLevel;
  final Board? board;
}
