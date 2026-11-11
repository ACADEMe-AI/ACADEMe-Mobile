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

  @override
  String get setupLanguageTitle => 'మీరు ఏ భాషలో నేర్చుకుంటారు?';

  @override
  String setupChooseLanguage(String name) {
    return '$name ఎంచుకోండి';
  }

  @override
  String get setupLanguageFootnote => 'సెట్టింగ్స్‌లో ఎప్పుడైనా మార్చవచ్చు.';

  @override
  String get setupAgeTitle => 'మీరు ఎప్పుడు పుట్టారు?';

  @override
  String get setupAgeSubtitle => 'వయసుకు సరిపడా ఉంచడానికి.';

  @override
  String get setupBirthYear => 'పుట్టిన సంవత్సరం';

  @override
  String setupYouAreAge(int age) {
    return 'మీ వయస్సు $age.';
  }

  @override
  String get setupClassTitle => 'మీ తరగతికి తిప్పండి';

  @override
  String get setupClassSubtitle => 'డయల్ తిప్పండి లేదా సంఖ్య తట్టండి.';

  @override
  String setupImInClass(int level) {
    return 'నేను క్లాస్ $levelలో ఉన్నాను';
  }

  @override
  String get setupBoardTitle => 'ఏ బోర్డు?';

  @override
  String get setupBoardSubtitle => 'మీ బోర్డు సిలబస్‌ను అనుసరిస్తాం.';

  @override
  String get setupStateBoardsSoon => 'రాష్ట్ర బోర్డులు త్వరలో.';

  @override
  String get setupFinish => 'సెటప్ పూర్తి చేయండి';

  @override
  String setupProgress(int step, int total) {
    return 'సెటప్ · $step/$total';
  }

  @override
  String get setupLater => 'తర్వాత';

  @override
  String get setupChangeInMe => 'Meలో ఎప్పుడైనా మార్చవచ్చు.';

  @override
  String setupStreamTitle(int level) {
    return 'క్లాస్ $levelలో మీరు ఏమి చదువుతారు?';
  }

  @override
  String get setupAnythingElse => 'ఇంకేమైనా?';

  @override
  String get setupWhichSubjects => 'మీరు ఏ సబ్జెక్టులు చదువుతారు?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus. ప్రధాన సబ్జెక్టులు వచ్చాయి.';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus. చదవనివి తీసేయండి.';
  }

  @override
  String get homeYourSubjects => 'మీ సబ్జెక్టులు';

  @override
  String get homeEdit => 'ఎడిట్';

  @override
  String get homeSubjectsNeedSyllabus =>
      'సబ్జెక్టులు చూడటానికి తరగతి మరియు బోర్డు సెట్ చేయండి';

  @override
  String get homeSubjectsLoading => 'సబ్జెక్టులు లోడ్ అవుతున్నాయి…';

  @override
  String get homeSubjectsSoon => 'మీ సబ్జెక్టులు ఇక్కడ త్వరలో కనిపిస్తాయి.';

  @override
  String homeNextChapter(int number, String title) {
    return 'తర్వాత: Ch $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'అన్ని పాఠాలు పూర్తి';

  @override
  String get homeLessonsComingSoon => 'పాఠాలు త్వరలో';

  @override
  String homeTodayMinutes(int minutes) {
    return 'ఈరోజు · $minutes నిమి';
  }

  @override
  String get homeTodayDone => 'ఈరోజు · అన్నీ పూర్తి';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ఫోల్డర్ల నుండి',
      one: '1 ఫోల్డర్ నుండి',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'మరియు మీ ఫోల్డర్లలో ఇంకా $count';
  }

  @override
  String get homeAskHintTitle => 'పెబ్బీని ఏదైనా అడగండి';

  @override
  String get homeAskHintBody =>
      'ప్రశ్న టైప్ చేయండి, లేదా హోమ్‌వర్క్ సాల్వ్ తట్టి ఫోటో తీయండి.';

  @override
  String get homeAskHintGotIt => 'అర్థమైంది';

  @override
  String get homeDashboardLoadError => 'డాష్‌బోర్డ్ లోడ్ కాలేదు.';

  @override
  String get homeRetry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get helloFallbackName => 'స్నేహితుడు';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల స్ట్రీక్',
      one: '1 రోజు స్ట్రీక్',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'నోట్స్ ఫోల్డర్‌లో';

  @override
  String get scanModeAsk => 'ఫోటో గురించి అడుగు';

  @override
  String get scanWhatsOnPaper => 'కాగితం మీద ఏముంది?';

  @override
  String get scanHintSolve => 'ముందు హింట్';

  @override
  String get scanHintCheck => 'బోర్డ్-స్టైల్ మార్కులు';

  @override
  String get scanHintNotes => 'పేజీల నుంచి పాఠం';

  @override
  String get scanHintAsk => 'ఇంకేదైనా';

  @override
  String get scanRecent => 'ఇటీవలి స్కాన్లు';

  @override
  String get scanStatusRead => 'చదివాను';

  @override
  String get scanStatusSolvedInAskMe => 'ASKMeలో సాల్వ్ చేశాను';

  @override
  String get scanStatusAskedInAskMe => 'ASKMeలో అడిగాను';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count మార్కులు',
      one: '1 మార్కు',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'ఇంకా మార్క్ కాలేదు';

  @override
  String get scanStatusLessonInFolder => 'ఫోల్డర్‌లో పాఠం';

  @override
  String get scanStatusNotesInFolder => 'ఫోల్డర్‌లో నోట్స్';

  @override
  String get scanStatusNotSaved => 'ఇంకా సేవ్ కాలేదు';

  @override
  String get scanSourceNotesBlurb =>
      'గరిష్టం 10 పేజీలు. ఫోటోలు కాదు, టెక్స్ట్ మాత్రమే ఉంచబడుతుంది.';

  @override
  String get scanSourceBlurb => 'ఫోటో కాదు, టెక్స్ట్ మాత్రమే ఉంచబడుతుంది.';

  @override
  String get scanTakePhoto => 'ఫోటో తీయి';

  @override
  String get scanChooseGallery => 'గ్యాలరీ నుంచి ఎంచుకో';

  @override
  String get scanCamera => 'కెమెరా';

  @override
  String get scanGallery => 'గ్యాలరీ';

  @override
  String get scanYourPages => 'నీ పేజీలు';

  @override
  String scanPagesOf(int current, int max) {
    return '$current / $max';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పేజీలు చదువు',
      one: '1 పేజీ చదువు',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'పేజీ తీసేయి';

  @override
  String get scanYourNotes => 'నీ నోట్స్';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'పెబ్బీ $count పేజీలు చదివాడు',
      one: 'పెబ్బీ 1 పేజీ చదివాడు',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'ఇవి ఎక్కడ ఉంచాలి?';

  @override
  String get scanChooseFolder => 'ఫోల్డర్ ఎంచుకో';

  @override
  String get scanChange => 'మార్చు';

  @override
  String get scanMakeFromNotes => 'నోట్స్ నుంచి తయారు చేయి';

  @override
  String get scanSwipeLesson => 'స్వైప్ పాఠం';

  @override
  String get scanSwipeLessonSubtitle =>
      'కార్డులు, చిన్న చెక్‌లు — ప్లాన్‌లో చేరతాయి';

  @override
  String get scanKeepNotes => 'నోట్స్ మాత్రమే ఉంచు';

  @override
  String get scanKeepNotesSubtitle => 'టెక్స్ట్ ఫోల్డర్‌లోకి వెళ్తుంది';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పేజీలు చదువుతున్నాను…',
      one: 'నీ పేజీ చదువుతున్నాను…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'కొన్ని సెకన్లు పడుతుంది.';

  @override
  String get scanMakingLesson => 'నీ పాఠం తయారవుతోంది…';

  @override
  String get scanSavingNotes => 'నీ నోట్స్ సేవ్ అవుతున్నాయి…';

  @override
  String get scanSavingWait => 'ఇవి నీ ఫోల్డర్‌లో ఉంటాయి.';

  @override
  String get scanFailUnavailableTitle => 'స్కాన్ ఇంకా సిద్ధం కాలేదు';

  @override
  String get scanFailUnavailableBody =>
      'పెబ్బీ ఇప్పుడు ఫోటోలు చదవలేడు. తర్వాత మళ్లీ ప్రయత్నించు.';

  @override
  String get scanFailNoTextTitle => 'ఇక్కడ మాటలు లేవు';

  @override
  String get scanFailNoTextBody =>
      'కెమెరాను హోమ్‌వర్క్, పాఠ్యపుస్తకం పేజీ లేదా నోట్స్ మీద పెట్టు.';

  @override
  String get scanFailTooLargeTitle => 'చాలా పెద్ద ఫోటోలు';

  @override
  String get scanFailTooLargeBody => 'ఒకేసారి తక్కువ పేజీలు ప్రయత్నించు.';

  @override
  String get scanFailNetworkTitle => 'నువ్వు ఆఫ్‌లైన్‌లో ఉన్నావు';

  @override
  String get scanFailNetworkBody => 'ఇంటర్నెట్ చూసి మళ్లీ ప్రయత్నించు.';

  @override
  String get scanFailScanLimitTitle => 'ఈరోజు ఉచిత స్కాన్లు అయిపోయాయి';

  @override
  String get scanFailScanLimitBody =>
      'అర్ధరాత్రి తిరిగి వస్తాయి. ఎన్ని కావాలంటే అన్ని స్కాన్ చేయడానికి Pro తీసుకో.';

  @override
  String get scanFailCheckLimitTitle => 'ఈరోజు ఉచిత చెక్ అయిపోయింది';

  @override
  String get scanFailCheckLimitBody =>
      'అర్ధరాత్రి తిరిగి వస్తుంది. ప్రతి సమాధానం చెక్ చేయడానికి Pro తీసుకో.';

  @override
  String get scanFailProOnlyTitle => 'నోట్స్ నుంచి పాఠాలు Pro';

  @override
  String get scanFailProOnlyBody =>
      'ఉచితంగా నోట్స్ ఉంచు, లేదా Pro తీసుకుంటే పెబ్బీ వాటితో పాఠం చేస్తాడు.';

  @override
  String get scanFailUnknownTitle => 'పెబ్బీ అది చదవలేకపోయాడు';

  @override
  String get scanFailUnknownBody =>
      'మళ్లీ ప్రయత్నించు, లేదా మంచి వెలుతురులో మళ్లీ ఫోటో తీయి.';

  @override
  String get scanBackToAnswer => 'నీ సమాధానానికి తిరిగి వెళ్లు';

  @override
  String get scanRetake => 'మళ్లీ తీయి';

  @override
  String get scanCameraOpenFailed =>
      'కెమెరా తెరవలేకపోయాను. గ్యాలరీ ప్రయత్నించు.';

  @override
  String get scanPebbyReadThis => 'పెబ్బీ ఇది చదివాడు';

  @override
  String get scanFixAnything => 'తప్పు ఉంటే సరిదిద్దు.';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · తప్పు ఉంటే సరిదిద్దు.';
  }

  @override
  String get scanFromYourPhoto => 'నీ ఫోటో నుంచి';

  @override
  String get scanFromMyPhoto => 'నా ఫోటో నుంచి:';

  @override
  String get scanWhatDoYouWant => 'నీకు ఏమి తెలుసుకోవాలి?';

  @override
  String get scanSuggestExplain => 'దీన్ని సింపుల్‌గా చెప్పు';

  @override
  String get scanSuggestSummarise => 'సారాంశం చెప్పు';

  @override
  String get scanSuggestKeyTerms => 'ముఖ్య పదాలు ఏమిటి?';

  @override
  String get scanSolveThis => 'దీన్ని సాల్వ్ చేయి';

  @override
  String get scanAskPebby => 'పెబ్బీని అడుగు';

  @override
  String get scanHintFirst => 'పెబ్బీ ముందు హింట్ ఇస్తాడు, తర్వాత స్టెప్స్.';

  @override
  String get checkPebbyReadAnswer => 'పెబ్బీ నీ సమాధానం చదివాడు';

  @override
  String get checkTheQuestion => 'ప్రశ్న';

  @override
  String get checkQuestionHint => 'ఫోటోలో లేకపోతే మాత్రమే';

  @override
  String get checkMarkIt => 'మార్క్ చేయి';

  @override
  String get checkMarkingAnswer => 'నీ సమాధానం మార్క్ అవుతోంది…';

  @override
  String get checkMarkingScheme => 'బోర్డు మార్కింగ్ స్కీమ్‌తో.';

  @override
  String get checkFullMarks => 'ఫుల్ మార్కులు!';

  @override
  String get checkNearlyThere => 'దాదాపు వచ్చావు';

  @override
  String get checkKeepGoing => 'కొనసాగించు';

  @override
  String get checkReportTitle => 'ఈ మార్కులను రిపోర్ట్ చేయి';

  @override
  String get checkReportThanks => 'ధన్యవాదాలు. ఈ మార్కులను చూస్తాం.';

  @override
  String get checkWhatGotMarks => 'దేనికి మార్కులు వచ్చాయి';

  @override
  String get checkWellDone => 'భలే చేశావు';

  @override
  String get checkForFullMarks => 'ఫుల్ మార్కుల కోసం';

  @override
  String get checkAgain => 'మళ్లీ చెక్ చేయి';

  @override
  String get checkShowModelAnswer => 'మోడల్ సమాధానం చూపించు';

  @override
  String get checkHideModelAnswer => 'మోడల్ సమాధానం దాచు';

  @override
  String checkAskQuestion(String question) {
    return 'ప్రశ్న: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'నా సమాధానం:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'నాకు $awarded/$marks వచ్చాయి. ఫుల్ మార్కులు ఎలా సాధించాలి?';
  }

  @override
  String get meLearningSection => 'నేర్చుకోవడం';

  @override
  String get meMyProgress => 'నా ప్రోగ్రెస్';

  @override
  String get meClassAndBoard => 'క్లాస్ మరియు బోర్డు';

  @override
  String get meAppearance => 'రూపం';

  @override
  String get meNotificationsSection => 'నోటిఫికేషన్లు';

  @override
  String get meRemindersAndDailyGoal => 'రిమైండర్లు మరియు రోజువారీ లక్ష్యం';

  @override
  String get meAccountSection => 'అకౌంట్';

  @override
  String get meAccount => 'అకౌంట్';

  @override
  String get meHelpAndFeedback => 'సహాయం మరియు ఫీడ్‌బ్యాక్';

  @override
  String get mePrivacyAndTerms => 'గోప్యత మరియు నిబంధనలు';

  @override
  String get meLogOut => 'లాగ్ అవుట్';

  @override
  String get meLoggingOut => 'లాగ్ అవుట్ అవుతోంది…';

  @override
  String get meStudentFallback => 'విద్యార్థి';

  @override
  String get meDayStreak => 'రోజుల స్ట్రీక్';

  @override
  String meLevelValue(int number) {
    return 'Lv $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return 'Lv $levelకి $xp XP';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'సరే';

  @override
  String meOkSwitchTo(String name) {
    return 'సరే · $nameకి మార్చు';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting ఇప్పుడు పెబ్బీ $nameలో సమాధానం ఇస్తుంది.';
  }

  @override
  String get meLanguageSwitchFailed => 'భాష మార్చలేకపోయాం. మళ్లీ ప్రయత్నించు.';

  @override
  String meOpenInBrowser(String url) {
    return 'బ్రౌజర్‌లో $url తెరువు';
  }

  @override
  String get meNotSet => 'సెట్ కాలేదు';

  @override
  String get meOff => 'ఆఫ్';

  @override
  String meClassOnly(int level) {
    return 'క్లాస్ $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'క్లాస్ $level · $board';
  }

  @override
  String get meLogOutTitle => 'లాగ్ అవుట్?';

  @override
  String get meLogOutBody =>
      'మీ ప్రోగ్రెస్ అకౌంట్‌లో సేవ్ అయింది. ఎప్పుడైనా మళ్లీ లాగిన్ అవ్వండి.';

  @override
  String get meLogOutStay => 'ఉండు';

  @override
  String get accountSaveName => 'పేరు సేవ్ చేయి';

  @override
  String get accountNameSaved => 'పేరు సేవ్ అయింది';

  @override
  String get accountDangerZone => 'ప్రమాద జోన్';

  @override
  String get accountDeleteMyAccount => 'నా అకౌంట్ తొలగించు';

  @override
  String get accountDeleteGraceNote =>
      'అడిగిన 30 రోజుల తర్వాత అకౌంట్ తొలగుతుంది. అప్పటిలోగా లాగిన్ అయి ఉంచుకోండి.';

  @override
  String get accountSignIn => 'సైన్-ఇన్';

  @override
  String get accountChangePassword => 'పాస్‌వర్డ్ మార్చు';

  @override
  String get accountSetPassword => 'పాస్‌వర్డ్ సెట్ చేయి';

  @override
  String get accountLinkGoogle => 'Google లింక్ చేయి';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'లింక్ అవుతోంది…';

  @override
  String get accountUnlinking => 'అన్‌లింక్ అవుతోంది…';

  @override
  String get accountNotLinked => 'లింక్ కాలేదు';

  @override
  String get accountGoogleLinked =>
      'Google లింక్ అయింది. ఇప్పుడు దానితో లాగిన్ అవ్వండి.';

  @override
  String get accountGoogleUnlinked =>
      'Google అన్‌లింక్ అయింది. ఇమెయిల్ మరియు పాస్‌వర్డ్‌తో లాగిన్ అవ్వండి.';

  @override
  String get accountUnlinkGoogleTitle => 'Google అన్‌లింక్ చేయాలా?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'ఇక $emailతో లాగిన్ కాలేరు. బదులు ఇమెయిల్ మరియు పాస్‌వర్డ్ వాడండి.';
  }

  @override
  String get accountKeepGoogle => 'Google ఉంచు';

  @override
  String get accountUnlink => 'అన్‌లింక్';

  @override
  String get passwordSave => 'పాస్‌వర్డ్ సేవ్ చేయి';

  @override
  String get passwordChangeBody =>
      'సైన్ అప్‌లోలాంటి నియమాలే. సేవ్ చేస్తే ఇతర డివైజ్‌లు లాగ్ అవుట్ అవుతాయి.';

  @override
  String get passwordSetBody =>
      'పాస్‌వర్డ్ జోడించు — Google మాత్రమే కాదు, ఇమెయిల్‌తో కూడా లాగిన్ అవ్వండి.';

  @override
  String get passwordCurrent => 'ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get passwordChangedSnack =>
      'పాస్‌వర్డ్ మారింది. ఇతర డివైజ్‌లు లాగ్ అవుట్ అయ్యాయి.';

  @override
  String get passwordSetSnack =>
      'పాస్‌వర్డ్ సెట్ అయింది. ఇప్పుడు ఇమెయిల్‌తో కూడా లాగిన్ అవ్వండి.';

  @override
  String get deleteAccountTitle => 'అకౌంట్ తొలగించు';

  @override
  String get deleteDeleting => 'తొలగిస్తోంది…';

  @override
  String get deleteSorryTitle => 'మీరు వెళ్తుంటే బాధగా ఉంది';

  @override
  String get deleteBody =>
      'మీ అకౌంట్ 30 రోజుల్లో తొలగుతుంది. అప్పటిలోగా మళ్లీ లాగిన్ అయి ఉంచుకోండి. 30 రోజుల తర్వాత ప్రొఫైల్, చాట్‌లు, ప్రోగ్రెస్ మరియు XP శాశ్వతంగా పోతాయి.';

  @override
  String get deleteSubscription => 'సబ్‌స్క్రిప్షన్';

  @override
  String get deleteSubscriptionNotice =>
      'అకౌంట్ తొలగించడం వల్ల Google Playలో కొన్న ACADEMe Pro సబ్‌స్క్రిప్షన్ రద్దు కాదు. మళ్లీ ఛార్జ్ కాకుండా Google Playలో రద్దు చేయండి.';

  @override
  String get deleteManageSubscription => 'సబ్‌స్క్రిప్షన్ నిర్వహించు';

  @override
  String get deleteWhyLeaving => 'ఎందుకు వెళ్తున్నారు? (ఐచ్ఛికం)';

  @override
  String deleteConfirmLabel(String word) {
    return 'నిర్ధారించడానికి $word టైప్ చేయి';
  }

  @override
  String get deleteReasonNotEnough => 'తగినంతగా వాడను';

  @override
  String get deleteReasonDidntHelp => 'నా చదువుకు సహాయం కాలేదు';

  @override
  String get deleteReasonTooManyNotifs => 'చాలా నోటిఫికేషన్లు';

  @override
  String get deleteReasonDataWorry => 'నా డేటా గురించి ఆందోళన';

  @override
  String get deleteReasonOther => 'ఏదో వేరే';

  @override
  String deleteScheduledSnack(String date) {
    return 'మీ అకౌంట్ $dateన తొలగుతుంది. అప్పటిలోగా లాగిన్ అయి ఉంచుకోండి.';
  }

  @override
  String get notifRemindersAndGoalTitle => 'రిమైండర్లు మరియు లక్ష్యం';

  @override
  String get notifStudyReminder => 'చదువు రిమైండర్';

  @override
  String get notifRemindMeToStudy => 'చదవమని గుర్తు చేయి';

  @override
  String get notifTime => 'సమయం';

  @override
  String get notifRemindMeAt => 'ఈ సమయాన గుర్తు చేయి';

  @override
  String get notifAlsoTellMe => 'ఇవి కూడా చెప్పు';

  @override
  String get notifStreakAboutToEnd => 'నా స్ట్రీక్ అయిపోబోతున్నప్పుడు';

  @override
  String get notifEveningBeforeTest => 'టెస్ట్ ముందు సాయంత్రం';

  @override
  String get notifWhenLevelUp => 'నేను లెవల్ పైకి వెళ్లినప్పుడు';

  @override
  String get notifNotifications => 'నోటిఫికేషన్లు';

  @override
  String get notifAllowed => 'అనుమతి ఉంది';

  @override
  String get notifNotAllowed => 'అనుమతి లేదు';

  @override
  String get notifTurnOn => 'నోటిఫికేషన్లు ఆన్ చేయి';

  @override
  String get notifTurnOnInSettings => 'సెట్టింగ్స్‌లో ఆన్ చేయి';

  @override
  String get reminderTimeTitle => 'రిమైండర్ సమయం';

  @override
  String get reminderHour => 'గంట';

  @override
  String get reminderMinute => 'నిమిషం';

  @override
  String get reminderAmPm => 'ఉదయం లేదా సాయంత్రం';

  @override
  String get reminderAm => 'am';

  @override
  String get reminderPm => 'pm';

  @override
  String get dailyGoalTitle => 'రోజువారీ లక్ష్యం';

  @override
  String dailyGoalNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes నిమిషాలు',
      one: '1 నిమిషం',
    );
    return 'హోమ్‌లో నేటి స్టెప్‌లు సుమారు $_temp0 అవుతాయి.';
  }

  @override
  String get dailyGoalSemantics => 'నిమిషాల్లో రోజువారీ లక్ష్యం';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes ని';
  }

  @override
  String get dailyGoalStudyEachDay => 'ప్రతి రోజు చదువు';

  @override
  String get appearanceTheme => 'థీమ్';

  @override
  String get appearanceLight => 'లైట్';

  @override
  String get appearanceDark => 'డార్క్';

  @override
  String get appearanceDarkHint =>
      'రాత్రి డార్క్ మోడ్ కళ్లకు సౌకర్యంగా ఉంటుంది.';

  @override
  String get appearanceLightsOff => 'లైట్లు ఆఫ్…';

  @override
  String get appearanceGoodMorning => 'శుభోదయం!';

  @override
  String get appearanceDimming => 'పెబ్బీ గదిని మసకబారుస్తోంది';

  @override
  String get appearanceOpeningCurtains => 'పెబ్బీ తెరలు తెరుస్తోంది';

  @override
  String get helpTellUs => 'మాకు చెప్పు';

  @override
  String get helpEmailUs => 'మాకు ఇమెయిల్ చేయి';

  @override
  String get helpThanks => 'ధన్యవాదాలు, మీ సందేశం అందింది.';

  @override
  String get feedbackWrongAnswer => 'తప్పు సమాధానం రిపోర్ట్ చేయి';

  @override
  String get feedbackBug => 'ఏదో పనిచేయడం లేదు';

  @override
  String get feedbackFeature => 'ఒక ఫీచర్ సూచించు';

  @override
  String get feedbackHint => 'ఏమైందో చెప్పు (కనీసం 10 అక్షరాలు).';

  @override
  String get feedbackSend => 'పంపు';

  @override
  String get feedbackLimitNote => 'రోజుకు 2, వారానికి 5 సందేశాలు పంపవచ్చు.';

  @override
  String get feedbackFailGeneric => 'పంపలేకపోయాం. మళ్లీ ప్రయత్నించు.';

  @override
  String get feedbackFailDay =>
      'ఈరోజు తీసుకోగలంత ఫీడ్‌బ్యాక్ వచ్చింది. రేపు మళ్లీ ప్రయత్నించు.';

  @override
  String get feedbackFailWeek =>
      'ఈ వారం తీసుకోగలంత ఫీడ్‌బ్యాక్ వచ్చింది. వచ్చే వారం మళ్లీ ప్రయత్నించు.';

  @override
  String get feedbackFailTooShort => 'సహాయం కోసం కనీసం 10 అక్షరాలు రాయి.';

  @override
  String get feedbackFailOffline =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. కనెక్షన్ చూసి మళ్లీ ప్రయత్నించు.';

  @override
  String get privacySummary1 =>
      'ACADEMe నడపడానికి మీ అకౌంట్, క్లాస్, బోర్డు మరియు సబ్జెక్టులు, చదువు ప్రోగ్రెస్ మరియు స్ట్రీక్, ఫోల్డర్లు, నోట్స్ మరియు పెబ్బీ చాట్‌లు ఉంచుతాం.';

  @override
  String get privacySummary2 =>
      'మీ ప్రశ్నలు మరియు స్కాన్ ఫోటోలు భారత్‌లోని Sarvam AIకి వెళ్తాయి — పెబ్బీ సమాధానం ఇవ్వడానికి. ఫోటోలు ఉంచము, వాటి నుంచి చదివిన టెక్స్ట్ మాత్రమే.';

  @override
  String get privacySummary3 =>
      'యాడ్స్ లేవు, యాడ్ ID లేదు, లొకేషన్ లేదు, మీ డేటా అమ్మము.';

  @override
  String get privacySummary4 =>
      'అకౌంట్‌లో ఎప్పుడైనా అకౌంట్ తొలగించవచ్చు. 30 రోజుల తర్వాత అంతా తొలగుతుంది.';

  @override
  String get privacyDocuments => 'డాక్యుమెంట్లు';

  @override
  String get privacyPolicy => 'గోప్యతా విధానం';

  @override
  String get privacyTermsOfUse => 'వినియోగ నిబంధనలు';

  @override
  String get privacyYourData => 'మీ డేటా';

  @override
  String get privacyGetCopy => 'నా డేటా కాపీ ఇవ్వండి';

  @override
  String get privacyGrievanceOfficer => 'ఫిర్యాదు అధికారి';

  @override
  String classBoardSave(int level, String board) {
    return 'సేవ్ · క్లాస్ $level · $board';
  }

  @override
  String get classBoardYourClass => 'మీ క్లాస్';

  @override
  String get classBoardYourBoard => 'మీ బోర్డు';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'మీ సబ్జెక్టులు మరియు ప్లాన్ క్లాస్ $level · $boardకి మారతాయి. ఇప్పటివరకు చేసింది సేవ్‌లోనే ఉంటుంది.';
  }

  @override
  String get classBoardSubjects => 'సబ్జెక్టులు';

  @override
  String get classBoardStream => 'స్ట్రీమ్';

  @override
  String get classBoardAllSubjects => 'అన్ని సబ్జెక్టులు';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'ఇప్పుడు క్లాస్ $level · $board సబ్జెక్టులు కనిపిస్తున్నాయి';
  }

  @override
  String get reminderPrimerTitle => 'టెస్ట్ ముందు ఒక నడ్జ్ పొందండి';

  @override
  String get reminderPrimerPromise1 =>
      'ప్రతి టెస్ట్‌కి 3 రోజుల ముందు, ముందు సాయంత్రం మరియు ఆ ఉదయం గుర్తు';

  @override
  String get reminderPrimerPromise2 =>
      'చదువు రిమైండర్, మీరు ఎంచుకున్న రోజులు మరియు సమయంలో మాత్రమే';

  @override
  String get reminderPrimerPromise3 => 'మరేమీ లేదు. Meలో ఎప్పుడైనా మార్చుకోండి';

  @override
  String get reminderPrimerAllow => 'అనుమతించు';

  @override
  String get paywallWelcomeSnack => 'ACADEMe Proకి స్వాగతం';

  @override
  String get paywallTagline =>
      'రోజు & వారం పరిమితులు 3×. అదే రీఫిల్ గడియారం — చదవడానికి ఎక్కువ స్థలం.';

  @override
  String get paywallOpeningPlay => 'Google Play తెరుస్తోంది…';

  @override
  String get paywallRestoring => 'రీస్టోర్ అవుతోంది…';

  @override
  String get paywallRestore => 'కొనుగోళ్లు రీస్టోర్ చేయి';

  @override
  String get paywallUnavailableTitle => 'ఈ పరికరంలో కొనుగోళ్లు అందుబాటులో లేవు';

  @override
  String get paywallUnavailableBody =>
      'Proకి వెళ్లేందుకు ACADEMeని Google Play నుంచి ఇన్‌స్టాల్ చేసి Playలో సైన్ ఇన్ చేయి.';

  @override
  String get paywallBenefitAskme => 'ప్రతి రోజు 3× ASKMe ప్రశ్నలు';

  @override
  String get paywallBenefitScan => 'ప్రతి రోజు 3× స్కాన్‌లు';

  @override
  String get paywallBenefitCheck => 'ప్రతి రోజు 3× సమాధాన తనిఖీలు';

  @override
  String get paywallBenefitLessons => 'నీ నోట్స్ నుంచి స్వైప్ పాఠాలు';

  @override
  String get paywallBenefitProgress => 'My Progress వారపు సారాంశం';

  @override
  String get paywallMonthly => 'నెలవారీ';

  @override
  String get paywallAnnual => 'వార్షిక';

  @override
  String paywallPlanSemantics(String title) {
    return '$title ప్లాన్';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return 'మొదటి నెల $introPrice, తర్వాత $price/నెల';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/నెల';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/సంవత్సరం';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'సుమారు $monthlyPrice/నెల · 17% ఆదా · ఆటో రిన్యూ';
  }

  @override
  String get paywallDetailAnnual => '17% ఆదా · ఆటో రిన్యూ';

  @override
  String get paywallDetailRenews => 'ఆటోమేటిక్‌గా రిన్యూ అవుతుంది';

  @override
  String get paywallBestValue => 'ఉత్తమ విలువ';

  @override
  String get paywallSmallPrint =>
      'ఆటో రిన్యూ. Google Playలో ఎప్పుడైనా రద్దు చేయి.';

  @override
  String get paywallTerms => 'నిబంధనలు';

  @override
  String get paywallPrivacy => 'గోప్యత';

  @override
  String get upgradeTitle => 'Pro తీసుకో · 3× పరిమితులు';

  @override
  String get limitAskmeTitle => 'ఈ రోజు ఉచిత ప్రశ్నలు అయిపోయాయి';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ASKMe ప్రశ్నలు',
      one: '1 ASKMe ప్రశ్న',
    );
    return 'ఫ్రీలో రోజుకు $_temp0. Pro ప్రతి రోజు 3× ఇస్తుంది.';
  }

  @override
  String get limitScanTitle => 'ఈ రోజు ఉచిత స్కాన్‌లు అయిపోయాయి';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count స్కాన్‌లు',
      one: '1 స్కాన్',
    );
    return 'ఫ్రీలో రోజుకు $_temp0. Pro ప్రతి రోజు 3× ఇస్తుంది.';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈ రోజు ఉచిత తనిఖీలు అయిపోయాయి',
      one: 'ఈ రోజు ఉచిత తనిఖీ అయిపోయింది',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count సమాధాన తనిఖీలు',
      one: 'ఒక సమాధాన తనిఖీ',
    );
    return 'ఫ్రీలో రోజుకు $_temp0. Pro ప్రతి రోజు 3× ఇస్తుంది.';
  }

  @override
  String get limitLessonsTitle => 'నోట్స్ నుంచి పాఠాలు Proలో ఉన్నాయి';

  @override
  String get limitLessonsBody =>
      'నోట్స్ ఉంచడం ఉచితం. Proతో పెబ్బీ వాటిని క్విజ్‌లతో స్వైప్ పాఠాలుగా మారుస్తుంది.';

  @override
  String get limitMaybeLater => 'తర్వాత చూద్దాం';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'ప్లాన్ & పరిమితులు';

  @override
  String get proCardSubtitleFree => 'ప్లాన్ & పరిమితులు · Proతో 3×';

  @override
  String get proCardSubtitleMonthly => 'Pro · నెలవారీ';

  @override
  String get proCardSubtitleAnnual => 'Pro · వార్షిక';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'నిర్వహించు';

  @override
  String get proOnPro => 'నువ్వు Proలో ఉన్నావు';

  @override
  String get proOnFree => 'నువ్వు ఫ్రీలో ఉన్నావు';

  @override
  String get proMetaFree => 'రోజు & వారం పరిమితులు · 12:00 AM IST';

  @override
  String get proMetaBillingIssue =>
      'Pro ఉంచేందుకు Google Playలో చెల్లింపు సరిచేయి';

  @override
  String get proMetaActiveNoExpiry =>
      '3× రోజువారీ పరిమితులు · వారపు సేఫ్టీ క్యాప్';

  @override
  String proMetaAnnualRenews(String date) {
    return 'వార్షిక · $dateన రిన్యూ · 3× పరిమితులు';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'నెలవారీ · $dateన రిన్యూ · 3× పరిమితులు';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro $dateన ముగుస్తుంది';
  }

  @override
  String get proStatusActive => 'యాక్టివ్';

  @override
  String get proStatusFree => 'ఫ్రీ';

  @override
  String get proDailyLimits => 'రోజువారీ పరిమితులు';

  @override
  String get proResetsDaily => 'ప్రతి రోజు 12:00 AM ISTకి రీసెట్';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'Scan';

  @override
  String get proFeatureCheck => 'Check';

  @override
  String get proFeatureLessons => 'పాఠాలు';

  @override
  String get proWeeklyLimit => 'వారపు పరిమితి';

  @override
  String get proResetsMondays => 'సోమవారాలు రీసెట్ · 12:00 AM IST';

  @override
  String proResetsOnDay(String day) {
    return '$dayన రీసెట్ · 12:00 AM IST';
  }

  @override
  String get proAllFeatures => 'అన్ని ఫీచర్లు';

  @override
  String get proManageInPlay => 'Google Playలో నిర్వహించు';

  @override
  String get proResetsSoon => 'త్వరలో';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count గంటల్లో',
      one: '1 గంటలో',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'నీ చెల్లింపు పెండింగ్‌లో ఉంది. Google Play నిర్ధారించగానే Pro ఆన్ అవుతుంది.';

  @override
  String get proNoticeNoPurchase =>
      'ఈ Google అకౌంట్‌లో ACADEMe Pro కొనుగోలు కనబడలేదు.';

  @override
  String get proNoticeNotAllowed =>
      'ఈ Google అకౌంట్‌కు కొనుగోళ్లు ఆఫ్ ఉన్నాయి.';

  @override
  String get proNoticeAlreadyOwned =>
      'ఈ Google అకౌంట్‌కు ఇప్పటికే Pro ఉంది. కొనుగోళ్లు రీస్టోర్ చేయి నొక్కు.';

  @override
  String get proNoticeUnavailable => 'ఈ పరికరంలో కొనుగోళ్లు అందుబాటులో లేవు.';

  @override
  String get proNoticeStoreError =>
      'Google Play పూర్తి చేయలేకపోయింది. మళ్లీ ప్రయత్నించు.';

  @override
  String get askmeNewChat => 'కొత్త చాట్';

  @override
  String askmeStudying(String name) {
    return 'ఏమి చదువుతున్నాం, $name?';
  }

  @override
  String get askmeModeExplainLine => 'పెబ్బీ సింపుల్‌గా, అడుగడుగునా చెబుతుంది.';

  @override
  String get askmeModeSolveLine =>
      'పెబ్బీ హింట్స్ ఇస్తుంది. నువ్వు సాల్వ్ చేస్తావు.';

  @override
  String get askmeModeQuizLine =>
      'పెబ్బీ అడుగుతుంది, నువ్వు సమాధానం ఇస్తావు, XP వస్తుంది.';

  @override
  String get askmeSuggestExplain1 => 'ప్రకాశ పరావర్తనాన్ని సింపుల్‌గా చెప్పు';

  @override
  String get askmeSuggestExplain2 => 'ఆకాశం నీలంగా ఎందుకుంది?';

  @override
  String get askmeSuggestExplain3 => 'ఫోటోసింతసిస్ అంటే ఏమిటి?';

  @override
  String get askmeSuggestSolve1 =>
      '2x + 3y = 11 మరియు x − 2y = −12 సాల్వ్ చేయడంలో సహాయం చెయ్యి';

  @override
  String get askmeSuggestSolve2 => 'r = 7 cm వృత్తం వైశాల్యం కనుక్కో';

  @override
  String get askmeSuggestSolve3 => 'H₂ + O₂ → H₂O బ్యాలెన్స్ చెయ్యి';

  @override
  String get askmeSuggestQuiz1 => 'Light మీద క్విజ్ ఇవ్వు';

  @override
  String get askmeSuggestQuiz2 => 'లీనియర్ ఈక్వేషన్స్ మీద 5 ప్రశ్నలు ఇవ్వు';

  @override
  String get askmeSuggestQuiz3 => 'French Revolution మీద క్విజ్ ఇవ్వు';

  @override
  String get askmeModeExplain => 'వివరించు';

  @override
  String get askmeModeSolve => 'సాల్వ్';

  @override
  String get askmeModeQuiz => 'క్విజ్';

  @override
  String get askmeFollowNextStep => 'తర్వాతి అడుగు';

  @override
  String get askmeFollowFullSolution => 'పూర్తి సమాధానం';

  @override
  String get askmeFollowNextQuestion => 'తర్వాతి ప్రశ్న';

  @override
  String get askmeFollowQuizMe => 'క్విజ్';

  @override
  String get askmeFollowGoDeeper => 'మరింత లోతుగా';

  @override
  String get askmeSendNextStep => 'తర్వాతి అడుగు చెప్పు.';

  @override
  String get askmeSendFullSolution => 'పూర్తి సమాధానం చూపించు.';

  @override
  String get askmeSendNextQuestion => 'తర్వాతి ప్రశ్న.';

  @override
  String get askmeSendGoDeeper => 'మరింత లోతుగా చెప్పు.';

  @override
  String get askmeSendQuizMe => 'దీనిపై క్విజ్ ఇవ్వు.';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe ఇంకా రెడీ కాలేదు. పెబ్బీ త్వరలో వస్తుంది.';

  @override
  String get askmeFailureSignedOut =>
      'నువ్వు లాగ్ అవుట్ అయ్యావు. మళ్లీ లాగ్ ఇన్ అవ్వు.';

  @override
  String get askmeFailureLimitReached =>
      'ఈరోజు ఉచిత ప్రశ్నలు అయిపోయాయి. అర్ధరాత్రి తిరిగి వస్తాయి.';

  @override
  String get askmeThinking => 'పెబ్బీ ఆలోచిస్తోంది';

  @override
  String get historyTitle => 'హిస్టరీ';

  @override
  String get historySearchHint => 'నీ ప్రశ్నలు సెర్చ్ చెయ్యి';

  @override
  String get historyLoadError => 'చాట్స్ లోడ్ కాలేదు. మళ్లీ ప్రయత్నించు';

  @override
  String get historyEmpty => 'పెబ్బీకి అడిగిన ప్రశ్నలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get historyThisWeek => 'ఈ వారం';

  @override
  String get historyEarlier => 'ముందు';

  @override
  String get historyNow => 'ఇప్పుడు';

  @override
  String historyHoursAgo(int hours) {
    return '$hoursగం';
  }

  @override
  String get historyWeekdayMon => 'సోమ';

  @override
  String get historyWeekdayTue => 'మం';

  @override
  String get historyWeekdayWed => 'బుధ';

  @override
  String get historyWeekdayThu => 'గురు';

  @override
  String get historyWeekdayFri => 'శుక్ర';

  @override
  String get historyWeekdaySat => 'శని';

  @override
  String get historyWeekdaySun => 'ఆది';

  @override
  String get historyMonthJan => 'జన';

  @override
  String get historyMonthFeb => 'ఫిబ్ర';

  @override
  String get historyMonthMar => 'మార్చి';

  @override
  String get historyMonthApr => 'ఏప్రి';

  @override
  String get historyMonthMay => 'మే';

  @override
  String get historyMonthJun => 'జూన్';

  @override
  String get historyMonthJul => 'జూలై';

  @override
  String get historyMonthAug => 'ఆగ';

  @override
  String get historyMonthSep => 'సెప్టె';

  @override
  String get historyMonthOct => 'అక్టో';

  @override
  String get historyMonthNov => 'నవం';

  @override
  String get historyMonthDec => 'డిసె';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'నీ ప్రశ్నకు జోడించు';

  @override
  String get attachCamera => 'కెమెరా';

  @override
  String get attachPhotos => 'ఫోటోలు';

  @override
  String get replyHelpful => 'ఉపయోగకరం';

  @override
  String get replyNotHelpful => 'ఉపయోగం లేదు';

  @override
  String get replyCopy => 'కాపీ';

  @override
  String get replyCopied => 'కాపీ అయింది';

  @override
  String get replyReportTitle => 'ఈ సమాధానాన్ని రిపోర్ట్ చెయ్యి';

  @override
  String get replyReportThanks => 'థాంక్స్. ఈ సమాధానాన్ని చూస్తాం.';

  @override
  String get reportTooltip => 'రిపోర్ట్';

  @override
  String get reportSendFailed => 'రిపోర్ట్ పంపలేకపోయాం. మళ్లీ ప్రయత్నించు.';

  @override
  String get reportBody =>
      'పెబ్బీని మరింత సేఫ్‌గా చేయడానికి ప్రతి రిపోర్ట్ చదువుతాం.';

  @override
  String get reportReasonWrong => 'ఇది తప్పు';

  @override
  String get reportReasonHarmful => 'ఇది హానికరం లేదా అసురక్షితం';

  @override
  String get reportReasonOffensive => 'ఇది అసభ్యం లేదా అభ్యంతరకరం';

  @override
  String get reportReasonOther => 'వేరేది';

  @override
  String get progressTitle => 'నా ప్రోగ్రెస్';

  @override
  String get progressLoading => 'ఈ వారం లోడ్ అవుతోంది…';

  @override
  String get progressLoadError => 'ఈ వారం సారాంశం లోడ్ కాలేదు.';

  @override
  String get progressHoldTitle => 'నా ప్రోగ్రెస్ Proలో భాగం';

  @override
  String get progressHoldBody =>
      'ACADEMe Proతో స్ట్రీక్, లెవెల్, స్టడీ ఇన్‌సైట్స్ చూడు.';

  @override
  String get progressGoProLimits => 'Go Pro · 3× లిమిట్స్';

  @override
  String get progressStudyDays => 'స్టడీ డేస్';

  @override
  String get progressThisWeek => 'ఈ వారం';

  @override
  String get progressTodayStudied => 'ఈరోజు · చదివావు';

  @override
  String get progressTodayNotYet => 'ఈరోజు · ఇంకా లేదు';

  @override
  String get progressTabSummary => 'సారాంశం';

  @override
  String get progressTabProgress => 'ప్రోగ్రెస్';

  @override
  String get progressTabActivity => 'యాక్టివిటీ';

  @override
  String get progressSubjectsThisWeek => 'ఈ వారం సబ్జెక్టులు';

  @override
  String get progressCompleted => 'పూర్తి';

  @override
  String get progressOverallGrade => 'మొత్తం గ్రేడ్';

  @override
  String get progressKeepItUp => 'ఇలాగే కొనసాగించు';

  @override
  String get progressStartJourney => 'నీ ప్రయాణం మొదలుపెట్టు';

  @override
  String get progressCourseProgress => 'కోర్సు ప్రోగ్రెస్';

  @override
  String get progressLessonsEmpty =>
      'నువ్వు పూర్తి చేసిన పాఠాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'యాక్టివిటీ';

  @override
  String get progressStudyDaysEmpty => 'నీ స్టడీ డేస్ ఇక్కడ కనిపిస్తాయి.';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈ వారం $count యాక్టివ్ రోజులు.',
      one: 'ఈ వారం 1 యాక్టివ్ రోజు.',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'నీ ప్రయాణం మొదలుపెట్టే సమయం!';

  @override
  String get progressCtaMomentum => 'నీ మొమెంటం కొనసాగించు';

  @override
  String get progressCtaHabit => 'నువ్వు అలవాటు తయారు చేసుకుంటున్నావు';

  @override
  String get progressCtaNext => 'తర్వాత ఏమి చేయాలో చూడు';

  @override
  String get progressNextSteps => 'తర్వాతి అడుగులు';

  @override
  String get progressYourSetup => 'నీ సెటప్';

  @override
  String get progressWhatNext => 'తర్వాత ఏమి చేయాలి';

  @override
  String get progressNextWithStudy =>
      'ఈ వారం పాఠాలు పూర్తి చేస్తూ ఉండు. పూర్తయ్యాక గ్రేడ్ అప్‌డేట్ అవుతుంది.';

  @override
  String get progressNextNoStudy =>
      'Meలో క్లాస్, బోర్డ్ కన్ఫర్మ్ చెయ్యి. తర్వాత Study తెరిచి మొదటి పాఠం పూర్తి చెయ్యి.';

  @override
  String get progressWeekEmpty => 'ఈ వారం ఇంకా స్టడీ లాగ్ కాలేదు.';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count యాక్టివ్ రోజులు',
      one: '1 యాక్టివ్ రోజు',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count చాప్టర్ టెస్టులు',
      one: '1 చాప్టర్ టెస్ట్',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'ఈ వారం: $parts.';
  }

  @override
  String get progressWeekdayMon => 'సో';

  @override
  String get progressWeekdayTue => 'మం';

  @override
  String get progressWeekdayWed => 'బు';

  @override
  String get progressWeekdayThu => 'గు';

  @override
  String get progressWeekdayFri => 'శు';

  @override
  String get progressWeekdaySat => 'శ';

  @override
  String get progressWeekdaySun => 'ఆ';

  @override
  String get subjectsStreamTitle => 'నీ స్ట్రీమ్';

  @override
  String get subjectsSave => 'సేవ్';

  @override
  String get subjectsLoadError => 'సబ్జెక్టులు లోడ్ కాలేదు. మళ్లీ ప్రయత్నించు';

  @override
  String get subjectsMain => 'మెయిన్';

  @override
  String get subjectsOptional => 'ఆప్షనల్';

  @override
  String streamSwipeFor(String name) {
    return '$name కోసం స్వైప్ చెయ్యి. Meలో ఎప్పుడైనా మార్చవచ్చు.';
  }

  @override
  String get streamChangeInMe => 'Meలో ఎప్పుడైనా మార్చవచ్చు.';

  @override
  String streamChoose(String name) {
    return '$name ఎంచుకో';
  }

  @override
  String get classDialLabel => 'క్లాస్';

  @override
  String classDialSemantics(int level) {
    return 'క్లాస్ $level';
  }

  @override
  String get studyTitle => 'చదువు';

  @override
  String get studyCourses => 'కోర్సులు';

  @override
  String get studyFolders => 'ఫోల్డర్లు';

  @override
  String get studyDone => 'అయింది';

  @override
  String get studyKeep => 'ఉంచు';

  @override
  String get studyDelete => 'తొలగించు';

  @override
  String get studySave => 'సేవ్';

  @override
  String get studyCreate => 'సృష్టించు';

  @override
  String get studyAdd => 'జోడించు';

  @override
  String get studyOptional => 'ఐచ్ఛికం';

  @override
  String get studyName => 'పేరు';

  @override
  String get studyToday => 'ఈరోజు';

  @override
  String get studyComingSoon => 'త్వరలో వస్తుంది';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'అధ్యాయం $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$_temp0లో $done పూర్తి';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count త్వరలో',
      one: '1 త్వరలో',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'బోర్డు పరీక్షలో లేదు';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count కార్డులు',
      one: '1 కార్డు',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count క్విక్ చెక్స్',
      one: '1 క్విక్ చెక్',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు',
      one: '1 ప్రశ్న',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అధ్యాయాలు',
      one: '1 అధ్యాయం',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes నిమి';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'సుమారు $minutes నిమి';
  }

  @override
  String get coursesNeedSyllabus =>
      'కోర్సులు చూడటానికి హోమ్‌లో క్లాస్, బోర్డు సెట్ చేయి.';

  @override
  String get coursesLoadError => 'కోర్సులు లోడ్ కాలేదు. మళ్లీ ప్రయత్నించు';

  @override
  String coursesComingSoon(String syllabus) {
    return '$syllabus పాఠాలు వస్తున్నాయి. అప్పటిదాకా ASKMeలో పెబ్బీని అడుగు.';
  }

  @override
  String get coursesNoFilterMatch => 'ఈ ఫిల్టర్లకు అధ్యాయాలు లేవు.';

  @override
  String get coursesFinishedEmpty => 'పూర్తైన అధ్యాయాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get coursesStartedEmpty => 'మొదలుపెట్టిన అధ్యాయాలు ఇక్కడ కనిపిస్తాయి.';

  @override
  String get coursesGoAgain => 'మళ్లీ చేయి';

  @override
  String coursesContinueCard(int current, int total) {
    return 'కొనసాగించు · కార్డు $current / $total';
  }

  @override
  String get coursesStart => 'మొదలుపెట్టు';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get filterInProgress => 'జరుగుతోంది';

  @override
  String get filterDone => 'అయింది';

  @override
  String get filterFilters => 'ఫిల్టర్లు';

  @override
  String filterFiltersOn(int count) {
    return 'ఫిల్టర్లు, $count ఆన్';
  }

  @override
  String get filterClear => 'క్లియర్';

  @override
  String get filterSort => 'సార్ట్';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అధ్యాయాలు',
      one: '1 అధ్యాయం',
    );
    return '$_temp0 చూపు';
  }

  @override
  String get filterBoardExamOnly => 'బోర్డు పరీక్ష మాత్రమే';

  @override
  String get filterBoardExamOnlyDesc => 'స్కూల్-అసెస్డ్ అధ్యాయాలు దాచు';

  @override
  String get filterReadyToStudy => 'చదవడానికి సిద్ధం';

  @override
  String get filterReadyToStudyDesc => 'త్వరలో వచ్చే అధ్యాయాలు దాచు';

  @override
  String get filterRevisionDue => 'రివిజన్ బాకీ';

  @override
  String get filterRevisionDueDesc =>
      'ఉంచిన కార్డులు రివైజ్ చేయాల్సిన అధ్యాయాలు';

  @override
  String get filterSortTextbook => 'పుస్తకం';

  @override
  String get filterSortMostMarks => 'ఎక్కువ మార్కులు';

  @override
  String get filterSortRecent => 'ఇటీవల';

  @override
  String get filterFlagBoardExam => 'బోర్డు పరీక్ష';

  @override
  String get filterFlagReady => 'సిద్ధం';

  @override
  String get filterFlagRevisionDue => 'రివిజన్ బాకీ';

  @override
  String filterRemove(String label) {
    return '$label తీసేయి';
  }

  @override
  String get folderNew => 'కొత్త ఫోల్డర్';

  @override
  String get folderEdit => 'ఫోల్డర్ ఎడిట్';

  @override
  String get folderEmptyHint =>
      'టెస్టు, హోమ్‌వర్క్ లేదా ఏదైనా సిద్ధం కోసం ఫోల్డర్ చేయి. తేదీ పెడితే రోజులు ప్లాన్ అవుతాయి.';

  @override
  String get folderEmpty => 'ఖాళీ';

  @override
  String get folderNothingLeftToday => 'ఈరోజు ఏమీ మిగల్లేదు';

  @override
  String folderTodoToday(int count) {
    return 'ఈరోజు $count చేయాలి';
  }

  @override
  String get folderNoDate => 'తేదీ లేదు';

  @override
  String folderPercentReady(int percent) {
    return '$percent% సిద్ధం';
  }

  @override
  String get folderWhatsFor => 'ఈ ఫోల్డర్ దేనికి?';

  @override
  String get folderAddChaptersPlan =>
      'అధ్యాయాలు జోడిస్తే పెబ్బీ రోజులు ప్లాన్ చేస్తుంది.';

  @override
  String get folderAddChapters => 'అధ్యాయాలు జోడించు';

  @override
  String get folderFromSyllabus => 'నీ సిలబస్ నుండి';

  @override
  String get folderWriteNote => 'నోట్ రాయి';

  @override
  String get folderNoteSubtitle => 'గుర్తుంచుకోవాల్సింది ఏదైనా';

  @override
  String get folderScanNotes => 'నోట్స్ స్కాన్ చేయి';

  @override
  String get folderScanNotesSubtitle => 'పేజీల ఫోటోలు, పాఠం అవుతాయి';

  @override
  String get folderAddTodo => 'టు-డూ జోడించు';

  @override
  String get folderAddDate => 'తేదీ జోడించు';

  @override
  String get folderRemoveDate => 'తేదీ తీసేయి';

  @override
  String get folderReminders => 'ఈ ఫోల్డర్ రిమైండర్లు';

  @override
  String get folderDeleteTitle => 'ఈ ఫోల్డర్ తొలగించాలా?';

  @override
  String get folderDeleteBody =>
      'నోట్స్, టు-డూలు కూడా పోతాయి. పాఠాలు, ప్రోగ్రెస్ ఉంటాయి.';

  @override
  String get folderTitle => 'ఫోల్డర్';

  @override
  String get folderEditRemindersTooltip => 'ఎడిట్ మరియు రిమైండర్లు';

  @override
  String get folderDeleteTooltip => 'ఫోల్డర్ తొలగించు';

  @override
  String get folderLoadError => 'ఫోల్డర్ లోడ్ కాలేదు. మళ్లీ ప్రయత్నించు';

  @override
  String folderTodayMinutes(int minutes) {
    return 'ఈరోజు · $minutes నిమి';
  }

  @override
  String get folderSeePlan => 'ప్లాన్ చూడు';

  @override
  String get folderAddChaptersOrTodos => 'అధ్యాయాలు లేదా టు-డూలు జోడించు.';

  @override
  String get folderNothingLeftForToday => 'ఈరోజుకు ఏమీ మిగల్లేదు.';

  @override
  String get folderInThisFolder => 'ఈ ఫోల్డర్‌లో';

  @override
  String get folderFromNotesDone => 'నీ నోట్స్ నుండి · అయింది';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'నీ నోట్స్ నుండి · $minutes నిమి';
  }

  @override
  String get folderNote => 'నోట్';

  @override
  String get folderSaveNote => 'నోట్ సేవ్ చేయి';

  @override
  String get folderTypeHere => 'ఇక్కడ రాయి…';

  @override
  String get folderAddTo => 'ఫోల్డర్‌కు జోడించు';

  @override
  String get folderCouldntMake => 'ఫోల్డర్ కాలేదు. మళ్లీ ప్రయత్నించు.';

  @override
  String folderAddedTo(String name) {
    return '$nameకు జోడించాం';
  }

  @override
  String get folderYourFolder => 'నీ ఫోల్డర్';

  @override
  String get folderPlan => 'ప్లాన్';

  @override
  String folderPlanTo(String date) {
    return '$date వరకు ప్లాన్';
  }

  @override
  String get folderPlanBody =>
      'ఈ ఫోల్డర్ అధ్యాయాల నుండి తయారు. ఏదైనా మిస్ అయితే తదుపరి రోజుకు వెళ్తుంది.';

  @override
  String get folderTestDay => 'టెస్టు రోజు · నువ్వు సిద్ధం';

  @override
  String get folderRestDay => 'విశ్రాంతి రోజు';

  @override
  String get folderDueTomorrow => 'రేపు';

  @override
  String get folderDueYesterday => 'నిన్న';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల',
      one: '1 రోజు',
    );
    return '$_temp0 క్రితం';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count రోజుల',
      one: '1 రోజు',
    );
    return '$_temp0లో';
  }

  @override
  String chapterTitle(int number) {
    return 'అధ్యాయం $number';
  }

  @override
  String get chapterLessons => 'పాఠాలు';

  @override
  String get chapterTest => 'అధ్యాయం టెస్టు';

  @override
  String chapterTestLast(int correct, int total) {
    return 'గతసారి $correct/$total · మళ్లీ ప్రయత్నించు';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ప్రశ్నలు',
      one: '1 ప్రశ్న',
    );
    return 'ప్రతి పాఠం నుండి $_temp0';
  }

  @override
  String get chapterKeptCards => 'ఉంచిన కార్డులు';

  @override
  String get chapterKeptEmpty =>
      'ఏ కార్డుపైనా Keep నొక్కితే ఇక్కడ సేవ్ అవుతుంది';

  @override
  String chapterKeptCount(int count) {
    return '$count రివైజ్ చేయాలి';
  }

  @override
  String get chapterAllDoneGoAgain => 'అన్ని పాఠాలు పూర్తి · మళ్లీ';

  @override
  String chapterResumeCard(int current, int total) {
    return 'కొనసాగించు · కార్డు $current / $total';
  }

  @override
  String get chapterNextLesson => 'తదుపరి పాఠం';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'పాఠం $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes సరైనవి';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'త్వరలో · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'పాఠాలు పూర్తి · ఇప్పుడు టెస్టు';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'అయింది · టెస్టు $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return ' · $count త్వరలో';
  }

  @override
  String get chapterNotInBoardExamSuffix => ' · బోర్డు పరీక్షలో లేదు';

  @override
  String get chapterReportGreat => 'బాగా చేశావ్';

  @override
  String get chapterReportGood => 'బాగానే వెళ్తోంది';

  @override
  String get chapterReportRetry => 'మళ్లీ ప్రయత్నించు';

  @override
  String get chapterReportByLesson => 'పాఠం వారీగా';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'మిస్ అయినవి రివైజ్ చేయి';

  @override
  String get chapterAddToFolderAction => 'అధ్యాయాన్ని ఫోల్డర్‌కు జోడించు';

  @override
  String get chapterBackToChapter => 'అధ్యాయానికి తిరిగి';

  @override
  String get chapterNoChaptersYet => 'నీ క్లాస్‌కు అధ్యాయాలు ఇంకా లేవు.';

  @override
  String get chapterAlreadyInFolder => 'ఇప్పటికే ఈ ఫోల్డర్‌లో ఉంది';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done పూర్తి';
  }

  @override
  String get chapterPickChapters => 'అధ్యాయాలు ఎంచు';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count అధ్యాయాలు',
      one: '1 అధ్యాయం',
    );
    return '$_temp0 జోడించు';
  }

  @override
  String get chapterAddChaptersTitle => 'అధ్యాయాలు జోడించు';

  @override
  String get deckReportTitle => 'ఈ పాఠాన్ని రిపోర్ట్ చేయి';

  @override
  String get deckReportThanks => 'ధన్యవాదాలు. ఈ పాఠాన్ని చూస్తాం.';

  @override
  String get deckLoadError => 'పాఠం లోడ్ కాలేదు. మళ్లీ ప్రయత్నించు';

  @override
  String get deckPerfect => 'పర్ఫెక్ట్ పాఠం!';

  @override
  String get deckLessonDone => 'పాఠం అయింది!';

  @override
  String get deckStatRight => 'సరైనవి';

  @override
  String get deckStatKept => 'ఉంచినవి';

  @override
  String deckNextTitle(String title) {
    return 'తదుపరి: $title';
  }

  @override
  String get deckStart => 'మొదలుపెట్టు';

  @override
  String deckShowStep(int step) {
    return 'స్టెప్ $step చూపు';
  }

  @override
  String get deckCheck => 'చెక్';

  @override
  String get deckNext => 'తదుపరి';

  @override
  String get deckFinish => 'ముగించు';

  @override
  String get deckPreviousCard => 'మునుపటి కార్డు';

  @override
  String get deckNewLesson => 'కొత్త పాఠం';

  @override
  String get deckByTheEnd => 'చివరికి నువ్వు చేయగలవు:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · సుమారు $minutes నిమి';
  }

  @override
  String get deckConcept => 'కాన్సెప్ట్';

  @override
  String get deckInOneLook => 'ఒక చూపులో';

  @override
  String get deckSummary => 'సారాంశం';

  @override
  String get deckThreeLines => 'పాఠం మూడు లైన్లలో';

  @override
  String get deckKeptForRevision => 'రివిజన్ కోసం ఉంచాం';

  @override
  String get deckKeptRevisionOne =>
      'ఈ పాఠం నుండి 1 కార్డు రివిజన్‌లో తిరిగి వస్తుంది.';

  @override
  String deckKeptRevisionMany(int count) {
    return 'ఈ పాఠం నుండి $count కార్డులు రివిజన్‌లో తిరిగి వస్తాయి.';
  }

  @override
  String get deckWorkedExample => 'సాల్వ్డ్ ఉదాహరణ';

  @override
  String deckStepTryFirst(int step) {
    return 'స్టెప్ $step · ముందు నువ్వే ప్రయత్నించు';
  }

  @override
  String get deckRemember => 'గుర్తుంచుకో';

  @override
  String get deckKept => 'ఉంచాం';

  @override
  String get deckAskPebby => 'పెబ్బీని అడుగు';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'దీన్ని మరింత సింపుల్‌గా చెప్పు? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return '\"$title\"ను ఉదాహరణతో చెప్పు?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'ఇది ఎలా సాల్వ్ చేయాలో చెప్పు: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'ఇది తప్పు అయింది: $question సరైనది ఎందుకు: $why';
  }

  @override
  String get deckAskExplainLesson => 'ఈ పాఠం చెప్పు?';

  @override
  String get deckGoals => 'లక్ష్యాలు';

  @override
  String get quizQuickCheck => 'క్విక్ చెక్';

  @override
  String quizQuestionOf(int current, int total) {
    return 'ప్రశ్న $current / $total';
  }

  @override
  String get quizPraise1 => 'బాగుంది! సరైనది.';

  @override
  String get quizPraise2 => 'అద్భుతం!';

  @override
  String get quizPraise3 => 'దొరికింది!';

  @override
  String get quizPraise4 => 'సరైనది, బాగా చేశావ్!';

  @override
  String get quizPraise5 => 'ఖచ్చితంగా సరైనది!';

  @override
  String get quizHeresWhy => 'ఎందుకంటే';

  @override
  String get quizYourAnswer => 'నీ సమాధానం';

  @override
  String get quizRightAnswer => 'సరైన సమాధానం';

  @override
  String get quizKeptForYou => 'నీ కోసం ఉంచాం';

  @override
  String get quizComesBack => 'ఈ ప్రశ్న రేపు రివిజన్‌లో తిరిగి వస్తుంది.';

  @override
  String get quizNotQuite => 'సరిగా లేదు. తర్వాత: ఎందుకు.';

  @override
  String quizStreak(int count) {
    return '$count వరుసగా';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'రివిజన్';

  @override
  String get studyRevisionEmptyTitle => 'రివైజ్ చేసేది ఏమీ లేదు';

  @override
  String get studyRevisionEmptyBody =>
      'పాఠంలో కార్డులు Keep చేయి, లేదా ప్రశ్న తప్పు అయితే ఇక్కడ వస్తాయి.';

  @override
  String get studyRevisionDone => 'రివిజన్ అయింది';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew తెలుసు · $almost దాదాపు · $again రేపు మళ్లీ';
  }

  @override
  String get studyRevisionHint =>
      'సమాధానం ఆలోచించు, చెక్ చేయడానికి ట్యాప్ చేయి.';

  @override
  String get studyRevisionShowAnswer => 'సమాధానం చూపు';

  @override
  String get studyRevisionAgain => 'తెలియలేదు';

  @override
  String get studyRevisionAlmost => 'దాదాపు';

  @override
  String get studyRevisionKnew => 'తెలుసు';

  @override
  String chapterTestDeckTitle(int number) {
    return 'అధ్యాయం $number టెస్టు';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count పాఠాలు',
      one: '1 పాఠం',
    );
    return '$_temp0లో $done';
  }

  @override
  String get actionTryAgain => 'మళ్లీ ప్రయత్నించు';

  @override
  String get actionGoPro => 'Pro తీసుకో';

  @override
  String get actionBack => 'వెనక్కి';

  @override
  String get actionClose => 'మూసేయి';

  @override
  String get failureNetwork =>
      'కనెక్షన్ లేదు. ఇంటర్నెట్ చూసి మళ్లీ ప్రయత్నించు.';

  @override
  String get failureUnknown => 'ఏదో తప్పు జరిగింది. మళ్లీ ప్రయత్నించు.';
}
