import 'package:academe/data/services/preferences_store.dart';
import 'package:academe/domain/models/study_preferences.dart';

class FakePreferencesStore implements PreferencesStore {
  FakePreferencesStore([this.stored = const StudyPreferences()]);

  StudyPreferences stored;

  @override
  Future<StudyPreferences> read() async => stored;

  @override
  Future<void> write(StudyPreferences preferences) async =>
      stored = preferences;
}
