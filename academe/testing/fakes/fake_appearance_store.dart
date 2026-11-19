import 'package:academe/data/services/appearance_store.dart';

class FakeAppearanceStore implements AppearanceStore {
  bool isDark = false;

  @override
  Future<bool> readIsDark() async => isDark;

  @override
  Future<void> writeIsDark(bool isDark) async => this.isDark = isDark;
}
