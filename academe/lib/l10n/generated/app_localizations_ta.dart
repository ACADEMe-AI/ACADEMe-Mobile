// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'ஆப் மொழி';

  @override
  String get meLanguageSheetBody =>
      'பெப்பி மற்றும் ஸ்கேன் பதில்கள் இந்த மொழியில் இருக்கும். ஆப் இடைமுகமும் இந்த மொழிக்கு மாறி வருகிறது.';

  @override
  String get meMoreLanguagesComing => 'மேலும் மொழிகள் விரைவில்';

  @override
  String languageSwitchingTo(String name) {
    return '$nameக்கு மாறுகிறது…';
  }

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'படிப்பு';

  @override
  String get navMe => 'நான்';

  @override
  String get navScan => 'ஸ்கேன்';

  @override
  String get navSend => 'அனுப்பு';

  @override
  String get askAnythingHint => 'எதையும் கேளுங்கள்…';

  @override
  String get askAttach => 'இணை';

  @override
  String get softUpdateDefaultMessage =>
      'புதிய பதிப்பு வந்துவிட்டது, தவறவிடாதீர்கள்!';

  @override
  String get softUpdateAction => 'புதுப்பி';

  @override
  String get softUpdateDismiss => 'இப்போது வேண்டாம்';

  @override
  String get updateRequiredTitle => 'பொறுங்கள்';

  @override
  String get updateRequiredBody =>
      'இந்த பில்டு இனி எங்கள் சேவையகங்களுடன் பேசாது. படிப்பைத் தொடர Play-இல் புதுப்பிக்கவும்.';

  @override
  String updateRequiredBuild(String build) {
    return 'நிறுவிய பில்டு $build.';
  }

  @override
  String get updateRequiredAction => 'Google Play-இல் புதுப்பிக்கவும்';

  @override
  String get pebbySemantics => 'பெப்பி';
}
