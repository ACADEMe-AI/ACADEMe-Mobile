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

  @override
  String get welcomeHeadlineLead => 'ஸ்மார்ட்டாக\nபடியுங்கள்.';

  @override
  String get welcomeHeadlineAccent => 'நீண்டதல்ல.';

  @override
  String get welcomeBody =>
      'நீங்கள் உண்மையில் படிக்கும்வற்றிலிருந்து குறிப்புகள், வினாடி வினா மற்றும் ஃபிளாஷ் கார்டுகள்.';

  @override
  String get welcomeGetStarted => 'தொடங்கு';

  @override
  String get welcomeAlreadyHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get welcomeNewUser => 'புதியவரா? ';

  @override
  String get welcomeLegal =>
      'தொடர்வதன் மூலம் எங்கள் விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்.';

  @override
  String get authSignUp => 'சைன் அப்';

  @override
  String get authLogIn => 'லாக் இன்';

  @override
  String get authContinueGoogle => 'Google மூலம் தொடரவும்';

  @override
  String get authContinueApple => 'Apple மூலம் தொடரவும்';

  @override
  String get authContinueEmail => 'மின்னஞ்சல் மூலம் தொடரவும்';

  @override
  String get loginHeadlineLead => 'மீண்டும்';

  @override
  String get loginHeadlineAccent => 'வரவேற்பு.';

  @override
  String get loginSubtitle => 'நிறுத்திய இடத்திலிருந்து தொடருங்கள்.';

  @override
  String get authEmail => 'மின்னஞ்சல்';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authShowPassword => 'கடவுச்சொல்லைக் காட்டு';

  @override
  String get authHidePassword => 'கடவுச்சொல்லை மறை';

  @override
  String get authForgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get authLoggingIn => 'உள்நுழைகிறது…';

  @override
  String get authNewHere => 'புதியவரா? ';

  @override
  String get forgotPasswordLead => 'கடவுச்சொல்';

  @override
  String get forgotPasswordAccent => 'மறந்துவிட்டதா?';

  @override
  String get forgotPasswordSubtitle =>
      'உங்கள் மின்னஞ்சலைத் தட்டச்சு செய்யுங்கள், 6 இலக்கக் குறியீடு அனுப்புவேன்.';

  @override
  String get authSending => 'அனுப்புகிறது…';

  @override
  String get authSendCode => 'குறியீடு அனுப்பு';

  @override
  String get resetCodeLead => 'உங்கள்';

  @override
  String get resetCodeAccent => 'மின்னஞ்சலைப் பாருங்கள்.';

  @override
  String resetCodeSubtitle(String email) {
    return '$emailக்கு ACADEMe கணக்கு இருந்தால், 6 இலக்கக் குறியீடு வருகிறது. இது 15 நிமிடங்களில் காலாவதியாகும்.';
  }

  @override
  String get authPasteCode => 'குறியீட்டை ஒட்டு';

  @override
  String get authChecking => 'சரிபார்க்கிறது…';

  @override
  String get authVerify => 'சரிபார்';

  @override
  String get resetDidntGetIt => 'வரவில்லையா? ';

  @override
  String get resetSendNewCode => 'புதிய குறியீடு அனுப்பு';

  @override
  String get resetSendingNewCode => 'புதிய குறியீடு அனுப்புகிறது…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'புதிய குறியீடு அனுப்பப்பட்டது. மீண்டும் கேட்கலாம் 0:$seconds-இல்';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'புதிய குறியீடு 0:$seconds-இல் கேட்கலாம்';
  }

  @override
  String get newPasswordLead => 'புதிய';

  @override
  String get newPasswordAccent => 'கடவுச்சொல்லைத் தேர்ந்தெடுங்கள்.';

  @override
  String get newPasswordSubtitle =>
      'குறைந்தது 8 எழுத்துகள். கவலைப்படாதீர்கள், நான் பார்க்கமாட்டேன்.';

  @override
  String get authNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ எழுத்துகள்';
  }

  @override
  String get authStartAgain => 'மீண்டும் தொடங்கு';

  @override
  String get authSaving => 'சேமிக்கிறது…';

  @override
  String get authSaveAndLogIn => 'சேமித்து உள்நுழை';

  @override
  String get authFailureEmailTaken =>
      'இந்த மின்னஞ்சலில் ஏற்கனவே கணக்கு உள்ளது. உள்நுழையுங்கள்.';

  @override
  String get authFailureWrongCredentials =>
      'மின்னஞ்சலும் கடவுச்சொல்லும் பொருந்தவில்லை.';

  @override
  String get authFailureInvalidInput =>
      'விவரங்களைச் சரிபார்த்து மீண்டும் முயலுங்கள்.';

  @override
  String get authFailureSignedOut =>
      'அமர்வு முடிந்தது. மீண்டும் உள்நுழையுங்கள்.';

  @override
  String get authFailureNetwork =>
      'ACADEMe-ஐ அடைய முடியவில்லை. இணைப்பைச் சரிபார்த்து மீண்டும் முயலுங்கள்.';

  @override
  String get authFailureCanceled => 'உள்நுழைவு ரத்து செய்யப்பட்டது.';

  @override
  String get authFailureProviderUnavailable =>
      'இந்த உள்நுழைவு விருப்பம் இன்னும் தயாராகவில்லை. இப்போது மின்னஞ்சலைப் பயன்படுத்துங்கள்.';

  @override
  String get authFailureWrongCode =>
      'குறியீடு சரியல்ல. மின்னஞ்சலைச் சரிபார்த்து மீண்டும் முயலுங்கள்.';

  @override
  String get authFailureTooManyAttempts =>
      'பல தவறான முயற்சிகள். புதிய குறியீடு அனுப்பிக் கொள்ளுங்கள்.';

  @override
  String get authFailureCodeExpired =>
      'குறியீடு காலாவதியானது. புதியதை அனுப்பிக் கொள்ளுங்கள்.';

  @override
  String get authFailureResetExpired =>
      'மீட்டமை இணைப்பு காலாவதியானது. கடவுச்சொல் மறந்துவிட்டதா என்பதிலிருந்து மீண்டும் தொடங்குங்கள்.';

  @override
  String get authFailureTooManyRequests =>
      'பல முயற்சிகள். சிறிது காத்திருந்து மீண்டும் முயலுங்கள்.';

  @override
  String get authFailureWrongPassword => 'இது உங்கள் தற்போதைய கடவுச்சொல் அல்ல.';

  @override
  String get authFailureGoogleTaken =>
      'இந்த Google கணக்கு வேறொரு ACADEMe கணக்குடன் இணைக்கப்பட்டுள்ளது.';

  @override
  String get authFailurePasswordRequired =>
      'முதலில் கடவுச்சொல்லை அமைங்கள், Google இல்லாமலும் உள்நுழைய.';

  @override
  String get signUpHiPebby => 'வணக்கம், நான் பெப்பி!';

  @override
  String signUpHiNamed(String name) {
    return 'வணக்கம் $name, நான் பெப்பி!';
  }

  @override
  String get signUpAskFirstName =>
      'தொடங்குவதற்கு முன், உங்களை என்னவென்று அழைக்கலாம்?';

  @override
  String get signUpFirstName => 'முதல் பெயர்';

  @override
  String signUpAskLastName(String name) {
    return 'சந்தித்ததில் மகிழ்ச்சி, $name! உங்கள் கடைசி பெயர்?';
  }

  @override
  String get signUpLastName => 'கடைசி பெயர்';

  @override
  String signUpAskEmail(String name) {
    return 'உங்கள் மின்னஞ்சல் என்ன, $name?';
  }

  @override
  String get signUpEmailHint => 'உள்நுழைய இதைப் பயன்படுத்துவீர்கள்.';

  @override
  String get signUpEmailInvalid => 'இது இன்னும் மின்னஞ்சல் போல் தெரியவில்லை.';

  @override
  String get signUpCreatePassword => 'கடவுச்சொல்லை உருவாக்குங்கள்';

  @override
  String signUpPasswordHint(int count) {
    return 'குறைந்தது $count எழுத்துகள். கவலைப்படாதீர்கள், நான் பார்க்கமாட்டேன்.';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'மீண்டும் வரவேற்கிறோம், $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'உங்களுக்கு ஏற்கனவே கணக்கு உள்ளது, எனவே நீங்கள் உள்நுழைந்துள்ளீர்கள்.';

  @override
  String signUpYoureIn(String name) {
    return 'நீங்கள் உள்ளே வந்துவிட்டீர்கள், $name!';
  }

  @override
  String get signUpAccountReady =>
      'கணக்கு தயார். அடுத்து நீங்கள் என்ன படிக்கிறீர்கள் என்று சொல்லுங்கள்.';

  @override
  String get signUpHelloEmail =>
      'நான் ஸ்மார்ட்டாகப் படிக்க உதவுவேன். கணக்கை அமைப்போம், ஒரு நிமிடம் ஆகும்.';

  @override
  String get signUpConnectingAccount => 'உங்கள் கணக்கை இணைக்கிறது…';

  @override
  String get signUpCheckName => 'பெயரைச் சரிபார்ப்போம், பிறகு நீங்கள் உள்ளே.';

  @override
  String get signUpConnecting => 'இணைக்கிறது…';

  @override
  String get signUpHiPebbyAction => 'வணக்கம் பெப்பி!';

  @override
  String get signUpCreatingAccount => 'கணக்கை உருவாக்குகிறது…';

  @override
  String get signUpCreateAccount => 'கணக்கை உருவாக்கு';

  @override
  String get signUpLetsGo => 'போகலாம்';

  @override
  String get authContinue => 'தொடரவும்';

  @override
  String get homeSetupTitle => 'உங்கள் டாஷ்போர்டை அமைக்கவும்';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'மொழி';

  @override
  String get homeSetupTaskAge => 'உங்கள் வயது';

  @override
  String get homeSetupTaskClass => 'உங்கள் வகுப்பு';

  @override
  String get homeSetupTaskBoard => 'உங்கள் போர்டு';

  @override
  String get homeSetupTaskSubjects => 'உங்கள் பாடங்கள்';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'வீட்டுப்பாடம் தீர்க்கவும்';

  @override
  String get homeCheckAnswer => 'பதிலைச் சரிபார்க்கவும்';

  @override
  String get homeFlashcards => 'ஃபிளாஷ் கார்டுகள்';

  @override
  String get homePickSubjects => 'உங்கள் பாடங்களைத் தேர்ந்தெடுக்கவும்';

  @override
  String homePickSubjectsBody(int xp) {
    return 'முகப்பு மற்றும் படிப்பில் நீங்கள் படிப்பவை மட்டுமே தெரியும். +$xp XP';
  }

  @override
  String get setupLanguageTitle => 'எந்த மொழியில் கற்கிறீர்கள்?';

  @override
  String setupChooseLanguage(String name) {
    return '$name தேர்ந்தெடு';
  }

  @override
  String get setupLanguageFootnote => 'அமைப்புகளில் எப்போதும் மாற்றலாம்.';

  @override
  String get setupAgeTitle => 'நீங்கள் எப்போது பிறந்தீர்கள்?';

  @override
  String get setupAgeSubtitle => 'வயதுக்கு ஏற்ப சரியாக வைக்க.';

  @override
  String get setupBirthYear => 'பிறந்த ஆண்டு';

  @override
  String setupYouAreAge(int age) {
    return 'உங்கள் வயது $age.';
  }

  @override
  String get setupClassTitle => 'உங்கள் வகுப்பிற்கு சுழற்றுங்கள்';

  @override
  String get setupClassSubtitle =>
      'டயலைத் திருப்புங்கள் அல்லது எண்ணைத் தட்டவும்.';

  @override
  String setupImInClass(int level) {
    return 'நான் வகுப்பு $level-இல் இருக்கிறேன்';
  }

  @override
  String get setupBoardTitle => 'எந்த போர்டு?';

  @override
  String get setupBoardSubtitle =>
      'உங்கள் போர்டு பாடத்திட்டத்தைப் பின்பற்றுகிறோம்.';

  @override
  String get setupStateBoardsSoon => 'மாநில போர்டுகள் விரைவில்.';

  @override
  String get setupFinish => 'அமைப்பை முடிக்கவும்';

  @override
  String setupProgress(int step, int total) {
    return 'அமைப்பு · $step/$total';
  }

  @override
  String get setupLater => 'பிறகு';

  @override
  String get setupChangeInMe => 'Me-இல் எப்போதும் மாற்றலாம்.';

  @override
  String setupStreamTitle(int level) {
    return 'வகுப்பு $level-இல் என்ன படிக்கிறீர்கள்?';
  }

  @override
  String get setupAnythingElse => 'வேறு ஏதேனும்?';

  @override
  String get setupWhichSubjects => 'எந்தப் பாடங்களைப் படிக்கிறீர்கள்?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus. முக்கிய பாடங்கள் உள்ளன.';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus. படிக்காதவற்றை நீக்குங்கள்.';
  }

  @override
  String get homeYourSubjects => 'உங்கள் பாடங்கள்';

  @override
  String get homeEdit => 'திருத்து';

  @override
  String get homeSubjectsNeedSyllabus =>
      'பாடங்களைப் பார்க்க வகுப்பு மற்றும் போர்டை அமைக்கவும்';

  @override
  String get homeSubjectsLoading => 'பாடங்கள் ஏற்றப்படுகின்றன…';

  @override
  String get homeSubjectsSoon => 'உங்கள் பாடங்கள் இங்கே விரைவில் தோன்றும்.';

  @override
  String homeNextChapter(int number, String title) {
    return 'அடுத்து: Ch $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'அனைத்து பாடங்களும் முடிந்தன';

  @override
  String get homeLessonsComingSoon => 'பாடங்கள் விரைவில்';

  @override
  String homeTodayMinutes(int minutes) {
    return 'இன்று · $minutes நிமி';
  }

  @override
  String get homeTodayDone => 'இன்று · அனைத்தும் முடிந்தது';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கோப்புறைகளிலிருந்து',
      one: '1 கோப்புறையிலிருந்து',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'மேலும் உங்கள் கோப்புறைகளில் $count';
  }

  @override
  String get homeAskHintTitle => 'பெப்பியிடம் எதையும் கேளுங்கள்';

  @override
  String get homeAskHintBody =>
      'கேள்வியைத் தட்டச்சு செய்யுங்கள், அல்லது வீட்டுப்பாடம் தீர்க்க தட்டிப் படம் எடுங்கள்.';

  @override
  String get homeAskHintGotIt => 'புரிந்தது';

  @override
  String get homeDashboardLoadError => 'டாஷ்போர்டை ஏற்ற முடியவில்லை.';

  @override
  String get homeRetry => 'மீண்டும் முயலு';

  @override
  String get helloFallbackName => 'நண்பா';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாள் தொடர்ச்சி',
      one: '1 நாள் தொடர்ச்சி',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'குறிப்புகள் கோப்புறையில்';

  @override
  String get scanModeAsk => 'புகைப்படம் பற்றி கேள்';

  @override
  String get scanWhatsOnPaper => 'காகிதத்தில் என்ன இருக்கிறது?';

  @override
  String get scanHintSolve => 'முதலில் குறிப்பு';

  @override
  String get scanHintCheck => 'போர்டு-ஸ்டைல் மதிப்பெண்கள்';

  @override
  String get scanHintNotes => 'பக்கங்களில் இருந்து பாடம்';

  @override
  String get scanHintAsk => 'வேறு எதுவும்';

  @override
  String get scanRecent => 'சமீபத்திய ஸ்கேன்கள்';

  @override
  String get scanStatusRead => 'படித்தேன்';

  @override
  String get scanStatusSolvedInAskMe => 'ASKMe-ல் தீர்த்தேன்';

  @override
  String get scanStatusAskedInAskMe => 'ASKMe-ல் கேட்டேன்';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மதிப்பெண்கள்',
      one: '1 மதிப்பெண்',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'இன்னும் மதிப்பிடவில்லை';

  @override
  String get scanStatusLessonInFolder => 'கோப்புறையில் பாடம்';

  @override
  String get scanStatusNotesInFolder => 'கோப்புறையில் குறிப்புகள்';

  @override
  String get scanStatusNotSaved => 'இன்னும் சேமிக்கவில்லை';

  @override
  String get scanSourceNotesBlurb =>
      'அதிகபட்சம் 10 பக்கங்கள். புகைப்படங்கள் அல்ல, உரை மட்டும் வைக்கப்படும்.';

  @override
  String get scanSourceBlurb => 'புகைப்படம் அல்ல, உரை மட்டும் வைக்கப்படும்.';

  @override
  String get scanTakePhoto => 'புகைப்படம் எடு';

  @override
  String get scanChooseGallery => 'கேலரியில் இருந்து தேர்ந்தெடு';

  @override
  String get scanCamera => 'கேமரா';

  @override
  String get scanGallery => 'கேலரி';

  @override
  String get scanYourPages => 'உன் பக்கங்கள்';

  @override
  String scanPagesOf(int current, int max) {
    return '$current / $max';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பக்கங்கள் படி',
      one: '1 பக்கம் படி',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'பக்கத்தை நீக்கு';

  @override
  String get scanYourNotes => 'உன் குறிப்புகள்';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'பெப்பி $count பக்கங்கள் படித்தான்',
      one: 'பெப்பி 1 பக்கம் படித்தான்',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'இவை எங்கே போக வேண்டும்?';

  @override
  String get scanChooseFolder => 'கோப்புறையைத் தேர்ந்தெடு';

  @override
  String get scanChange => 'மாற்று';

  @override
  String get scanMakeFromNotes => 'குறிப்புகளில் இருந்து உருவாக்கு';

  @override
  String get scanSwipeLesson => 'ஸ்வைப் பாடம்';

  @override
  String get scanSwipeLessonSubtitle =>
      'கார்டுகள் மற்றும் சிறு சோதனைகள், திட்டத்தில் சேரும்';

  @override
  String get scanKeepNotes => 'குறிப்புகளை மட்டும் வை';

  @override
  String get scanKeepNotesSubtitle => 'உரை கோப்புறைக்குச் செல்லும்';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பக்கங்களைப் படிக்கிறேன்…',
      one: 'உன் பக்கத்தைப் படிக்கிறேன்…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'சில வினாடிகள் ஆகும்.';

  @override
  String get scanMakingLesson => 'உன் பாடம் தயாராகிறது…';

  @override
  String get scanSavingNotes => 'உன் குறிப்புகள் சேமிக்கப்படுகின்றன…';

  @override
  String get scanSavingWait => 'இவை உன் கோப்புறையில் இருக்கும்.';

  @override
  String get scanFailUnavailableTitle => 'ஸ்கேன் இன்னும் தயாராகவில்லை';

  @override
  String get scanFailUnavailableBody =>
      'பெப்பி இப்போது புகைப்படங்களைப் படிக்க முடியாது. பிறகு மீண்டும் முயலு.';

  @override
  String get scanFailNoTextTitle => 'இங்கே வார்த்தைகள் இல்லை';

  @override
  String get scanFailNoTextBody =>
      'கேமராவை வீட்டுப்பாடம், பாடநூல் பக்கம் அல்லது குறிப்புகள் மீது வை.';

  @override
  String get scanFailTooLargeTitle => 'மிகப் பெரிய புகைப்படங்கள்';

  @override
  String get scanFailTooLargeBody => 'ஒரே நேரத்தில் குறைவான பக்கங்களை முயலு.';

  @override
  String get scanFailNetworkTitle => 'நீ ஆஃப்லைனில் இருக்கிறாய்';

  @override
  String get scanFailNetworkBody => 'இணையத்தைப் பார்த்து மீண்டும் முயலு.';

  @override
  String get scanFailScanLimitTitle => 'இன்றைய இலவச ஸ்கேன்கள் முடிந்தன';

  @override
  String get scanFailScanLimitBody =>
      'நள்ளிரவில் திரும்பும். விரும்பும் அளவு ஸ்கேன் செய்ய Pro எடு.';

  @override
  String get scanFailCheckLimitTitle => 'இன்றைய இலவச சரிபார்ப்பு முடிந்தது';

  @override
  String get scanFailCheckLimitBody =>
      'நள்ளிரவில் திரும்பும். ஒவ்வொரு பதிலையும் சரிபார்க்க Pro எடு.';

  @override
  String get scanFailProOnlyTitle => 'குறிப்புகளில் இருந்து பாடங்கள் Pro';

  @override
  String get scanFailProOnlyBody =>
      'இலவசமாக குறிப்புகளை வை, அல்லது Pro எடுத்து பெப்பி அவற்றைப் பாடமாக்கட்டும்.';

  @override
  String get scanFailUnknownTitle => 'பெப்பி அதைப் படிக்க முடியவில்லை';

  @override
  String get scanFailUnknownBody =>
      'மீண்டும் முயலு, அல்லது நல்ல வெளிச்சத்தில் மீண்டும் புகைப்படம் எடு.';

  @override
  String get scanBackToAnswer => 'உன் பதிலுக்குத் திரும்பு';

  @override
  String get scanRetake => 'மீண்டும் எடு';

  @override
  String get scanCameraOpenFailed =>
      'கேமராவைத் திறக்க முடியவில்லை. கேலரியை முயலு.';

  @override
  String get scanPebbyReadThis => 'பெப்பி இதைப் படித்தான்';

  @override
  String get scanFixAnything => 'தவறு இருந்தால் சரி செய்.';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · தவறு இருந்தால் சரி செய்.';
  }

  @override
  String get scanFromYourPhoto => 'உன் புகைப்படத்தில் இருந்து';

  @override
  String get scanFromMyPhoto => 'என் புகைப்படத்தில் இருந்து:';

  @override
  String get scanWhatDoYouWant => 'நீ என்ன தெரிந்துகொள்ள விரும்புகிறாய்?';

  @override
  String get scanSuggestExplain => 'இதை எளிதாக விளக்கு';

  @override
  String get scanSuggestSummarise => 'சுருக்கம் சொல்';

  @override
  String get scanSuggestKeyTerms => 'முக்கிய சொற்கள் எவை?';

  @override
  String get scanSolveThis => 'இதைத் தீர்த்து வை';

  @override
  String get scanAskPebby => 'பெப்பியிடம் கேள்';

  @override
  String get scanHintFirst => 'பெப்பி முதலில் குறிப்பு தருவான், பிறகு படிகள்.';

  @override
  String get checkPebbyReadAnswer => 'பெப்பி உன் பதிலைப் படித்தான்';

  @override
  String get checkTheQuestion => 'கேள்வி';

  @override
  String get checkQuestionHint => 'புகைப்படத்தில் இல்லையென்றால் மட்டும்';

  @override
  String get checkMarkIt => 'மதிப்பிடு';

  @override
  String get checkMarkingAnswer => 'உன் பதில் மதிப்பிடப்படுகிறது…';

  @override
  String get checkMarkingScheme => 'போர்டின் மதிப்பீட்டுத் திட்டத்துடன்.';

  @override
  String get checkFullMarks => 'முழு மதிப்பெண்கள்!';

  @override
  String get checkNearlyThere => 'கிட்டத்தட்ட வந்துவிட்டாய்';

  @override
  String get checkKeepGoing => 'தொடர்ந்து முயலு';

  @override
  String get checkReportTitle => 'இந்த மதிப்பெண்களைப் புகாரளி';

  @override
  String get checkReportThanks => 'நன்றி. இந்த மதிப்பெண்களைப் பார்ப்போம்.';

  @override
  String get checkWhatGotMarks => 'எதற்கு மதிப்பெண்கள் கிடைத்தன';

  @override
  String get checkWellDone => 'நன்றாகச் செய்தாய்';

  @override
  String get checkForFullMarks => 'முழு மதிப்பெண்களுக்கு';

  @override
  String get checkAgain => 'மீண்டும் சரிபார்';

  @override
  String get checkShowModelAnswer => 'மாதிரி பதிலைக் காட்டு';

  @override
  String get checkHideModelAnswer => 'மாதிரி பதிலை மறை';

  @override
  String checkAskQuestion(String question) {
    return 'கேள்வி: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'என் பதில்:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'எனக்கு $awarded/$marks கிடைத்தது. முழு மதிப்பெண்கள் எப்படிப் பெறுவது?';
  }

  @override
  String get meLearningSection => 'கற்றல்';

  @override
  String get meMyProgress => 'என் முன்னேற்றம்';

  @override
  String get meClassAndBoard => 'வகுப்பும் போர்டும்';

  @override
  String get meAppearance => 'தோற்றம்';

  @override
  String get meNotificationsSection => 'அறிவிப்புகள்';

  @override
  String get meRemindersAndDailyGoal => 'நினைவூட்டலும் தினசரி இலக்கும்';

  @override
  String get meAccountSection => 'கணக்கு';

  @override
  String get meAccount => 'கணக்கு';

  @override
  String get meHelpAndFeedback => 'உதவியும் கருத்தும்';

  @override
  String get mePrivacyAndTerms => 'தனியுரிமையும் விதிகளும்';

  @override
  String get meLogOut => 'வெளியேறு';

  @override
  String get meLoggingOut => 'வெளியேறுகிறது…';

  @override
  String get meStudentFallback => 'மாணவர்';

  @override
  String get meDayStreak => 'நாள் தொடர்';

  @override
  String meLevelValue(int number) {
    return 'Lv $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return 'Lv $levelக்கு $xp XP';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'சரி';

  @override
  String meOkSwitchTo(String name) {
    return 'சரி · $nameக்கு மாற்று';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting இப்போது பெப்பி $nameஇல் பதிலளிப்பார்.';
  }

  @override
  String get meLanguageSwitchFailed =>
      'மொழியை மாற்ற முடியவில்லை. மீண்டும் முயலு.';

  @override
  String meOpenInBrowser(String url) {
    return 'உலாவியில் $url திற';
  }

  @override
  String get meNotSet => 'அமைக்கவில்லை';

  @override
  String get meOff => 'ஆஃப்';

  @override
  String meClassOnly(int level) {
    return 'வகுப்பு $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'வகுப்பு $level · $board';
  }

  @override
  String get meLogOutTitle => 'வெளியேறவா?';

  @override
  String get meLogOutBody =>
      'உன் முன்னேற்றம் கணக்கில் சேமிக்கப்பட்டுள்ளது. எப்போதும் மீண்டும் உள்நுழையலாம்.';

  @override
  String get meLogOutStay => 'இரு';

  @override
  String get accountSaveName => 'பெயரைச் சேமி';

  @override
  String get accountNameSaved => 'பெயர் சேமிக்கப்பட்டது';

  @override
  String get accountDangerZone => 'ஆபத்து மண்டலம்';

  @override
  String get accountDeleteMyAccount => 'என் கணக்கை நீக்கு';

  @override
  String get accountDeleteGraceNote =>
      'கேட்ட 30 நாட்களுக்குப் பிறகு கணக்கு நீக்கப்படும். அதற்குள் உள்நுழைந்து வைத்துக்கொள்.';

  @override
  String get accountSignIn => 'உள்நுழைவு';

  @override
  String get accountChangePassword => 'கடவுச்சொல்லை மாற்று';

  @override
  String get accountSetPassword => 'கடவுச்சொல் அமை';

  @override
  String get accountLinkGoogle => 'Google இணை';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'இணைக்கிறது…';

  @override
  String get accountUnlinking => 'இணைப்பு நீக்குகிறது…';

  @override
  String get accountNotLinked => 'இணைக்கவில்லை';

  @override
  String get accountGoogleLinked =>
      'Google இணைக்கப்பட்டது. இப்போது அதனால் உள்நுழையலாம்.';

  @override
  String get accountGoogleUnlinked =>
      'Google இணைப்பு நீக்கப்பட்டது. மின்னஞ்சல் மற்றும் கடவுச்சொல்லால் உள்நுழை.';

  @override
  String get accountUnlinkGoogleTitle => 'Google இணைப்பை நீக்கவா?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'இனி $email கொண்டு உள்நுழைய முடியாது. மின்னஞ்சல் மற்றும் கடவுச்சொல்லைப் பயன்படுத்து.';
  }

  @override
  String get accountKeepGoogle => 'Google வைத்திரு';

  @override
  String get accountUnlink => 'இணைப்பை நீக்கு';

  @override
  String get passwordSave => 'கடவுச்சொல்லைச் சேமி';

  @override
  String get passwordChangeBody =>
      'பதிவு செய்தபோது போன்ற விதிகள். சேமித்ததும் மற்ற சாதனங்கள் வெளியேறும்.';

  @override
  String get passwordSetBody =>
      'Google மட்டும் அல்ல, மின்னஞ்சலாலும் உள்நுழைய கடவுச்சொல் சேர்.';

  @override
  String get passwordCurrent => 'தற்போதைய கடவுச்சொல்';

  @override
  String get passwordChangedSnack =>
      'கடவுச்சொல் மாற்றப்பட்டது. மற்ற சாதனங்கள் வெளியேறின.';

  @override
  String get passwordSetSnack =>
      'கடவுச்சொல் அமைக்கப்பட்டது. இப்போது மின்னஞ்சலாலும் உள்நுழையலாம்.';

  @override
  String get deleteAccountTitle => 'கணக்கை நீக்கு';

  @override
  String get deleteDeleting => 'நீக்குகிறது…';

  @override
  String get deleteSorryTitle => 'நீ போவது வருத்தம்';

  @override
  String get deleteBody =>
      'உன் கணக்கு 30 நாட்களில் நீக்கப்படும். அதற்குள் மீண்டும் உள்நுழைந்து வைத்துக்கொள். 30 நாட்களுக்குப் பிறகு சுயவிவரம், அரட்டைகள், முன்னேற்றம் மற்றும் XP நிரந்தரமாக அழியும்.';

  @override
  String get deleteSubscription => 'சந்தா';

  @override
  String get deleteSubscriptionNotice =>
      'கணக்கை நீக்கினால் Google Playஇல் வாங்கிய ACADEMe Pro சந்தா ரத்து ஆகாது. மீண்டும் கட்டணம் வராமல் Google Playஇல் ரத்து செய்.';

  @override
  String get deleteManageSubscription => 'சந்தாவை நிர்வகி';

  @override
  String get deleteWhyLeaving => 'ஏன் போகிறாய்? (விருப்பம்)';

  @override
  String deleteConfirmLabel(String word) {
    return 'உறுதிப்படுத்த $word எழுது';
  }

  @override
  String get deleteReasonNotEnough => 'போதுமான அளவு பயன்படுத்தவில்லை';

  @override
  String get deleteReasonDidntHelp => 'படிப்பிற்கு உதவவில்லை';

  @override
  String get deleteReasonTooManyNotifs => 'அதிக அறிவிப்புகள்';

  @override
  String get deleteReasonDataWorry => 'என் தரவு குறித்து கவலை';

  @override
  String get deleteReasonOther => 'வேறு ஏதோ';

  @override
  String deleteScheduledSnack(String date) {
    return 'உன் கணக்கு $date அன்று நீக்கப்படும். அதற்குள் உள்நுழைந்து வைத்துக்கொள்.';
  }

  @override
  String get notifRemindersAndGoalTitle => 'நினைவூட்டலும் இலக்கும்';

  @override
  String get notifStudyReminder => 'படிப்பு நினைவூட்டல்';

  @override
  String get notifRemindMeToStudy => 'படிக்க நினைவூட்டு';

  @override
  String get notifTime => 'நேரம்';

  @override
  String get notifRemindMeAt => 'இந்த நேரத்தில் நினைவூட்டு';

  @override
  String get notifAlsoTellMe => 'இவற்றையும் சொல்';

  @override
  String get notifStreakAboutToEnd => 'என் தொடர் முடியப்போகும்போது';

  @override
  String get notifEveningBeforeTest => 'தேர்வுக்கு முந்தைய மாலை';

  @override
  String get notifWhenLevelUp => 'நான் நிலை உயரும்போது';

  @override
  String get notifNotifications => 'அறிவிப்புகள்';

  @override
  String get notifAllowed => 'அனுமதிக்கப்பட்டது';

  @override
  String get notifNotAllowed => 'அனுமதி இல்லை';

  @override
  String get notifTurnOn => 'அறிவிப்புகளை இயக்கு';

  @override
  String get notifTurnOnInSettings => 'அமைப்புகளில் இயக்கு';

  @override
  String get reminderTimeTitle => 'நினைவூட்டல் நேரம்';

  @override
  String get reminderHour => 'மணி';

  @override
  String get reminderMinute => 'நிமிடம்';

  @override
  String get reminderAmPm => 'காலை அல்லது மாலை';

  @override
  String get reminderAm => 'am';

  @override
  String get reminderPm => 'pm';

  @override
  String get dailyGoalTitle => 'தினசரி இலக்கு';

  @override
  String dailyGoalNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes நிமிடங்கள்',
      one: '1 நிமிடம்',
    );
    return 'முகப்பில் இன்றைய படிகள் சுமார் $_temp0 ஆகும்.';
  }

  @override
  String get dailyGoalSemantics => 'நிமிடங்களில் தினசரி இலக்கு';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes நிமி';
  }

  @override
  String get dailyGoalStudyEachDay => 'ஒவ்வொரு நாளும் படி';

  @override
  String get appearanceTheme => 'தீம்';

  @override
  String get appearanceLight => 'லைட்';

  @override
  String get appearanceDark => 'டார்க்';

  @override
  String get appearanceDarkHint => 'இரவில் டார்க் மோடு கண்களுக்கு எளிது.';

  @override
  String get appearanceLightsOff => 'விளக்கு அணைவு…';

  @override
  String get appearanceGoodMorning => 'காலை வணக்கம்!';

  @override
  String get appearanceDimming => 'பெப்பி அறையை மங்கலாக்குகிறார்';

  @override
  String get appearanceOpeningCurtains => 'பெப்பி திரைகளைத் திறக்கிறார்';

  @override
  String get helpTellUs => 'எங்களிடம் சொல்';

  @override
  String get helpEmailUs => 'எங்களுக்கு மின்னஞ்சல் அனுப்பு';

  @override
  String get helpThanks => 'நன்றி, உன் செய்தி கிடைத்தது.';

  @override
  String get feedbackWrongAnswer => 'தவறான பதிலைப் புகாரளி';

  @override
  String get feedbackBug => 'ஏதோ வேலை செய்யவில்லை';

  @override
  String get feedbackFeature => 'ஒரு அம்சத்தைப் பரிந்துரை';

  @override
  String get feedbackHint => 'என்ன ஆனது என்று சொல் (குறைந்தது 10 எழுத்துகள்).';

  @override
  String get feedbackSend => 'அனுப்பு';

  @override
  String get feedbackLimitNote =>
      'ஒரு நாளில் 2, வாரத்தில் 5 செய்திகள் அனுப்பலாம்.';

  @override
  String get feedbackFailGeneric => 'அனுப்ப முடியவில்லை. மீண்டும் முயலு.';

  @override
  String get feedbackFailDay =>
      'இன்று எடுக்கக்கூடிய கருத்தை எடுத்துவிட்டோம். நாளை மீண்டும் முயலு.';

  @override
  String get feedbackFailWeek =>
      'இந்த வாரம் எடுக்கக்கூடிய கருத்தை எடுத்துவிட்டோம். அடுத்த வாரம் மீண்டும் முயலு.';

  @override
  String get feedbackFailTooShort => 'உதவ குறைந்தது 10 எழுத்துகள் எழுது.';

  @override
  String get feedbackFailOffline =>
      'நீ ஆஃப்லைனில் இருக்கிறாய். இணைப்பைப் பார்த்து மீண்டும் முயலு.';

  @override
  String get privacySummary1 =>
      'ACADEMe இயக்க உன் கணக்கு, வகுப்பு, போர்டு மற்றும் பாடங்கள், படிப்பு முன்னேற்றம் மற்றும் தொடர், கோப்புறைகள், குறிப்புகள் மற்றும் பெப்பி அரட்டைகளை வைத்திருக்கிறோம்.';

  @override
  String get privacySummary2 =>
      'உன் கேள்விகளும் ஸ்கேன் படங்களும் இந்தியாவில் உள்ள Sarvam AIக்குச் செல்கின்றன — பெப்பி பதிலளிக்க. படங்களை வைக்கமாட்டோம், அவற்றிலிருந்து படித்த உரை மட்டும்.';

  @override
  String get privacySummary3 =>
      'விளம்பரங்கள் இல்லை, விளம்பர ID இல்லை, இருப்பிடம் இல்லை, உன் தரவை விற்கமாட்டோம்.';

  @override
  String get privacySummary4 =>
      'கணக்கில் எப்போதும் கணக்கை நீக்கலாம். 30 நாட்களுக்குப் பிறகு அனைத்தும் அழியும்.';

  @override
  String get privacyDocuments => 'ஆவணங்கள்';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get privacyTermsOfUse => 'பயன்பாட்டு விதிகள்';

  @override
  String get privacyYourData => 'உன் தரவு';

  @override
  String get privacyGetCopy => 'என் தரவின் நகலைப் பெறு';

  @override
  String get privacyGrievanceOfficer => 'குறைதீர்ப்பு அதிகாரி';

  @override
  String classBoardSave(int level, String board) {
    return 'சேமி · வகுப்பு $level · $board';
  }

  @override
  String get classBoardYourClass => 'உன் வகுப்பு';

  @override
  String get classBoardYourBoard => 'உன் போர்டு';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'உன் பாடங்களும் திட்டமும் வகுப்பு $level · $boardக்கு மாறும். இதுவரை செய்ததெல்லாம் சேமிக்கப்படும்.';
  }

  @override
  String get classBoardSubjects => 'பாடங்கள்';

  @override
  String get classBoardStream => 'ஸ்ட்ரீம்';

  @override
  String get classBoardAllSubjects => 'அனைத்துப் பாடங்கள்';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'இப்போது வகுப்பு $level · $board பாடங்கள் காட்டப்படுகின்றன';
  }

  @override
  String get reminderPrimerTitle => 'தேர்வுக்கு முன் ஒரு நினைவூட்டல் பெறு';

  @override
  String get reminderPrimerPromise1 =>
      'ஒவ்வொரு தேர்வுக்கும் 3 நாட்களுக்கு முன், முந்தைய மாலை மற்றும் அன்று காலை நினைவூட்டல்';

  @override
  String get reminderPrimerPromise2 =>
      'படிப்பு நினைவூட்டல், நீ தேர்ந்தெடுத்த நாட்கள் மற்றும் நேரத்தில் மட்டும்';

  @override
  String get reminderPrimerPromise3 =>
      'வேறு எதுவும் இல்லை. Meஇல் எப்போதும் மாற்றலாம்';

  @override
  String get reminderPrimerAllow => 'அனுமதி';

  @override
  String get paywallWelcomeSnack => 'ACADEMe Pro-க்கு வரவேற்கிறோம்';

  @override
  String get paywallTagline =>
      'தினசரி & வாராந்திர வரம்புகள் 3×. அதே ரீஃபில் கடிகாரம் — படிக்க அதிக இடம்.';

  @override
  String get paywallOpeningPlay => 'Google Play திறக்கிறது…';

  @override
  String get paywallRestoring => 'மீட்டமைக்கிறது…';

  @override
  String get paywallRestore => 'கொள்முதல்களை மீட்டெடு';

  @override
  String get paywallUnavailableTitle => 'இந்த சாதனத்தில் கொள்முதல் இல்லை';

  @override
  String get paywallUnavailableBody =>
      'Pro-க்கு செல்ல ACADEMe-ஐ Google Play-இல் நிறுவி Play-இல் உள்நுழை.';

  @override
  String get paywallBenefitAskme => 'ஒவ்வொரு நாளும் 3× ASKMe கேள்விகள்';

  @override
  String get paywallBenefitScan => 'ஒவ்வொரு நாளும் 3× ஸ்கேன்கள்';

  @override
  String get paywallBenefitCheck => 'ஒவ்வொரு நாளும் 3× பதில் சரிபார்ப்புகள்';

  @override
  String get paywallBenefitLessons => 'உன் நோட்ஸிலிருந்து ஸ்வைப் பாடங்கள்';

  @override
  String get paywallBenefitProgress => 'My Progress வாராந்திர சுருக்கம்';

  @override
  String get paywallMonthly => 'மாதாந்திரம்';

  @override
  String get paywallAnnual => 'ஆண்டு';

  @override
  String paywallPlanSemantics(String title) {
    return '$title திட்டம்';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return 'முதல் மாதம் $introPrice, பிறகு $price/மாதம்';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/மாதம்';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/ஆண்டு';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'சுமார் $monthlyPrice/மாதம் · 17% சேமிப்பு · தானாக புதுப்பிப்பு';
  }

  @override
  String get paywallDetailAnnual => '17% சேமிப்பு · தானாக புதுப்பிப்பு';

  @override
  String get paywallDetailRenews => 'தானாக புதுப்பிக்கும்';

  @override
  String get paywallBestValue => 'சிறந்த மதிப்பு';

  @override
  String get paywallSmallPrint =>
      'தானாக புதுப்பிப்பு. Google Play-இல் எப்போதும் ரத்து செய்.';

  @override
  String get paywallTerms => 'விதிமுறைகள்';

  @override
  String get paywallPrivacy => 'தனியுரிமை';

  @override
  String get upgradeTitle => 'Pro வாங்கு · 3× வரம்புகள்';

  @override
  String get limitAskmeTitle => 'இன்றைய இலவச கேள்விகள் முடிந்தன';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ASKMe கேள்விகள்',
      one: '1 ASKMe கேள்வி',
    );
    return 'இலவசத்தில் ஒரு நாளைக்கு $_temp0. Pro ஒவ்வொரு நாளும் 3× தரும்.';
  }

  @override
  String get limitScanTitle => 'இன்றைய இலவச ஸ்கேன்கள் முடிந்தன';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ஸ்கேன்கள்',
      one: '1 ஸ்கேன்',
    );
    return 'இலவசத்தில் ஒரு நாளைக்கு $_temp0. Pro ஒவ்வொரு நாளும் 3× தரும்.';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இன்றைய இலவச சரிபார்ப்புகள் முடிந்தன',
      one: 'இன்றைய இலவச சரிபார்ப்பு முடிந்தது',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பதில் சரிபார்ப்புகள்',
      one: 'ஒரு பதில் சரிபார்ப்பு',
    );
    return 'இலவசத்தில் ஒரு நாளைக்கு $_temp0. Pro ஒவ்வொரு நாளும் 3× தரும்.';
  }

  @override
  String get limitLessonsTitle => 'நோட்ஸிலிருந்து பாடங்கள் Pro-இல்';

  @override
  String get limitLessonsBody =>
      'நோட்ஸை வைத்திருப்பது இலவசம். Pro-இல் பெப்பி அவற்றை வினாடி வினாவுடன் ஸ்வைப் பாடங்களாக்கும்.';

  @override
  String get limitMaybeLater => 'பிறகு பார்க்கலாம்';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'திட்டம் & வரம்புகள்';

  @override
  String get proCardSubtitleFree => 'திட்டம் & வரம்புகள் · Pro-இல் 3×';

  @override
  String get proCardSubtitleMonthly => 'Pro · மாதாந்திரம்';

  @override
  String get proCardSubtitleAnnual => 'Pro · ஆண்டு';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'நிர்வகி';

  @override
  String get proOnPro => 'நீ Pro-இல் இருக்கிறாய்';

  @override
  String get proOnFree => 'நீ இலவசத்தில் இருக்கிறாய்';

  @override
  String get proMetaFree => 'தினசரி & வாராந்திர வரம்புகள் · 12:00 AM IST';

  @override
  String get proMetaBillingIssue =>
      'Pro வைத்திருக்க Google Play-இல் பேமென்ட்டை சரிசெய்';

  @override
  String get proMetaActiveNoExpiry =>
      '3× தினசரி வரம்புகள் · வாராந்திர பாதுகாப்பு வரம்பு';

  @override
  String proMetaAnnualRenews(String date) {
    return 'ஆண்டு · $date அன்று புதுப்பிப்பு · 3× வரம்புகள்';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'மாதாந்திரம் · $date அன்று புதுப்பிப்பு · 3× வரம்புகள்';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro $date அன்று முடியும்';
  }

  @override
  String get proStatusActive => 'செயலில்';

  @override
  String get proStatusFree => 'இலவசம்';

  @override
  String get proDailyLimits => 'தினசரி வரம்புகள்';

  @override
  String get proResetsDaily => 'ஒவ்வொரு நாளும் 12:00 AM IST-இல் மீட்டமை';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'Scan';

  @override
  String get proFeatureCheck => 'Check';

  @override
  String get proFeatureLessons => 'பாடங்கள்';

  @override
  String get proWeeklyLimit => 'வாராந்திர வரம்பு';

  @override
  String get proResetsMondays => 'திங்கட்கிழமைகளில் மீட்டமை · 12:00 AM IST';

  @override
  String proResetsOnDay(String day) {
    return '$day அன்று மீட்டமை · 12:00 AM IST';
  }

  @override
  String get proAllFeatures => 'அனைத்து அம்சங்கள்';

  @override
  String get proManageInPlay => 'Google Play-இல் நிர்வகி';

  @override
  String get proResetsSoon => 'விரைவில்';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count மணிநேரத்தில்',
      one: '1 மணிநேரத்தில்',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'உன் பேமென்ட் நிலுவையில். Google Play உறுதிப்படுத்தியதும் Pro ஆன் ஆகும்.';

  @override
  String get proNoticeNoPurchase =>
      'இந்த Google கணக்கில் ACADEMe Pro கொள்முதல் இல்லை.';

  @override
  String get proNoticeNotAllowed =>
      'இந்த Google கணக்கில் கொள்முதல் அணைக்கப்பட்டுள்ளது.';

  @override
  String get proNoticeAlreadyOwned =>
      'இந்த Google கணக்கில் ஏற்கனவே Pro உள்ளது. கொள்முதல்களை மீட்டெடு என்பதைத் தட்டு.';

  @override
  String get proNoticeUnavailable => 'இந்த சாதனத்தில் கொள்முதல் இல்லை.';

  @override
  String get proNoticeStoreError =>
      'Google Play முடிக்க முடியவில்லை. மீண்டும் முயலு.';

  @override
  String get askmeNewChat => 'புதிய அரட்டை';

  @override
  String askmeStudying(String name) {
    return 'என்ன படிக்கிறோம், $name?';
  }

  @override
  String get askmeModeExplainLine => 'பெப்பி எளிமையாக, படிப்படியாக விளக்கும்.';

  @override
  String get askmeModeSolveLine => 'பெப்பி குறிப்புகள் தரும். நீ தீர்க்கிறாய்.';

  @override
  String get askmeModeQuizLine =>
      'பெப்பி கேட்கும், நீ பதில் சொல்வாய், XP கிடைக்கும்.';

  @override
  String get askmeSuggestExplain1 => 'ஒளி பிரதிபலிப்பை எளிமையாக விளக்கு';

  @override
  String get askmeSuggestExplain2 => 'வானம் ஏன் நீலமாக இருக்கிறது?';

  @override
  String get askmeSuggestExplain3 => 'ஒளிச்சேர்க்கை என்றால் என்ன?';

  @override
  String get askmeSuggestSolve1 =>
      '2x + 3y = 11 மற்றும் x − 2y = −12 தீர்க்க உதவு';

  @override
  String get askmeSuggestSolve2 => 'r = 7 cm வட்டத்தின் பரப்பளவைக் கண்டுபிடி';

  @override
  String get askmeSuggestSolve3 => 'H₂ + O₂ → H₂O சமன் செய்';

  @override
  String get askmeSuggestQuiz1 => 'Light மீது வினாடி வினா';

  @override
  String get askmeSuggestQuiz2 => 'நேர்கோட்டுச் சமன்பாடுகளில் 5 கேள்விகள் தா';

  @override
  String get askmeSuggestQuiz3 => 'French Revolution மீது வினாடி வினா';

  @override
  String get askmeModeExplain => 'விளக்கு';

  @override
  String get askmeModeSolve => 'தீர்க்கு';

  @override
  String get askmeModeQuiz => 'வினாடி வினா';

  @override
  String get askmeFollowNextStep => 'அடுத்த அடி';

  @override
  String get askmeFollowFullSolution => 'முழு தீர்வு';

  @override
  String get askmeFollowNextQuestion => 'அடுத்த கேள்வி';

  @override
  String get askmeFollowQuizMe => 'வினாடி வினா';

  @override
  String get askmeFollowGoDeeper => 'மேலும் ஆழமாக';

  @override
  String get askmeSendNextStep => 'அடுத்த அடியைச் சொல்லு.';

  @override
  String get askmeSendFullSolution => 'முழு தீர்வைக் காட்டு.';

  @override
  String get askmeSendNextQuestion => 'அடுத்த கேள்வி.';

  @override
  String get askmeSendGoDeeper => 'மேலும் ஆழமாகச் சொல்லு.';

  @override
  String get askmeSendQuizMe => 'இதில் வினாடி வினா கேள்.';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe இன்னும் தயாராகவில்லை. பெப்பி விரைவில் வரும்.';

  @override
  String get askmeFailureSignedOut => 'நீ வெளியேறிவிட்டாய். மீண்டும் உள்நுழை.';

  @override
  String get askmeFailureLimitReached =>
      'இன்றைய இலவச கேள்விகள் முடிந்தது. நள்ளிரவில் மீண்டும் வரும்.';

  @override
  String get askmeThinking => 'பெப்பி யோசிக்கிறது';

  @override
  String get historyTitle => 'வரலாறு';

  @override
  String get historySearchHint => 'உன் கேள்விகளைத் தேடு';

  @override
  String get historyLoadError => 'அரட்டைகள் ஏறவில்லை. மீண்டும் முயலு';

  @override
  String get historyEmpty => 'பெப்பியிடம் கேட்ட கேள்விகள் இங்கே தெரியும்.';

  @override
  String get historyThisWeek => 'இந்த வாரம்';

  @override
  String get historyEarlier => 'முன்பு';

  @override
  String get historyNow => 'இப்போது';

  @override
  String historyHoursAgo(int hours) {
    return '$hoursமணி';
  }

  @override
  String get historyWeekdayMon => 'திங்';

  @override
  String get historyWeekdayTue => 'செவ்';

  @override
  String get historyWeekdayWed => 'புத';

  @override
  String get historyWeekdayThu => 'வியா';

  @override
  String get historyWeekdayFri => 'வெள்';

  @override
  String get historyWeekdaySat => 'சனி';

  @override
  String get historyWeekdaySun => 'ஞாயி';

  @override
  String get historyMonthJan => 'ஜன';

  @override
  String get historyMonthFeb => 'பிப்';

  @override
  String get historyMonthMar => 'மார்';

  @override
  String get historyMonthApr => 'ஏப்';

  @override
  String get historyMonthMay => 'மே';

  @override
  String get historyMonthJun => 'ஜூன்';

  @override
  String get historyMonthJul => 'ஜூலை';

  @override
  String get historyMonthAug => 'ஆக';

  @override
  String get historyMonthSep => 'செப்';

  @override
  String get historyMonthOct => 'அக்';

  @override
  String get historyMonthNov => 'நவ';

  @override
  String get historyMonthDec => 'டிச';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'உன் கேள்வியில் சேர்';

  @override
  String get attachCamera => 'கேமரா';

  @override
  String get attachPhotos => 'புகைப்படங்கள்';

  @override
  String get replyHelpful => 'உதவிகரமானது';

  @override
  String get replyNotHelpful => 'உதவியாக இல்லை';

  @override
  String get replyCopy => 'நகல்';

  @override
  String get replyCopied => 'நகலெடுக்கப்பட்டது';

  @override
  String get replyReportTitle => 'இந்த பதிலைப் புகாரளி';

  @override
  String get replyReportThanks => 'நன்றி. இந்த பதிலைப் பார்ப்போம்.';

  @override
  String get reportTooltip => 'புகார்';

  @override
  String get reportSendFailed => 'புகார் அனுப்ப முடியவில்லை. மீண்டும் முயலு.';

  @override
  String get reportBody =>
      'பெப்பியை மேலும் பாதுகாப்பாக்க ஒவ்வொரு புகாரையும் படிக்கிறோம்.';

  @override
  String get reportReasonWrong => 'இது தவறு';

  @override
  String get reportReasonHarmful => 'இது தீங்கு அல்லது பாதுகாப்பற்றது';

  @override
  String get reportReasonOffensive => 'இது மரியாதையற்றது அல்லது புண்படுத்தும்';

  @override
  String get reportReasonOther => 'வேறு ஏதோ';

  @override
  String get progressTitle => 'என் முன்னேற்றம்';

  @override
  String get progressLoading => 'இந்த வாரம் ஏற்றுகிறது…';

  @override
  String get progressLoadError => 'இந்த வாரச் சுருக்கம் ஏறவில்லை.';

  @override
  String get progressHoldTitle => 'என் முன்னேற்றம் Pro-இன் பகுதி';

  @override
  String get progressHoldBody =>
      'ACADEMe Pro உடன் ஸ்ட்ரீக், நிலை, படிப்பு நுண்ணறிவுகளைப் பார்.';

  @override
  String get progressGoProLimits => 'Go Pro · 3× வரம்புகள்';

  @override
  String get progressStudyDays => 'படிப்பு நாட்கள்';

  @override
  String get progressThisWeek => 'இந்த வாரம்';

  @override
  String get progressTodayStudied => 'இன்று · படித்தாய்';

  @override
  String get progressTodayNotYet => 'இன்று · இன்னும் இல்லை';

  @override
  String get progressTabSummary => 'சுருக்கம்';

  @override
  String get progressTabProgress => 'முன்னேற்றம்';

  @override
  String get progressTabActivity => 'செயல்பாடு';

  @override
  String get progressSubjectsThisWeek => 'இந்த வாரப் பாடங்கள்';

  @override
  String get progressCompleted => 'முடிந்தது';

  @override
  String get progressOverallGrade => 'மொத்த தரம்';

  @override
  String get progressKeepItUp => 'இப்படியே தொடர்';

  @override
  String get progressStartJourney => 'உன் பயணத்தைத் தொடங்கு';

  @override
  String get progressCourseProgress => 'பாடநெறி முன்னேற்றம்';

  @override
  String get progressLessonsEmpty => 'நீ முடிக்கும் பாடங்கள் இங்கே தெரியும்.';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடங்கள்',
      one: '1 பாடம்',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'செயல்பாடு';

  @override
  String get progressStudyDaysEmpty => 'உன் படிப்பு நாட்கள் இங்கே தெரியும்.';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'இந்த வாரம் $count செயல்பட்ட நாட்கள்.',
      one: 'இந்த வாரம் 1 செயல்பட்ட நாள்.',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'உன் பயணத்தைத் தொடங்க வேண்டிய நேரம்!';

  @override
  String get progressCtaMomentum => 'உன் வேகத்தைத் தொடர்';

  @override
  String get progressCtaHabit => 'நீ ஒரு பழக்கத்தை உருவாக்குகிறாய்';

  @override
  String get progressCtaNext => 'அடுத்து என்ன செய்ய வேண்டும் பார்';

  @override
  String get progressNextSteps => 'அடுத்த அடிகள்';

  @override
  String get progressYourSetup => 'உன் அமைப்பு';

  @override
  String get progressWhatNext => 'அடுத்து என்ன செய்வது';

  @override
  String get progressNextWithStudy =>
      'இந்த வாரம் பாடங்களை முடித்துக் கொண்டே இரு. முடிந்ததும் தரம் புதுப்பிக்கும்.';

  @override
  String get progressNextNoStudy =>
      'Me-இல் வகுப்பு மற்றும் போர்டை உறுதிப்படுத்து. பிறகு Study திறந்து முதல் பாடத்தை முடி.';

  @override
  String get progressWeekEmpty => 'இந்த வாரம் இன்னும் படிப்பு பதிவு இல்லை.';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count செயல்பட்ட நாட்கள்',
      one: '1 செயல்பட்ட நாள்',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடங்கள்',
      one: '1 பாடம்',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அத்தியாயத் தேர்வுகள்',
      one: '1 அத்தியாயத் தேர்வு',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'இந்த வாரம்: $parts.';
  }

  @override
  String get progressWeekdayMon => 'தி';

  @override
  String get progressWeekdayTue => 'செ';

  @override
  String get progressWeekdayWed => 'பு';

  @override
  String get progressWeekdayThu => 'வி';

  @override
  String get progressWeekdayFri => 'வெ';

  @override
  String get progressWeekdaySat => 'ச';

  @override
  String get progressWeekdaySun => 'ஞா';

  @override
  String get subjectsStreamTitle => 'உன் ஸ்ட்ரீம்';

  @override
  String get subjectsSave => 'சேமி';

  @override
  String get subjectsLoadError => 'பாடங்கள் ஏறவில்லை. மீண்டும் முயலு';

  @override
  String get subjectsMain => 'முதன்மை';

  @override
  String get subjectsOptional => 'விருப்பத்தேர்வு';

  @override
  String streamSwipeFor(String name) {
    return '$nameக்கு ஸ்வைப் செய். Me-இல் எப்போதும் மாற்றலாம்.';
  }

  @override
  String get streamChangeInMe => 'Me-இல் எப்போதும் மாற்றலாம்.';

  @override
  String streamChoose(String name) {
    return '$name தேர்ந்தெடு';
  }

  @override
  String get classDialLabel => 'வகுப்பு';

  @override
  String classDialSemantics(int level) {
    return 'வகுப்பு $level';
  }

  @override
  String get studyTitle => 'படிப்பு';

  @override
  String get studyCourses => 'பாடநெறிகள்';

  @override
  String get studyFolders => 'கோப்புறைகள்';

  @override
  String get studyDone => 'முடிந்தது';

  @override
  String get studyKeep => 'வை';

  @override
  String get studyDelete => 'நீக்கு';

  @override
  String get studySave => 'சேமி';

  @override
  String get studyCreate => 'உருவாக்கு';

  @override
  String get studyAdd => 'சேர்';

  @override
  String get studyOptional => 'விருப்பம்';

  @override
  String get studyName => 'பெயர்';

  @override
  String get studyToday => 'இன்று';

  @override
  String get studyComingSoon => 'விரைவில்';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'அத்தியாயம் $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடங்களில்',
      one: '1 பாடத்தில்',
    );
    return '$_temp0 $done முடிந்தது';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count விரைவில்',
      one: '1 விரைவில்',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'போர்டு தேர்வில் இல்லை';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அட்டைகள்',
      one: '1 அட்டை',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count விரைவுச் சோதனைகள்',
      one: '1 விரைவுச் சோதனை',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கேள்விகள்',
      one: '1 கேள்வி',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அத்தியாயங்கள்',
      one: '1 அத்தியாயம்',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடங்கள்',
      one: '1 பாடம்',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes நிமி';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'சுமார் $minutes நிமி';
  }

  @override
  String get coursesNeedSyllabus =>
      'பாடநெறிகளைப் பார்க்க ஹோமில் வகுப்பு, போர்டை அமை.';

  @override
  String get coursesLoadError => 'பாடநெறிகள் ஏறவில்லை. மீண்டும் முயலு';

  @override
  String coursesComingSoon(String syllabus) {
    return '$syllabus பாடங்கள் வருகின்றன. அதுவரை ASKMe-ல் பெப்பியிடம் கேள்.';
  }

  @override
  String get coursesNoFilterMatch =>
      'இந்த வடிகட்டிகளுக்கு அத்தியாயங்கள் இல்லை.';

  @override
  String get coursesFinishedEmpty => 'முடிந்த அத்தியாயங்கள் இங்கே தெரியும்.';

  @override
  String get coursesStartedEmpty => 'தொடங்கிய அத்தியாயங்கள் இங்கே தெரியும்.';

  @override
  String get coursesGoAgain => 'மீண்டும் செய்';

  @override
  String coursesContinueCard(int current, int total) {
    return 'தொடர் · அட்டை $current / $total';
  }

  @override
  String get coursesStart => 'தொடங்கு';

  @override
  String get filterAll => 'அனைத்தும்';

  @override
  String get filterInProgress => 'நடக்கிறது';

  @override
  String get filterDone => 'முடிந்தது';

  @override
  String get filterFilters => 'வடிகட்டிகள்';

  @override
  String filterFiltersOn(int count) {
    return 'வடிகட்டிகள், $count ஆன்';
  }

  @override
  String get filterClear => 'அழி';

  @override
  String get filterSort => 'வரிசை';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அத்தியாயங்கள்',
      one: '1 அத்தியாயம்',
    );
    return '$_temp0 காட்டு';
  }

  @override
  String get filterBoardExamOnly => 'போர்டு தேர்வு மட்டும்';

  @override
  String get filterBoardExamOnlyDesc => 'பள்ளி மதிப்பீட்டு அத்தியாயங்களை மறை';

  @override
  String get filterReadyToStudy => 'படிக்கத் தயார்';

  @override
  String get filterReadyToStudyDesc => 'விரைவில் வரும் அத்தியாயங்களை மறை';

  @override
  String get filterRevisionDue => 'மறுபார்வை நிலுவை';

  @override
  String get filterRevisionDueDesc =>
      'வைத்த அட்டைகள் மறுபார்வைக்குள்ள அத்தியாயங்கள்';

  @override
  String get filterSortTextbook => 'பாடநூல்';

  @override
  String get filterSortMostMarks => 'அதிக மதிப்பெண்கள்';

  @override
  String get filterSortRecent => 'சமீபத்திய';

  @override
  String get filterFlagBoardExam => 'போர்டு தேர்வு';

  @override
  String get filterFlagReady => 'தயார்';

  @override
  String get filterFlagRevisionDue => 'மறுபார்வை நிலுவை';

  @override
  String filterRemove(String label) {
    return '$label நீக்கு';
  }

  @override
  String get folderNew => 'புதிய கோப்புறை';

  @override
  String get folderEdit => 'கோப்புறையைத் திருத்து';

  @override
  String get folderEmptyHint =>
      'தேர்வு, வீட்டுப்பாடம் அல்லது ஏதேனும் தயாரிப்புக்கு கோப்புறை உருவாக்கு. தேதி போட்டால் நாட்கள் திட்டமிடப்படும்.';

  @override
  String get folderEmpty => 'காலி';

  @override
  String get folderNothingLeftToday => 'இன்று எதுவும் மீதி இல்லை';

  @override
  String folderTodoToday(int count) {
    return 'இன்று $count செய்ய வேண்டும்';
  }

  @override
  String get folderNoDate => 'தேதி இல்லை';

  @override
  String folderPercentReady(int percent) {
    return '$percent% தயார்';
  }

  @override
  String get folderWhatsFor => 'இந்தக் கோப்புறை எதற்கு?';

  @override
  String get folderAddChaptersPlan =>
      'அத்தியாயங்கள் சேர்த்தால் பெப்பி நாட்களைத் திட்டமிடும்.';

  @override
  String get folderAddChapters => 'அத்தியாயங்கள் சேர்';

  @override
  String get folderFromSyllabus => 'உன் பாடத்திட்டத்திலிருந்து';

  @override
  String get folderWriteNote => 'குறிப்பு எழுது';

  @override
  String get folderNoteSubtitle => 'நினைவில் வைக்க வேண்டியது';

  @override
  String get folderScanNotes => 'குறிப்புகளை ஸ்கேன் செய்';

  @override
  String get folderScanNotesSubtitle => 'பக்கங்களின் போட்டோ, பாடமாகிவிடும்';

  @override
  String get folderAddTodo => 'செய்ய வேண்டியதைச் சேர்';

  @override
  String get folderAddDate => 'தேதி சேர்';

  @override
  String get folderRemoveDate => 'தேதியை நீக்கு';

  @override
  String get folderReminders => 'இந்தக் கோப்புறை நினைவூட்டல்கள்';

  @override
  String get folderDeleteTitle => 'இந்தக் கோப்புறையை நீக்கவா?';

  @override
  String get folderDeleteBody =>
      'குறிப்புகளும் செய்ய வேண்டியவையும் போகும். பாடங்களும் முன்னேற்றமும் இருக்கும்.';

  @override
  String get folderTitle => 'கோப்புறை';

  @override
  String get folderEditRemindersTooltip => 'திருத்து மற்றும் நினைவூட்டல்கள்';

  @override
  String get folderDeleteTooltip => 'கோப்புறையை நீக்கு';

  @override
  String get folderLoadError => 'கோப்புறை ஏறவில்லை. மீண்டும் முயலு';

  @override
  String folderTodayMinutes(int minutes) {
    return 'இன்று · $minutes நிமி';
  }

  @override
  String get folderSeePlan => 'திட்டம் பார்';

  @override
  String get folderAddChaptersOrTodos =>
      'அத்தியாயங்கள் அல்லது செய்ய வேண்டியவை சேர்.';

  @override
  String get folderNothingLeftForToday => 'இன்றைக்கு எதுவும் மீதி இல்லை.';

  @override
  String get folderInThisFolder => 'இந்தக் கோப்புறையில்';

  @override
  String get folderFromNotesDone => 'உன் குறிப்புகளிலிருந்து · முடிந்தது';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'உன் குறிப்புகளிலிருந்து · $minutes நிமி';
  }

  @override
  String get folderNote => 'குறிப்பு';

  @override
  String get folderSaveNote => 'குறிப்பைச் சேமி';

  @override
  String get folderTypeHere => 'இங்கே எழுது…';

  @override
  String get folderAddTo => 'கோப்புறையில் சேர்';

  @override
  String get folderCouldntMake => 'கோப்புறை உருவாகவில்லை. மீண்டும் முயலு.';

  @override
  String folderAddedTo(String name) {
    return '$name-இல் சேர்த்தோம்';
  }

  @override
  String get folderYourFolder => 'உன் கோப்புறை';

  @override
  String get folderPlan => 'திட்டம்';

  @override
  String folderPlanTo(String date) {
    return '$date வரை திட்டம்';
  }

  @override
  String get folderPlanBody =>
      'இந்தக் கோப்புறை அத்தியாயங்களிலிருந்து. ஏதேனும் தவறினால் அடுத்த நாளுக்குச் செல்லும்.';

  @override
  String get folderTestDay => 'தேர்வு நாள் · நீ தயார்';

  @override
  String get folderRestDay => 'ஓய்வு நாள்';

  @override
  String get folderDueTomorrow => 'நாளை';

  @override
  String get folderDueYesterday => 'நேற்று';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள்',
      one: '1 நாள்',
    );
    return '$_temp0 முன்';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்களில்',
      one: '1 நாளில்',
    );
    return '$_temp0';
  }

  @override
  String chapterTitle(int number) {
    return 'அத்தியாயம் $number';
  }

  @override
  String get chapterLessons => 'பாடங்கள்';

  @override
  String get chapterTest => 'அத்தியாயத் தேர்வு';

  @override
  String chapterTestLast(int correct, int total) {
    return 'கடந்த முறை $correct/$total · மீண்டும் முயலு';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கேள்விகள்',
      one: '1 கேள்வி',
    );
    return 'ஒவ்வொரு பாடத்திலிருந்தும் $_temp0';
  }

  @override
  String get chapterKeptCards => 'வைத்த அட்டைகள்';

  @override
  String get chapterKeptEmpty =>
      'ஏதேனும் அட்டையில் Keep அழுத்தினால் இங்கே சேமிக்கப்படும்';

  @override
  String chapterKeptCount(int count) {
    return '$count மறுபார்வை';
  }

  @override
  String get chapterAllDoneGoAgain => 'எல்லாப் பாடங்களும் முடிந்தன · மீண்டும்';

  @override
  String chapterResumeCard(int current, int total) {
    return 'தொடர் · அட்டை $current / $total';
  }

  @override
  String get chapterNextLesson => 'அடுத்த பாடம்';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'பாடம் $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes சரி';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'விரைவில் · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'பாடங்கள் முடிந்தன · இப்போது தேர்வு';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'முடிந்தது · தேர்வு $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return ' · $count விரைவில்';
  }

  @override
  String get chapterNotInBoardExamSuffix => ' · போர்டு தேர்வில் இல்லை';

  @override
  String get chapterReportGreat => 'அருமை';

  @override
  String get chapterReportGood => 'நன்றாகப் போகிறது';

  @override
  String get chapterReportRetry => 'மீண்டும் முயலு';

  @override
  String get chapterReportByLesson => 'பாடம் வாரியாக';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'தவறியதை மறுபார்வை செய்';

  @override
  String get chapterAddToFolderAction => 'அத்தியாயத்தைக் கோப்புறையில் சேர்';

  @override
  String get chapterBackToChapter => 'அத்தியாயத்திற்குத் திரும்பு';

  @override
  String get chapterNoChaptersYet =>
      'உன் வகுப்புக்கு அத்தியாயங்கள் இன்னும் இல்லை.';

  @override
  String get chapterAlreadyInFolder => 'ஏற்கனவே இந்தக் கோப்புறையில்';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done முடிந்தது';
  }

  @override
  String get chapterPickChapters => 'அத்தியாயங்கள் தேர்வு செய்';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count அத்தியாயங்கள்',
      one: '1 அத்தியாயம்',
    );
    return '$_temp0 சேர்';
  }

  @override
  String get chapterAddChaptersTitle => 'அத்தியாயங்கள் சேர்';

  @override
  String get deckReportTitle => 'இந்தப் பாடத்தைப் புகார் செய்';

  @override
  String get deckReportThanks => 'நன்றி. இந்தப் பாடத்தைப் பார்ப்போம்.';

  @override
  String get deckLoadError => 'பாடம் ஏறவில்லை. மீண்டும் முயலு';

  @override
  String get deckPerfect => 'சரியான பாடம்!';

  @override
  String get deckLessonDone => 'பாடம் முடிந்தது!';

  @override
  String get deckStatRight => 'சரி';

  @override
  String get deckStatKept => 'வைத்தவை';

  @override
  String deckNextTitle(String title) {
    return 'அடுத்து: $title';
  }

  @override
  String get deckStart => 'தொடங்கு';

  @override
  String deckShowStep(int step) {
    return 'படி $step காட்டு';
  }

  @override
  String get deckCheck => 'சரிபார்';

  @override
  String get deckNext => 'அடுத்து';

  @override
  String get deckFinish => 'முடி';

  @override
  String get deckPreviousCard => 'முந்தைய அட்டை';

  @override
  String get deckNewLesson => 'புதிய பாடம்';

  @override
  String get deckByTheEnd => 'முடிவில் நீ செய்ய முடியும்:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · சுமார் $minutes நிமி';
  }

  @override
  String get deckConcept => 'கருத்து';

  @override
  String get deckInOneLook => 'ஒரே பார்வையில்';

  @override
  String get deckSummary => 'சுருக்கம்';

  @override
  String get deckThreeLines => 'பாடம் மூன்று வரிகளில்';

  @override
  String get deckKeptForRevision => 'மறுபார்வைக்கு வைத்தோம்';

  @override
  String get deckKeptRevisionOne =>
      'இந்தப் பாடத்திலிருந்து 1 அட்டை மறுபார்வையில் வரும்.';

  @override
  String deckKeptRevisionMany(int count) {
    return 'இந்தப் பாடத்திலிருந்து $count அட்டைகள் மறுபார்வையில் வரும்.';
  }

  @override
  String get deckWorkedExample => 'தீர்த்த எடுத்துக்காட்டு';

  @override
  String deckStepTryFirst(int step) {
    return 'படி $step · முதலில் நீயே முயலு';
  }

  @override
  String get deckRemember => 'நினைவில் வை';

  @override
  String get deckKept => 'வைத்தோம்';

  @override
  String get deckAskPebby => 'பெப்பியிடம் கேள்';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'இதை இன்னும் எளிதாகச் சொல்லு? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return '\"$title\"-ஐ எடுத்துக்காட்டுடன் சொல்லு?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'இதை எப்படித் தீர்ப்பது என்று சொல்லு: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'இது தவறு: $question சரியானது ஏன்: $why';
  }

  @override
  String get deckAskExplainLesson => 'இந்தப் பாடத்தைச் சொல்லு?';

  @override
  String get deckGoals => 'இலக்குகள்';

  @override
  String get quizQuickCheck => 'விரைவுச் சோதனை';

  @override
  String quizQuestionOf(int current, int total) {
    return 'கேள்வி $current / $total';
  }

  @override
  String get quizPraise1 => 'நன்று! சரி.';

  @override
  String get quizPraise2 => 'மிகச் சரி!';

  @override
  String get quizPraise3 => 'கிடைத்துவிட்டது!';

  @override
  String get quizPraise4 => 'சரி, நல்லா இருக்கு!';

  @override
  String get quizPraise5 => 'சரியாகவே இருக்கிறது!';

  @override
  String get quizHeresWhy => 'ஏனெனில்';

  @override
  String get quizYourAnswer => 'உன் பதில்';

  @override
  String get quizRightAnswer => 'சரியான பதில்';

  @override
  String get quizKeptForYou => 'உனக்காக வைத்தோம்';

  @override
  String get quizComesBack => 'இந்தக் கேள்வி நாளை மறுபார்வையில் வரும்.';

  @override
  String get quizNotQuite => 'சரியில்லை. அடுத்து: ஏன்.';

  @override
  String quizStreak(int count) {
    return '$count தொடர்ச்சியாக';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'மறுபார்வை';

  @override
  String get studyRevisionEmptyTitle => 'மறுபார்வைக்கு ஒன்றுமில்லை';

  @override
  String get studyRevisionEmptyBody =>
      'பாடத்தில் அட்டைகளை Keep செய், அல்லது கேள்வி தவறினால் இங்கே வரும்.';

  @override
  String get studyRevisionDone => 'மறுபார்வை முடிந்தது';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew தெரியும் · $almost கிட்டத்தட்ட · $again நாளை மீண்டும்';
  }

  @override
  String get studyRevisionHint => 'பதிலை யோசி, சரிபார்க்க தட்டவும்.';

  @override
  String get studyRevisionShowAnswer => 'பதிலைக் காட்டு';

  @override
  String get studyRevisionAgain => 'தெரியவில்லை';

  @override
  String get studyRevisionAlmost => 'கிட்டத்தட்ட';

  @override
  String get studyRevisionKnew => 'தெரியும்';

  @override
  String chapterTestDeckTitle(int number) {
    return 'அத்தியாயம் $number தேர்வு';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count பாடங்களில்',
      one: '1 பாடத்தில்',
    );
    return '$_temp0 $done';
  }

  @override
  String get actionTryAgain => 'மீண்டும் முயலு';

  @override
  String get actionGoPro => 'Pro வாங்கு';

  @override
  String get actionBack => 'பின்';

  @override
  String get actionClose => 'மூடு';

  @override
  String get failureNetwork =>
      'இணைப்பு இல்லை. இணையத்தைப் பார்த்து மீண்டும் முயலு.';

  @override
  String get failureUnknown => 'ஏதோ தவறு நடந்தது. மீண்டும் முயலு.';
}
