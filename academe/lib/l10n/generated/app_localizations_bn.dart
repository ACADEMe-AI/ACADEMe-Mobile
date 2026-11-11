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
      'পেবি ও স্ক্যানের উত্তর এই ভাষায় হবে। অ্যাপের ইন্টারফেসও এই ভাষায় আসছে।';

  @override
  String get meMoreLanguagesComing => 'আরও ভাষা শীঘ্রই আসছে';

  @override
  String languageSwitchingTo(String name) {
    return '$name-এ স্যুইচ হচ্ছে…';
  }

  @override
  String get navHome => 'হোম';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'পড়াশোনা';

  @override
  String get navMe => 'আমি';

  @override
  String get navScan => 'স্ক্যান';

  @override
  String get navSend => 'পাঠান';

  @override
  String get askAnythingHint => 'যা খুশি জিজ্ঞাসা করুন…';

  @override
  String get askAttach => 'অ্যাটাচ';

  @override
  String get softUpdateDefaultMessage => 'নতুন ভার্সন এসেছে, মিস করবেন না!';

  @override
  String get softUpdateAction => 'আপডেট';

  @override
  String get softUpdateDismiss => 'এখন নয়';

  @override
  String get updateRequiredTitle => 'একটু দাঁড়ান';

  @override
  String get updateRequiredBody =>
      'এই বিল্ড আর আমাদের সার্ভারের সাথে কথা বলতে পারে না। পড়া চালিয়ে যেতে Play-এ আপডেট করুন।';

  @override
  String updateRequiredBuild(String build) {
    return 'ইনস্টল করা বিল্ড $build।';
  }

  @override
  String get updateRequiredAction => 'Google Play-এ আপডেট করুন';

  @override
  String get pebbySemantics => 'পেবি';
}
