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

  @override
  String get loginHeadlineLead => 'మళ్లీ';

  @override
  String get loginHeadlineAccent => 'స్వాగతం.';

  @override
  String get loginSubtitle => 'మీరు ఆపిన చోట నుంచి కొనసాగండి.';

  @override
  String get authEmail => 'ఇమెయిల్';

  @override
  String get authPassword => 'పాస్‌వర్డ్';

  @override
  String get authShowPassword => 'పాస్‌వర్డ్ చూపించు';

  @override
  String get authHidePassword => 'పాస్‌వర్డ్ దాచు';

  @override
  String get authForgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get authLoggingIn => 'లాగిన్ అవుతోంది…';

  @override
  String get authNewHere => 'కొత్తవారా? ';

  @override
  String get forgotPasswordLead => 'పాస్‌వర్డ్';

  @override
  String get forgotPasswordAccent => 'మర్చిపోయారా?';

  @override
  String get forgotPasswordSubtitle =>
      'మీ ఇమెయిల్ టైప్ చేయండి, 6 అంకెల కోడ్ పంపుతాను.';

  @override
  String get authSending => 'పంపుతోంది…';

  @override
  String get authSendCode => 'కోడ్ పంపు';

  @override
  String get resetCodeLead => 'మీ';

  @override
  String get resetCodeAccent => 'ఇమెయిల్ చూడండి.';

  @override
  String resetCodeSubtitle(String email) {
    return '$emailకి ACADEMe అకౌంట్ ఉంటే, 6 అంకెల కోడ్ వస్తోంది. ఇది 15 నిమిషాల్లో ముగుస్తుంది.';
  }

  @override
  String get authPasteCode => 'కోడ్ పేస్ట్ చేయి';

  @override
  String get authChecking => 'తనిఖీ చేస్తోంది…';

  @override
  String get authVerify => 'వెరిఫై';

  @override
  String get resetDidntGetIt => 'రాలేదా? ';

  @override
  String get resetSendNewCode => 'కొత్త కోడ్ పంపు';

  @override
  String get resetSendingNewCode => 'కొత్త కోడ్ పంపుతోంది…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'కొత్త కోడ్ పంపబడింది. మళ్లీ అడగవచ్చు 0:$secondsలో';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'కొత్త కోడ్ 0:$secondsలో అడగవచ్చు';
  }

  @override
  String get newPasswordLead => 'కొత్త';

  @override
  String get newPasswordAccent => 'పాస్‌వర్డ్ ఎంచుకోండి.';

  @override
  String get newPasswordSubtitle =>
      'కనీసం 8 అక్షరాలు. చింతించకండి, నేను చూడను.';

  @override
  String get authNewPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ అక్షరాలు';
  }

  @override
  String get authStartAgain => 'మళ్లీ ప్రారంభించు';

  @override
  String get authSaving => 'సేవ్ అవుతోంది…';

  @override
  String get authSaveAndLogIn => 'సేవ్ చేసి లాగిన్';
}
