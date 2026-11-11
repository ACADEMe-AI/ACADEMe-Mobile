// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'App language';

  @override
  String get meLanguageSheetBody =>
      'Pebby and Scan teaching replies use this language. App menus stay in English for now.';

  @override
  String get meMoreLanguagesComing => 'More languages coming soon';

  @override
  String languageSwitchingTo(String name) {
    return 'Switching to $name…';
  }
}
