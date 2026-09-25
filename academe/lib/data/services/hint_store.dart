import 'package:shared_preferences/shared_preferences.dart';

enum Hint { askPebby, notificationPermission, notificationPrimer }

abstract class HintStore {
  Future<bool> hasSeen(Hint hint);

  Future<void> markSeen(Hint hint);
}

class SharedPreferencesHintStore implements HintStore {
  final _preferences = SharedPreferencesAsync();

  static String _key(Hint hint) => 'hint_seen_${hint.name}';

  @override
  Future<bool> hasSeen(Hint hint) async =>
      await _preferences.getBool(_key(hint)) ?? false;

  @override
  Future<void> markSeen(Hint hint) => _preferences.setBool(_key(hint), true);
}
