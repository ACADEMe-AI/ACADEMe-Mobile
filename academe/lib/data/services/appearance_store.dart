import 'package:shared_preferences/shared_preferences.dart';

abstract class AppearanceStore {
  Future<bool> readIsDark();

  Future<void> writeIsDark(bool isDark);
}

class SharedPreferencesAppearanceStore implements AppearanceStore {
  final _preferences = SharedPreferencesAsync();

  static const _key = 'appearance_dark';

  @override
  Future<bool> readIsDark() async => await _preferences.getBool(_key) ?? false;

  @override
  Future<void> writeIsDark(bool isDark) => _preferences.setBool(_key, isDark);
}
