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

  @override
  String get welcomeHeadlineLead => 'स्मार्ट\nपढ़ो।';

  @override
  String get welcomeHeadlineAccent => 'ज़्यादा नहीं।';

  @override
  String get welcomeBody =>
      'नोट्स, क्विज़ और फ्लैशकार्ड्स — वही जो तुम असल में पढ़ रहे हो।';

  @override
  String get welcomeGetStarted => 'शुरू करें';

  @override
  String get welcomeAlreadyHaveAccount => 'पहले से अकाउंट है? ';

  @override
  String get welcomeNewUser => 'नए हो? ';

  @override
  String get welcomeLegal =>
      'आगे बढ़कर आप हमारी शर्तों और गोपनीयता नीति से सहमत होते हैं।';

  @override
  String get authSignUp => 'साइन अप';

  @override
  String get authLogIn => 'लॉग इन';

  @override
  String get authContinueGoogle => 'Google से जारी रखें';

  @override
  String get authContinueApple => 'Apple से जारी रखें';

  @override
  String get authContinueEmail => 'ईमेल से जारी रखें';
}
