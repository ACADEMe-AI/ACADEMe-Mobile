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

  @override
  String get authFailureEmailTaken =>
      'ఈ ఇమెయిల్‌తో ఇప్పటికే అకౌంట్ ఉంది. లాగిన్ అవ్వండి.';

  @override
  String get authFailureWrongCredentials =>
      'ఇమెయిల్ మరియు పాస్‌వర్డ్ సరిపోలడం లేదు.';

  @override
  String get authFailureInvalidInput =>
      'వివరాలు తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authFailureSignedOut => 'సెషన్ ముగిసింది. మళ్లీ లాగిన్ అవ్వండి.';

  @override
  String get authFailureNetwork =>
      'ACADEMeని చేరుకోలేకపోయాం. కనెక్షన్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authFailureCanceled => 'సైన్-ఇన్ రద్దు చేయబడింది.';

  @override
  String get authFailureProviderUnavailable =>
      'ఈ సైన్-ఇన్ ఎంపిక ఇంకా సిద్ధం కాదు. ఇప్పుడు ఇమెయిల్ వాడండి.';

  @override
  String get authFailureWrongCode =>
      'కోడ్ సరైనది కాదు. ఇమెయిల్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authFailureTooManyAttempts =>
      'చాలా తప్పు ప్రయత్నాలు. కొత్త కోడ్ పంపించుకోండి.';

  @override
  String get authFailureCodeExpired =>
      'కోడ్ గడువు ముగిసింది. కొత్తది పంపించుకోండి.';

  @override
  String get authFailureResetExpired =>
      'రీసెట్ లింక్ గడువు ముగిసింది. పాస్‌వర్డ్ మర్చిపోయాను నుంచి మళ్లీ ప్రారంభించండి.';

  @override
  String get authFailureTooManyRequests =>
      'చాలా ప్రయత్నాలు. కాసేపు ఆగి మళ్లీ ప్రయత్నించండి.';

  @override
  String get authFailureWrongPassword => 'ఇది మీ ప్రస్తుత పాస్‌వర్డ్ కాదు.';

  @override
  String get authFailureGoogleTaken =>
      'ఈ Google అకౌంట్ మరొక ACADEMe అకౌంట్‌కి లింక్ అయింది.';

  @override
  String get authFailurePasswordRequired =>
      'ముందు పాస్‌వర్డ్ సెట్ చేయండి, Google లేకుండా కూడా లాగిన్ అవ్వడానికి.';

  @override
  String get authFailureUnknown => 'ఏదో తప్పు జరిగింది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get signUpHiPebby => 'హాయ్, నేను పెబ్బీ!';

  @override
  String signUpHiNamed(String name) {
    return 'హాయ్ $name, నేను పెబ్బీ!';
  }

  @override
  String get signUpAskFirstName => 'మొదలుపెట్టే ముందు, నిన్ను ఏమని పిలవాలి?';

  @override
  String get signUpFirstName => 'మొదటి పేరు';

  @override
  String signUpAskLastName(String name) {
    return 'కలవడం సంతోషం, $name! మీ చివరి పేరు?';
  }

  @override
  String get signUpLastName => 'చివరి పేరు';

  @override
  String signUpAskEmail(String name) {
    return 'మీ ఇమెయిల్ ఏమిటి, $name?';
  }

  @override
  String get signUpEmailHint => 'లాగిన్ కోసం దీన్ని వాడతారు.';

  @override
  String get signUpEmailInvalid => 'ఇది ఇంకా ఇమెయిల్‌లా కనిపించడం లేదు.';

  @override
  String get signUpCreatePassword => 'పాస్‌వర్డ్ సృష్టించండి';

  @override
  String signUpPasswordHint(int count) {
    return 'కనీసం $count అక్షరాలు. చింతించకండి, నేను చూడను.';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'మళ్లీ స్వాగతం, $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'మీకు ఇప్పటికే అకౌంట్ ఉంది, కాబట్టి మీరు లాగిన్ అయ్యారు.';

  @override
  String signUpYoureIn(String name) {
    return 'మీరు లోపలికి వచ్చారు, $name!';
  }

  @override
  String get signUpAccountReady =>
      'అకౌంట్ సిద్ధం. తర్వాత మీరు ఏమి చదువుతున్నారో చెప్పండి.';

  @override
  String get signUpHelloEmail =>
      'నేను స్మార్ట్‌గా చదవడంలో సహాయం చేస్తాను. అకౌంట్ సెటప్ చేద్దాం, ఒక నిమిషం పడుతుంది.';

  @override
  String get signUpConnectingAccount => 'మీ అకౌంట్ కనెక్ట్ అవుతోంది…';

  @override
  String get signUpCheckName => 'పేరు చూద్దాం, తర్వాత మీరు లోపలికి.';

  @override
  String get signUpConnecting => 'కనెక్ట్ అవుతోంది…';

  @override
  String get signUpTryAgain => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get signUpHiPebbyAction => 'హాయ్ పెబ్బీ!';

  @override
  String get signUpCreatingAccount => 'అకౌంట్ సృష్టిస్తోంది…';

  @override
  String get signUpCreateAccount => 'అకౌంట్ సృష్టించు';

  @override
  String get signUpLetsGo => 'వెళ్దాం';

  @override
  String get authContinue => 'కొనసాగించు';

  @override
  String get homeSetupTitle => 'మీ డాష్‌బోర్డ్ సెటప్ చేయండి';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'భాష';

  @override
  String get homeSetupTaskAge => 'మీ వయస్సు';

  @override
  String get homeSetupTaskClass => 'మీ తరగతి';

  @override
  String get homeSetupTaskBoard => 'మీ బోర్డు';

  @override
  String get homeSetupTaskSubjects => 'మీ సబ్జెక్టులు';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'హోమ్‌వర్క్ సాల్వ్ చేయండి';

  @override
  String get homeCheckAnswer => 'సమాధానం చెక్ చేయండి';

  @override
  String get homeFlashcards => 'ఫ్లాష్‌కార్డ్‌లు';

  @override
  String get homePickSubjects => 'మీ సబ్జెక్టులు ఎంచుకోండి';

  @override
  String homePickSubjectsBody(int xp) {
    return 'హోమ్ మరియు స్టడీలో మీరు చదివేవి మాత్రమే కనిపిస్తాయి. +$xp XP';
  }
}
