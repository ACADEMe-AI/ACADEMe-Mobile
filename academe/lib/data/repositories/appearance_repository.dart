import 'package:flutter/foundation.dart';

import '../../utils/safe_notifier.dart';
import '../services/appearance_store.dart';

class AppearanceRepository extends ChangeNotifier with SafeNotifier {
  AppearanceRepository({required AppearanceStore store, bool isDark = false})
    : _store = store,
      _isDark = isDark;

  final AppearanceStore _store;
  bool _isDark;

  bool get isDark => _isDark;

  static Future<AppearanceRepository> load(AppearanceStore store) async =>
      AppearanceRepository(store: store, isDark: await store.readIsDark());

  Future<void> setDark(bool isDark) async {
    if (isDark == _isDark) return;
    _isDark = isDark;
    notifyListeners();
    await _store.writeIsDark(isDark);
  }
}
