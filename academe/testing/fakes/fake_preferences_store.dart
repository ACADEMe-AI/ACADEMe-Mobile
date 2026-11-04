import 'package:academe/data/services/preferences_store.dart';
import 'package:academe/domain/models/study_preferences.dart';

class FakePreferencesStore implements PreferencesStore {
  FakePreferencesStore([this.stored = const StudyPreferences()]);

  StudyPreferences stored;
  int lastNotifiedLevelStored = 0;
  int softUpdateDismissedBuildStored = 0;

  @override
  Future<StudyPreferences> read() async => stored;

  @override
  Future<void> write(StudyPreferences preferences) async =>
      stored = preferences;

  @override
  Future<int> lastNotifiedLevel() async => lastNotifiedLevelStored;

  @override
  Future<void> saveLastNotifiedLevel(int level) async =>
      lastNotifiedLevelStored = level;

  @override
  Future<int> softUpdateDismissedBuild() async =>
      softUpdateDismissedBuildStored;

  @override
  Future<void> saveSoftUpdateDismissedBuild(int build) async =>
      softUpdateDismissedBuildStored = build;
}
