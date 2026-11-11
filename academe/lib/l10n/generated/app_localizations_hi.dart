// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'ऐप की भाषा';

  @override
  String get meLanguageSheetBody =>
      'पेबी और स्कैन के जवाब इस भाषा में होंगे। ऐप का इंटरफ़ेस भी इसी भाषा में आता जा रहा है।';

  @override
  String get meMoreLanguagesComing => 'और भाषाएँ जल्द आ रही हैं';

  @override
  String languageSwitchingTo(String name) {
    return '$name पर स्विच हो रहा है…';
  }

  @override
  String get navHome => 'होम';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'पढ़ाई';

  @override
  String get navMe => 'मैं';

  @override
  String get navScan => 'स्कैन';

  @override
  String get navSend => 'भेजें';

  @override
  String get askAnythingHint => 'कुछ भी पूछो…';

  @override
  String get askAttach => 'अटैच';

  @override
  String get softUpdateDefaultMessage => 'नया वर्शन आ गया है, मिस मत करना!';

  @override
  String get softUpdateAction => 'अपडेट';

  @override
  String get softUpdateDismiss => 'अभी नहीं';

  @override
  String get updateRequiredTitle => 'रुक जाओ';

  @override
  String get updateRequiredBody =>
      'यह बिल्ड अब हमारे सर्वर से बात नहीं कर सकता। पढ़ाई जारी रखने के लिए Play पर अपडेट करो।';

  @override
  String updateRequiredBuild(String build) {
    return 'इंस्टॉल बिल्ड $build।';
  }

  @override
  String get updateRequiredAction => 'Google Play पर अपडेट करो';

  @override
  String get pebbySemantics => 'पेबी';
}
