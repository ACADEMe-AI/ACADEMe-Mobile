// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'యాప్ భాష';

  @override
  String get meLanguageSheetBody =>
      'పెబ్బీ మరియు స్కాన్ సమాధానాలు ఈ భాషలో ఉంటాయి. యాప్ ఇంటర్‌ఫేస్ కూడా ఈ భాషలోకి వస్తోంది.';

  @override
  String get meMoreLanguagesComing => 'మరిన్ని భాషలు త్వరలో';

  @override
  String languageSwitchingTo(String name) {
    return '$nameకి మారుతోంది…';
  }

  @override
  String get navHome => 'హోమ్';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'చదువు';

  @override
  String get navMe => 'నేను';

  @override
  String get navScan => 'స్కాన్';

  @override
  String get navSend => 'పంపు';

  @override
  String get askAnythingHint => 'ఏదైనా అడగండి…';

  @override
  String get askAttach => 'జతపరచు';

  @override
  String get softUpdateDefaultMessage =>
      'కొత్త వెర్షన్ వచ్చింది, మిస్ అవ్వకండి!';

  @override
  String get softUpdateAction => 'అప్‌డేట్';

  @override
  String get softUpdateDismiss => 'ఇప్పుడు కాదు';

  @override
  String get updateRequiredTitle => 'ఆగండి';

  @override
  String get updateRequiredBody =>
      'ఈ బిల్డ్ ఇక మా సర్వర్‌లతో మాట్లాడదు. చదువు కొనసాగించడానికి Playలో అప్‌డేట్ చేయండి.';

  @override
  String updateRequiredBuild(String build) {
    return 'ఇన్‌స్టాల్ బిల్డ్ $build.';
  }

  @override
  String get updateRequiredAction => 'Google Playలో అప్‌డేట్ చేయండి';

  @override
  String get pebbySemantics => 'పెబ్బీ';

  @override
  String get welcomeHeadlineLead => 'స్మార్ట్‌గా\nచదవండి.';

  @override
  String get welcomeHeadlineAccent => 'ఎక్కువ కాదు.';

  @override
  String get welcomeBody =>
      'మీరు నిజంగా చదువుతున్న వాటి నుండి నోట్స్, క్విజ్‌లు మరియు ఫ్లాష్‌కార్డ్‌లు.';

  @override
  String get welcomeGetStarted => 'ప్రారంభించండి';

  @override
  String get welcomeAlreadyHaveAccount => 'ఇప్పటికే అకౌంట్ ఉందా? ';

  @override
  String get welcomeNewUser => 'కొత్త వాడా? ';

  @override
  String get welcomeLegal =>
      'కొనసాగించడం ద్వారా మీరు మా నిబంధనలు మరియు గోప్యతా విధానాన్ని అంగీకరిస్తున్నారు.';

  @override
  String get authSignUp => 'సైన్ అప్';

  @override
  String get authLogIn => 'లాగిన్';

  @override
  String get authContinueGoogle => 'Googleతో కొనసాగించండి';

  @override
  String get authContinueApple => 'Appleతో కొనసాగించండి';

  @override
  String get authContinueEmail => 'ఇమెయిల్‌తో కొనసాగించండి';
}
