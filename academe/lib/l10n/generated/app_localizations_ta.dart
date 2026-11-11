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
      'பெப்பி மற்றும் ஸ்கேன் பதில்கள் இந்த மொழியில் இருக்கும். ஆப் மெனுக்கள் இன்னும் ஆங்கிலத்தில் உள்ளன.';

  @override
  String get meMoreLanguagesComing => 'மேலும் மொழிகள் விரைவில்';

  @override
  String languageSwitchingTo(String name) {
    return '$nameக்கு மாறுகிறது…';
  }
}
