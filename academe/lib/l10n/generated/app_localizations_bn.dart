// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'অ্যাপের ভাষা';

  @override
  String get meLanguageSheetBody =>
      'পেবি ও স্ক্যানের উত্তর এই ভাষায় হবে। অ্যাপ মেনু এখনো ইংরেজিতে।';

  @override
  String get meMoreLanguagesComing => 'আরও ভাষা শীঘ্রই আসছে';

  @override
  String languageSwitchingTo(String name) {
    return '$name-এ স্যুইচ হচ্ছে…';
  }
}
