import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/study_preferences.dart';

abstract class PreferencesStore {
  Future<StudyPreferences> read();

  Future<void> write(StudyPreferences preferences);
}

class SharedPreferencesStore implements PreferencesStore {
  final _preferences = SharedPreferencesAsync();

  static const _prefix = 'study_';

  @override
  Future<StudyPreferences> read() async {
    const fallback = StudyPreferences();
    Future<bool> flag(String key, bool or) async =>
        await _preferences.getBool('$_prefix$key') ?? or;
    Future<int> number(String key, int or) async =>
        await _preferences.getInt('$_prefix$key') ?? or;
    final days = await _preferences.getStringList('${_prefix}days');
    return StudyPreferences(
      remindsToStudy: await flag('reminds', fallback.remindsToStudy),
      reminderHour: await number('hour', fallback.reminderHour),
      reminderMinute: await number('minute', fallback.reminderMinute),
      reminderDays: days == null
          ? fallback.reminderDays
          : {for (final d in days) ?int.tryParse(d)},
      savesStreak: await flag('streak', fallback.savesStreak),
      warnsBeforeTests: await flag('tests', fallback.warnsBeforeTests),
      celebratesLevelUps: await flag('levels', fallback.celebratesLevelUps),
      dailyGoalMinutes: await number('goal', fallback.dailyGoalMinutes),
    );
  }

  @override
  Future<void> write(StudyPreferences p) async {
    await _preferences.setBool('${_prefix}reminds', p.remindsToStudy);
    await _preferences.setInt('${_prefix}hour', p.reminderHour);
    await _preferences.setInt('${_prefix}minute', p.reminderMinute);
    await _preferences.setStringList('${_prefix}days', [
      for (final d in p.reminderDays) '$d',
    ]);
    await _preferences.setBool('${_prefix}streak', p.savesStreak);
    await _preferences.setBool('${_prefix}tests', p.warnsBeforeTests);
    await _preferences.setBool('${_prefix}levels', p.celebratesLevelUps);
    await _preferences.setInt('${_prefix}goal', p.dailyGoalMinutes);
  }
}
