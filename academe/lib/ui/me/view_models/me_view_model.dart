import 'package:flutter/foundation.dart';

import '../../../data/repositories/appearance_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/billing_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/services/preferences_store.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/app_language.dart';
import '../../../domain/models/board.dart';
import '../../../domain/models/level.dart';
import '../../../domain/models/profile.dart';
import '../../../domain/models/reminder.dart';
import '../../../domain/models/study_preferences.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef Syllabus = ({int classLevel, Board board});
typedef FullName = ({String first, String last});
typedef PasswordChange = ({String? current, String next});

class MeViewModel extends ChangeNotifier {
  MeViewModel({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required PreferencesStore preferencesStore,
    required AppearanceRepository appearance,
    ReminderRepository? reminders,
    BillingRepository? billing,
  }) : _auth = authRepository,
       _billing = billing,
       _reminders = reminders,
       _appearance = appearance,
       _profiles = profileRepository,
       _store = preferencesStore {
    saveSyllabus = Command1(_saveSyllabus)..addListener(notifyListeners);
    saveLanguage = Command1(_saveLanguage)..addListener(notifyListeners);
    saveName = Command1(_saveName)..addListener(notifyListeners);
    logOut = Command0(_auth.logOut)..addListener(notifyListeners);
    changePassword = Command1(
      (PasswordChange change) => _auth.changePassword(
        currentPassword: change.current,
        newPassword: change.next,
      ),
    )..addListener(notifyListeners);
    linkGoogle = Command0(_auth.linkGoogle)..addListener(notifyListeners);
    unlinkGoogle = Command0(_auth.unlinkGoogle)..addListener(notifyListeners);
    deleteAccount = Command1(
      (String? reason) => _auth.deleteAccount(reason: reason),
    )..addListener(notifyListeners);
    _profiles.addListener(notifyListeners);
    _appearance.addListener(notifyListeners);
    _reminders?.addListener(notifyListeners);
    _billing?.addListener(notifyListeners);
    _loadPreferences();
  }

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  final PreferencesStore _store;
  final AppearanceRepository _appearance;
  final ReminderRepository? _reminders;
  final BillingRepository? _billing;

  late final Command1<Profile, Syllabus> saveSyllabus;
  late final Command1<Profile, AppLanguage> saveLanguage;
  late final Command1<Account, FullName> saveName;
  late final Command0<void> logOut;
  late final Command1<Account, PasswordChange> changePassword;
  late final Command0<Account> linkGoogle;
  late final Command0<Account> unlinkGoogle;
  late final Command1<DateTime, String?> deleteAccount;

  StudyPreferences _preferences = const StudyPreferences();

  Account? get account => _auth.account;
  bool get hasPassword => account?.hasPassword ?? true;
  String? get googleEmail => account?.googleEmail;
  bool get isPro => _billing?.isPro ?? false;
  String get manageSubscriptionUrl =>
      _billing?.manageUrl ?? BillingRepository.playSubscriptionsUrl;
  Profile get profile => _profiles.profile ?? const Profile();
  StudyPreferences get preferences => _preferences;
  Level get level => Level.of(profile.xp);

  bool get isDark => _appearance.isDark;

  String get appearanceLabel => isDark ? 'Dark' : 'Light';

  Future<void> setDark(bool isDark) => _appearance.setDark(isDark);

  AppLanguage get language => profile.language ?? AppLanguage.english;

  String get syllabusLabel {
    final classLevel = profile.classLevel;
    final board = profile.board;
    if (classLevel == null) return 'Not set';
    return board == null
        ? 'Class $classLevel'
        : 'Class $classLevel · ${board.code}';
  }

  String get notificationsLabel =>
      _preferences.remindsToStudy ? _preferences.reminderLabel : 'Off';

  NotificationAccess get notificationAccess =>
      _reminders?.access ?? NotificationAccess.unknown;

  Future<void> turnOnNotifications() async => _reminders?.turnOn();

  Future<void> updatePreferences(StudyPreferences next) async {
    _preferences = next;
    notifyListeners();
    await _store.write(next);
  }

  Future<void> _loadPreferences() async {
    _preferences = await _store.read();
    notifyListeners();
  }

  Future<Result<Profile>> _saveSyllabus(Syllabus syllabus) => _profiles.update(
    ProfileUpdate(classLevel: syllabus.classLevel, board: syllabus.board),
  );

  Future<Result<Profile>> _saveLanguage(AppLanguage language) =>
      _profiles.update(ProfileUpdate(language: language));

  Future<Result<Account>> _saveName(FullName name) async {
    final result = await _auth.updateName(
      firstName: name.first,
      lastName: name.last,
    );
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _profiles.removeListener(notifyListeners);
    _appearance.removeListener(notifyListeners);
    _reminders?.removeListener(notifyListeners);
    _billing?.removeListener(notifyListeners);
    for (final command in <Command<Object?>>[
      saveSyllabus,
      saveLanguage,
      saveName,
      logOut,
      changePassword,
      linkGoogle,
      unlinkGoogle,
      deleteAccount,
    ]) {
      command
        ..removeListener(notifyListeners)
        ..dispose();
    }
    super.dispose();
  }
}
