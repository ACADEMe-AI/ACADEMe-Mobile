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

  @override
  String get loginHeadlineLead => 'फिर से';

  @override
  String get loginHeadlineAccent => 'स्वागत है।';

  @override
  String get loginSubtitle => 'जहाँ छोड़ा था वहीं से जारी रखो।';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authShowPassword => 'पासवर्ड दिखाएँ';

  @override
  String get authHidePassword => 'पासवर्ड छिपाएँ';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authLoggingIn => 'लॉग इन हो रहा है…';

  @override
  String get authNewHere => 'नए हो? ';

  @override
  String get forgotPasswordLead => 'पासवर्ड';

  @override
  String get forgotPasswordAccent => 'भूल गए?';

  @override
  String get forgotPasswordSubtitle =>
      'अपना ईमेल लिखो, मैं 6 अंकों का कोड भेजूँगा।';

  @override
  String get authSending => 'भेजा जा रहा है…';

  @override
  String get authSendCode => 'कोड भेजें';

  @override
  String get resetCodeLead => 'अपना';

  @override
  String get resetCodeAccent => 'ईमेल देखो।';

  @override
  String resetCodeSubtitle(String email) {
    return 'अगर $email पर ACADEMe अकाउंट है, तो 6 अंकों का कोड आ रहा है। यह 15 मिनट में खत्म हो जाएगा।';
  }

  @override
  String get authPasteCode => 'कोड पेस्ट करें';

  @override
  String get authChecking => 'जाँच हो रही है…';

  @override
  String get authVerify => 'वेरिफाई';

  @override
  String get resetDidntGetIt => 'नहीं मिला? ';

  @override
  String get resetSendNewCode => 'नया कोड भेजें';

  @override
  String get resetSendingNewCode => 'नया कोड भेजा जा रहा है…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'नया कोड भेज दिया। फिर माँग सकते हो 0:$seconds में';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'नया कोड 0:$seconds में माँग सकते हो';
  }

  @override
  String get newPasswordLead => 'नया';

  @override
  String get newPasswordAccent => 'पासवर्ड चुनो।';

  @override
  String get newPasswordSubtitle =>
      'कम से कम 8 अक्षर। चिंता मत करो, मैं नहीं देखूँगा।';

  @override
  String get authNewPassword => 'नया पासवर्ड';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ अक्षर';
  }

  @override
  String get authStartAgain => 'फिर से शुरू करें';

  @override
  String get authSaving => 'सेव हो रहा है…';

  @override
  String get authSaveAndLogIn => 'सेव करके लॉग इन';

  @override
  String get authFailureEmailTaken =>
      'इस ईमेल पर पहले से अकाउंट है। लॉग इन करो।';

  @override
  String get authFailureWrongCredentials => 'ईमेल और पासवर्ड मेल नहीं खाते।';

  @override
  String get authFailureInvalidInput => 'अपनी जानकारी जाँचकर फिर कोशिश करो।';

  @override
  String get authFailureSignedOut => 'सेशन खत्म हो गया। फिर लॉग इन करो।';

  @override
  String get authFailureNetwork =>
      'ACADEMe तक पहुँच नहीं पा रहे। कनेक्शन जाँचकर फिर कोशिश करो।';

  @override
  String get authFailureCanceled => 'साइन-इन रद्द हो गया।';

  @override
  String get authFailureProviderUnavailable =>
      'यह साइन-इन विकल्प अभी तैयार नहीं है। अभी ईमेल इस्तेमाल करो।';

  @override
  String get authFailureWrongCode =>
      'कोड सही नहीं है। ईमेल जाँचकर फिर कोशिश करो।';

  @override
  String get authFailureTooManyAttempts => 'बहुत गलत कोशिशें। नया कोड मँगाओ।';

  @override
  String get authFailureCodeExpired => 'कोड की समय सीमा खत्म। नया कोड मँगाओ।';

  @override
  String get authFailureResetExpired =>
      'रीसेट लिंक की समय सीमा खत्म। पासवर्ड भूल गए से फिर शुरू करो।';

  @override
  String get authFailureTooManyRequests =>
      'बहुत कोशिशें हो गईं। थोड़ा रुककर फिर कोशिश करो।';

  @override
  String get authFailureWrongPassword => 'यह तुम्हारा मौजूदा पासवर्ड नहीं है।';

  @override
  String get authFailureGoogleTaken =>
      'यह Google अकाउंट किसी और ACADEMe अकाउंट से जुड़ा है।';

  @override
  String get authFailurePasswordRequired =>
      'पहले पासवर्ड सेट करो, ताकि Google के बिना भी लॉग इन कर सको।';

  @override
  String get signUpHiPebby => 'नमस्ते, मैं पेबी हूँ!';

  @override
  String signUpHiNamed(String name) {
    return 'नमस्ते $name, मैं पेबी हूँ!';
  }

  @override
  String get signUpAskFirstName => 'शुरू करने से पहले, मैं तुम्हें क्या कहूँ?';

  @override
  String get signUpFirstName => 'पहला नाम';

  @override
  String signUpAskLastName(String name) {
    return 'मिलकर अच्छा लगा, $name! और तुम्हारा अंतिम नाम?';
  }

  @override
  String get signUpLastName => 'अंतिम नाम';

  @override
  String signUpAskEmail(String name) {
    return 'तुम्हारा ईमेल क्या है, $name?';
  }

  @override
  String get signUpEmailHint => 'लॉग इन के लिए यही इस्तेमाल होगा।';

  @override
  String get signUpEmailInvalid => 'यह अभी ईमेल जैसा नहीं लग रहा।';

  @override
  String get signUpCreatePassword => 'पासवर्ड बनाओ';

  @override
  String signUpPasswordHint(int count) {
    return 'कम से कम $count अक्षर। चिंता मत करो, मैं नहीं देखूँगा।';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'वापस स्वागत है, $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'तुम्हारा अकाउंट पहले से है, इसलिए तुम लॉग इन हो।';

  @override
  String signUpYoureIn(String name) {
    return 'तुम अंदर हो, $name!';
  }

  @override
  String get signUpAccountReady =>
      'अकाउंट तैयार है। अब बताओ तुम क्या पढ़ते हो।';

  @override
  String get signUpHelloEmail =>
      'मैं स्मार्ट पढ़ाई में मदद करूँगा। अकाउंट सेट करते हैं, एक मिनट लगेगा।';

  @override
  String get signUpConnectingAccount => 'अकाउंट जोड़ा जा रहा है…';

  @override
  String get signUpCheckName => 'नाम जाँचते हैं, फिर तुम अंदर।';

  @override
  String get signUpConnecting => 'जुड़ रहा है…';

  @override
  String get signUpHiPebbyAction => 'नमस्ते पेबी!';

  @override
  String get signUpCreatingAccount => 'अकाउंट बन रहा है…';

  @override
  String get signUpCreateAccount => 'अकाउंट बनाएँ';

  @override
  String get signUpLetsGo => 'चलो शुरू करें';

  @override
  String get authContinue => 'जारी रखें';

  @override
  String get homeSetupTitle => 'अपना डैशबोर्ड सेट करो';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'भाषा';

  @override
  String get homeSetupTaskAge => 'तुम्हारी उम्र';

  @override
  String get homeSetupTaskClass => 'तुम्हारी कक्षा';

  @override
  String get homeSetupTaskBoard => 'तुम्हारा बोर्ड';

  @override
  String get homeSetupTaskSubjects => 'तुम्हारे विषय';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'होमवर्क हल करो';

  @override
  String get homeCheckAnswer => 'जवाब जाँचो';

  @override
  String get homeFlashcards => 'फ्लैशकार्ड्स';

  @override
  String get homePickSubjects => 'अपने विषय चुनो';

  @override
  String homePickSubjectsBody(int xp) {
    return 'होम और स्टडी में वही विषय दिखेंगे जो तुम पढ़ते हो। +$xp XP';
  }

  @override
  String get setupLanguageTitle => 'तुम किस भाषा में पढ़ते हो?';

  @override
  String setupChooseLanguage(String name) {
    return '$name चुनो';
  }

  @override
  String get setupLanguageFootnote => 'सेटिंग्स में कभी भी बदल सकते हो।';

  @override
  String get setupAgeTitle => 'तुम कब पैदा हुए?';

  @override
  String get setupAgeSubtitle => 'ताकि उम्र के हिसाब से सही रख सकें।';

  @override
  String get setupBirthYear => 'जन्म वर्ष';

  @override
  String setupYouAreAge(int age) {
    return 'तुम्हारी उम्र $age है।';
  }

  @override
  String get setupClassTitle => 'अपनी कक्षा चुनो';

  @override
  String get setupClassSubtitle => 'डायल घुमाओ या नंबर टैप करो।';

  @override
  String setupImInClass(int level) {
    return 'मैं कक्षा $level में हूँ';
  }

  @override
  String get setupBoardTitle => 'कौन सा बोर्ड?';

  @override
  String get setupBoardSubtitle => 'हम तुम्हारे बोर्ड के सिलेबस पर चलते हैं।';

  @override
  String get setupStateBoardsSoon => 'राज्य बोर्ड जल्द आ रहे हैं।';

  @override
  String get setupFinish => 'सेटअप पूरा करें';

  @override
  String setupProgress(int step, int total) {
    return 'सेट अप · $step/$total';
  }

  @override
  String get setupLater => 'बाद में';

  @override
  String get setupChangeInMe => 'मी में कभी भी बदल सकते हो।';

  @override
  String setupStreamTitle(int level) {
    return 'कक्षा $level में तुम क्या पढ़ते हो?';
  }

  @override
  String get setupAnythingElse => 'और कुछ?';

  @override
  String get setupWhichSubjects => 'तुम कौन से विषय पढ़ते हो?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus. मुख्य विषय लग गए।';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus. जो नहीं पढ़ते उन्हें हटाओ।';
  }

  @override
  String get homeYourSubjects => 'तुम्हारे विषय';

  @override
  String get homeEdit => 'एडिट';

  @override
  String get homeSubjectsNeedSyllabus =>
      'विषय देखने के लिए कक्षा और बोर्ड सेट करो';

  @override
  String get homeSubjectsLoading => 'विषय लोड हो रहे हैं…';

  @override
  String get homeSubjectsSoon => 'तुम्हारे विषय यहाँ जल्द दिखेंगे।';

  @override
  String homeNextChapter(int number, String title) {
    return 'अगला: अध्याय $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'सभी पाठ पूरे';

  @override
  String get homeLessonsComingSoon => 'पाठ जल्द आ रहे हैं';

  @override
  String homeTodayMinutes(int minutes) {
    return 'आज · $minutes मिनट';
  }

  @override
  String get homeTodayDone => 'आज · सब हो गया';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़ोल्डर से',
      one: '1 फ़ोल्डर से',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'और $count तुम्हारे फ़ोल्डर में';
  }

  @override
  String get homeAskHintTitle => 'पेबी से कुछ भी पूछो';

  @override
  String get homeAskHintBody =>
      'सवाल टाइप करो, या होमवर्क हल करो पर टैप करके फोटो लो।';

  @override
  String get homeAskHintGotIt => 'समझ गया';

  @override
  String get homeDashboardLoadError => 'डैशबोर्ड लोड नहीं हो सका।';

  @override
  String get homeRetry => 'फिर कोशिश';

  @override
  String get helloFallbackName => 'दोस्त';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन की स्ट्रीक',
      one: '1 दिन की स्ट्रीक',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'नोट्स फ़ोल्डर में';

  @override
  String get scanModeAsk => 'फ़ोटो के बारे में पूछो';

  @override
  String get scanWhatsOnPaper => 'कागज़ पर क्या है?';

  @override
  String get scanHintSolve => 'पहले संकेत';

  @override
  String get scanHintCheck => 'बोर्ड-स्टाइल मार्क्स';

  @override
  String get scanHintNotes => 'पेज से पाठ';

  @override
  String get scanHintAsk => 'और कुछ भी';

  @override
  String get scanRecent => 'हाल के स्कैन';

  @override
  String get scanStatusRead => 'पढ़ लिया';

  @override
  String get scanStatusSolvedInAskMe => 'ASKMe में हल किया';

  @override
  String get scanStatusAskedInAskMe => 'ASKMe में पूछा';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मार्क्स',
      one: '1 मार्क',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'अभी मार्क नहीं हुए';

  @override
  String get scanStatusLessonInFolder => 'फ़ोल्डर में पाठ';

  @override
  String get scanStatusNotesInFolder => 'फ़ोल्डर में नोट्स';

  @override
  String get scanStatusNotSaved => 'अभी सेव नहीं';

  @override
  String get scanSourceNotesBlurb =>
      'ज़्यादा से ज़्यादा 10 पेज। सिर्फ टेक्स्ट रहता है, फ़ोटो नहीं।';

  @override
  String get scanSourceBlurb => 'सिर्फ टेक्स्ट रहता है, फ़ोटो नहीं।';

  @override
  String get scanTakePhoto => 'फ़ोटो लो';

  @override
  String get scanChooseGallery => 'गैलरी से चुनो';

  @override
  String get scanCamera => 'कैमरा';

  @override
  String get scanGallery => 'गैलरी';

  @override
  String get scanYourPages => 'तुम्हारे पेज';

  @override
  String scanPagesOf(int current, int max) {
    return '$current / $max';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज पढ़ो',
      one: '1 पेज पढ़ो',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'पेज हटाओ';

  @override
  String get scanYourNotes => 'तुम्हारे नोट्स';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'पेबी ने $count पेज पढ़े',
      one: 'पेबी ने 1 पेज पढ़ा',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'ये कहाँ जाएँ?';

  @override
  String get scanChooseFolder => 'फ़ोल्डर चुनो';

  @override
  String get scanChange => 'बदलो';

  @override
  String get scanMakeFromNotes => 'नोट्स से बनाओ';

  @override
  String get scanSwipeLesson => 'स्वाइप पाठ';

  @override
  String get scanSwipeLessonSubtitle =>
      'कार्ड्स और छोटी जाँच, प्लान में जुड़ेंगे';

  @override
  String get scanKeepNotes => 'सिर्फ नोट्स रखो';

  @override
  String get scanKeepNotesSubtitle => 'टेक्स्ट फ़ोल्डर में चला जाएगा';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज पढ़ रहा हूँ…',
      one: 'तुम्हारा पेज पढ़ रहा हूँ…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'कुछ सेकंड लगेंगे।';

  @override
  String get scanMakingLesson => 'तुम्हारा पाठ बना रहा हूँ…';

  @override
  String get scanSavingNotes => 'तुम्हारे नोट्स सेव हो रहे हैं…';

  @override
  String get scanSavingWait => 'ये तुम्हारे फ़ोल्डर में होंगे।';

  @override
  String get scanFailUnavailableTitle => 'स्कैन अभी तैयार नहीं';

  @override
  String get scanFailUnavailableBody =>
      'पेबी अभी फ़ोटो नहीं पढ़ सकता। बाद में फिर कोशिश करो।';

  @override
  String get scanFailNoTextTitle => 'यहाँ कोई शब्द नहीं';

  @override
  String get scanFailNoTextBody =>
      'कैमरा होमवर्क, किताब के पेज या नोट्स पर रखो।';

  @override
  String get scanFailTooLargeTitle => 'बहुत बड़ी फ़ोटो हैं';

  @override
  String get scanFailTooLargeBody => 'एक साथ कम पेज आज़माओ।';

  @override
  String get scanFailNetworkTitle => 'तुम ऑफ़लाइन हो';

  @override
  String get scanFailNetworkBody => 'इंटरनेट जाँचकर फिर कोशिश करो।';

  @override
  String get scanFailScanLimitTitle => 'आज के मुफ़्त स्कैन खत्म';

  @override
  String get scanFailScanLimitBody =>
      'आधी रात को वापस मिलेंगे। जितना चाहो स्कैन करने के लिए Pro लो।';

  @override
  String get scanFailCheckLimitTitle => 'आज की मुफ़्त जाँच खत्म';

  @override
  String get scanFailCheckLimitBody =>
      'आधी रात को वापस मिलेगी। हर जवाब जाँचने के लिए Pro लो।';

  @override
  String get scanFailProOnlyTitle => 'नोट्स से पाठ Pro है';

  @override
  String get scanFailProOnlyBody =>
      'मुफ़्त में नोट्स रखो, या Pro लो और पेबी उनसे पाठ बनाए।';

  @override
  String get scanFailUnknownTitle => 'पेबी इसे नहीं पढ़ पाया';

  @override
  String get scanFailUnknownBody =>
      'फिर कोशिश करो, या बेहतर रोशनी में फ़ोटो दोबारा लो।';

  @override
  String get scanBackToAnswer => 'अपने जवाब पर वापस';

  @override
  String get scanRetake => 'फिर से लो';

  @override
  String get scanCameraOpenFailed => 'कैमरा नहीं खुल सका। गैलरी आज़माओ।';

  @override
  String get scanPebbyReadThis => 'पेबी ने ये पढ़ा';

  @override
  String get scanFixAnything => 'जो गलत हो उसे ठीक करो।';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · जो गलत हो उसे ठीक करो।';
  }

  @override
  String get scanFromYourPhoto => 'तुम्हारी फ़ोटो से';

  @override
  String get scanFromMyPhoto => 'मेरी फ़ोटो से:';

  @override
  String get scanWhatDoYouWant => 'तुम क्या जानना चाहते हो?';

  @override
  String get scanSuggestExplain => 'इसे आसान भाषा में समझाओ';

  @override
  String get scanSuggestSummarise => 'सार बताओ';

  @override
  String get scanSuggestKeyTerms => 'मुख्य शब्द क्या हैं?';

  @override
  String get scanSolveThis => 'इसे हल करो';

  @override
  String get scanAskPebby => 'पेबी से पूछो';

  @override
  String get scanHintFirst => 'पेबी पहले संकेत देता है, फिर स्टेप्स।';

  @override
  String get checkPebbyReadAnswer => 'पेबी ने तुम्हारा जवाब पढ़ा';

  @override
  String get checkTheQuestion => 'सवाल';

  @override
  String get checkQuestionHint => 'सिर्फ अगर फ़ोटो में नहीं है';

  @override
  String get checkMarkIt => 'मार्क करो';

  @override
  String get checkMarkingAnswer => 'तुम्हारा जवाब मार्क हो रहा है…';

  @override
  String get checkMarkingScheme => 'बोर्ड की मार्किंग स्कीम से।';

  @override
  String get checkFullMarks => 'फुल मार्क्स!';

  @override
  String get checkNearlyThere => 'लगभग पहुँच गए';

  @override
  String get checkKeepGoing => 'लगे रहो';

  @override
  String get checkReportTitle => 'इन मार्क्स की रिपोर्ट करो';

  @override
  String get checkReportThanks => 'धन्यवाद। हम इन मार्क्स की जाँच करेंगे।';

  @override
  String get checkWhatGotMarks => 'किस पर मार्क्स मिले';

  @override
  String get checkWellDone => 'शाबाश';

  @override
  String get checkForFullMarks => 'फुल मार्क्स के लिए';

  @override
  String get checkAgain => 'फिर जाँचो';

  @override
  String get checkShowModelAnswer => 'मॉडल जवाब दिखाओ';

  @override
  String get checkHideModelAnswer => 'मॉडल जवाब छिपाओ';

  @override
  String checkAskQuestion(String question) {
    return 'सवाल: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'मेरा जवाब:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'मुझे $awarded/$marks मिले। फुल मार्क्स कैसे लाऊँ?';
  }

  @override
  String get meLearningSection => 'पढ़ाई';

  @override
  String get meMyProgress => 'मेरी प्रगति';

  @override
  String get meClassAndBoard => 'कक्षा और बोर्ड';

  @override
  String get meAppearance => 'दिखावट';

  @override
  String get meNotificationsSection => 'सूचनाएँ';

  @override
  String get meRemindersAndDailyGoal => 'रिमाइंडर और रोज़ाना लक्ष्य';

  @override
  String get meAccountSection => 'अकाउंट';

  @override
  String get meAccount => 'अकाउंट';

  @override
  String get meHelpAndFeedback => 'मदद और फ़ीडबैक';

  @override
  String get mePrivacyAndTerms => 'गोपनीयता और शर्तें';

  @override
  String get meLogOut => 'लॉग आउट';

  @override
  String get meLoggingOut => 'लॉग आउट हो रहा है…';

  @override
  String get meStudentFallback => 'स्टूडेंट';

  @override
  String get meDayStreak => 'दिन की स्ट्रीक';

  @override
  String meLevelValue(int number) {
    return 'Lv $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return 'Lv $level तक $xp XP';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'ठीक';

  @override
  String meOkSwitchTo(String name) {
    return 'ठीक · $name पर स्विच करो';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting अब पेबी $name में जवाब देगा।';
  }

  @override
  String get meLanguageSwitchFailed => 'भाषा नहीं बदल सकी। फिर कोशिश करो।';

  @override
  String meOpenInBrowser(String url) {
    return 'ब्राउज़र में $url खोलो';
  }

  @override
  String get meNotSet => 'सेट नहीं';

  @override
  String get meOff => 'बंद';

  @override
  String meClassOnly(int level) {
    return 'कक्षा $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'कक्षा $level · $board';
  }

  @override
  String get meLogOutTitle => 'लॉग आउट?';

  @override
  String get meLogOutBody =>
      'तुम्हारी प्रगति अकाउंट में सेव है। कभी भी फिर लॉग इन कर सकते हो।';

  @override
  String get meLogOutStay => 'रहो';

  @override
  String get accountSaveName => 'नाम सेव करो';

  @override
  String get accountNameSaved => 'नाम सेव हो गया';

  @override
  String get accountDangerZone => 'खतरनाक ज़ोन';

  @override
  String get accountDeleteMyAccount => 'मेरा अकाउंट मिटाओ';

  @override
  String get accountDeleteGraceNote =>
      'अकाउंट माँगने के 30 दिन बाद मिटता है। तब तक लॉग इन करके बचा सकते हो।';

  @override
  String get accountSignIn => 'साइन-इन';

  @override
  String get accountChangePassword => 'पासवर्ड बदलो';

  @override
  String get accountSetPassword => 'पासवर्ड सेट करो';

  @override
  String get accountLinkGoogle => 'Google लिंक करो';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'लिंक हो रहा है…';

  @override
  String get accountUnlinking => 'अनलिंक हो रहा है…';

  @override
  String get accountNotLinked => 'लिंक नहीं';

  @override
  String get accountGoogleLinked =>
      'Google लिंक हो गया। अब इससे लॉग इन कर सकते हो।';

  @override
  String get accountGoogleUnlinked =>
      'Google अनलिंक हो गया। ईमेल और पासवर्ड से लॉग इन करो।';

  @override
  String get accountUnlinkGoogleTitle => 'Google अनलिंक करें?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'अब $email से लॉग इन नहीं कर पाओगे। ईमेल और पासवर्ड इस्तेमाल करो।';
  }

  @override
  String get accountKeepGoogle => 'Google रखो';

  @override
  String get accountUnlink => 'अनलिंक';

  @override
  String get passwordSave => 'पासवर्ड सेव करो';

  @override
  String get passwordChangeBody =>
      'साइन अप जैसी ही शर्तें। सेव करते ही बाकी डिवाइस लॉग आउट हो जाते हैं।';

  @override
  String get passwordSetBody =>
      'पासवर्ड जोड़ो ताकि सिर्फ़ Google नहीं, ईमेल से भी लॉग इन कर सको।';

  @override
  String get passwordCurrent => 'अभी का पासवर्ड';

  @override
  String get passwordChangedSnack =>
      'पासवर्ड बदल गया। बाकी डिवाइस लॉग आउट हो गए।';

  @override
  String get passwordSetSnack =>
      'पासवर्ड सेट हो गया। अब ईमेल से भी लॉग इन कर सकते हो।';

  @override
  String get deleteAccountTitle => 'अकाउंट मिटाओ';

  @override
  String get deleteDeleting => 'मिटाया जा रहा है…';

  @override
  String get deleteSorryTitle => 'तुम्हें जाते देख दुख हो रहा है';

  @override
  String get deleteBody =>
      'तुम्हारा अकाउंट 30 दिन में मिट जाएगा। तब तक फिर लॉग इन करके बचा सकते हो। 30 दिन बाद प्रोफ़ाइल, चैट, प्रगति और XP हमेशा के लिए मिट जाते हैं।';

  @override
  String get deleteSubscription => 'सब्सक्रिप्शन';

  @override
  String get deleteSubscriptionNotice =>
      'अकाउंट मिटाने से Google Play पर ख़रीदा ACADEMe Pro सब्सक्रिप्शन रद्द नहीं होता। दोबारा चार्ज न हो, इसके लिए Google Play में रद्द करो।';

  @override
  String get deleteManageSubscription => 'सब्सक्रिप्शन मैनेज करो';

  @override
  String get deleteWhyLeaving => 'क्यों जा रहे हो? (वैकल्पिक)';

  @override
  String deleteConfirmLabel(String word) {
    return 'कन्फ़र्म करने के लिए $word लिखो';
  }

  @override
  String get deleteReasonNotEnough => 'काफ़ी इस्तेमाल नहीं करता/करती';

  @override
  String get deleteReasonDidntHelp => 'पढ़ाई में मदद नहीं मिली';

  @override
  String get deleteReasonTooManyNotifs => 'बहुत ज़्यादा सूचनाएँ';

  @override
  String get deleteReasonDataWorry => 'डेटा को लेकर चिंता है';

  @override
  String get deleteReasonOther => 'कुछ और';

  @override
  String deleteScheduledSnack(String date) {
    return 'तुम्हारा अकाउंट $date को मिट जाएगा। तब तक लॉग इन करके बचा सकते हो।';
  }

  @override
  String get notifRemindersAndGoalTitle => 'रिमाइंडर और लक्ष्य';

  @override
  String get notifStudyReminder => 'पढ़ाई का रिमाइंडर';

  @override
  String get notifRemindMeToStudy => 'पढ़ने की याद दिलाओ';

  @override
  String get notifTime => 'समय';

  @override
  String get notifRemindMeAt => 'इतने बजे याद दिलाओ';

  @override
  String get notifAlsoTellMe => 'ये भी बताओ';

  @override
  String get notifStreakAboutToEnd => 'जब स्ट्रीक खत्म होने वाली हो';

  @override
  String get notifEveningBeforeTest => 'टेस्ट से एक शाम पहले';

  @override
  String get notifWhenLevelUp => 'जब लेवल बढ़े';

  @override
  String get notifNotifications => 'सूचनाएँ';

  @override
  String get notifAllowed => 'अनुमति है';

  @override
  String get notifNotAllowed => 'अनुमति नहीं';

  @override
  String get notifTurnOn => 'सूचनाएँ चालू करो';

  @override
  String get notifTurnOnInSettings => 'सेटिंग्स में चालू करो';

  @override
  String get reminderTimeTitle => 'रिमाइंडर का समय';

  @override
  String get reminderHour => 'घंटा';

  @override
  String get reminderMinute => 'मिनट';

  @override
  String get reminderAmPm => 'सुबह या शाम';

  @override
  String get reminderAm => 'am';

  @override
  String get reminderPm => 'pm';

  @override
  String get dailyGoalTitle => 'रोज़ाना लक्ष्य';

  @override
  String dailyGoalNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes मिनट',
      one: '1 मिनट',
    );
    return 'होम पर आज के स्टेप्स लगभग $_temp0 तक जुड़ेंगे।';
  }

  @override
  String get dailyGoalSemantics => 'मिनट में रोज़ाना लक्ष्य';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes मि';
  }

  @override
  String get dailyGoalStudyEachDay => 'हर दिन पढ़ो';

  @override
  String get appearanceTheme => 'थीम';

  @override
  String get appearanceLight => 'लाइट';

  @override
  String get appearanceDark => 'डार्क';

  @override
  String get appearanceDarkHint => 'रात में डार्क मोड आँखों को आराम देता है।';

  @override
  String get appearanceLightsOff => 'लाइट्स बंद…';

  @override
  String get appearanceGoodMorning => 'सुप्रभात!';

  @override
  String get appearanceDimming => 'पेबी कमरा मंद कर रहा है';

  @override
  String get appearanceOpeningCurtains => 'पेबी पर्दे खोल रहा है';

  @override
  String get helpTellUs => 'हमें बताओ';

  @override
  String get helpEmailUs => 'हमें ईमेल करो';

  @override
  String get helpThanks => 'धन्यवाद, हमें तुम्हारा संदेश मिल गया।';

  @override
  String get feedbackWrongAnswer => 'गलत जवाब रिपोर्ट करो';

  @override
  String get feedbackBug => 'कुछ काम नहीं कर रहा';

  @override
  String get feedbackFeature => 'कोई फीचर सुझाओ';

  @override
  String get feedbackHint => 'क्या हुआ बताओ (कम से कम 10 अक्षर)।';

  @override
  String get feedbackSend => 'भेजो';

  @override
  String get feedbackLimitNote =>
      'दिन में 2 और हफ़्ते में 5 संदेश भेज सकते हो।';

  @override
  String get feedbackFailGeneric => 'नहीं भेज सके। फिर कोशिश करो।';

  @override
  String get feedbackFailDay =>
      'आज जितना फ़ीडबैक ले सकते थे, ले लिया। कल फिर कोशिश करो।';

  @override
  String get feedbackFailWeek =>
      'इस हफ़्ते जितना फ़ीडबैक ले सकते थे, ले लिया। अगले हफ़्ते फिर कोशिश करो।';

  @override
  String get feedbackFailTooShort => 'मदद के लिए कम से कम 10 अक्षर लिखो।';

  @override
  String get feedbackFailOffline =>
      'तुम ऑफ़लाइन हो। कनेक्शन जाँचकर फिर कोशिश करो।';

  @override
  String get privacySummary1 =>
      'ACADEMe चलाने के लिए हम तुम्हारा अकाउंट, कक्षा, बोर्ड और विषय, पढ़ाई की प्रगति और स्ट्रीक, फ़ोल्डर, नोट्स और पेबी चैट रखते हैं।';

  @override
  String get privacySummary2 =>
      'तुम्हारे सवाल और स्कैन की गई फ़ोटो भारत में Sarvam AI को जाती हैं ताकि पेबी जवाब दे सके। हम फ़ोटो नहीं रखते, सिर्फ़ उनमें से पढ़ा टेक्स्ट।';

  @override
  String get privacySummary3 =>
      'कोई विज्ञापन नहीं, कोई ऐड ID नहीं, लोकेशन नहीं, और हम तुम्हारा डेटा कभी नहीं बेचते।';

  @override
  String get privacySummary4 =>
      'अकाउंट में कभी भी अकाउंट मिटा सकते हो। 30 दिन बाद सब मिट जाता है।';

  @override
  String get privacyDocuments => 'दस्तावेज़';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get privacyTermsOfUse => 'उपयोग की शर्तें';

  @override
  String get privacyYourData => 'तुम्हारा डेटा';

  @override
  String get privacyGetCopy => 'मेरे डेटा की कॉपी लो';

  @override
  String get privacyGrievanceOfficer => 'शिकायत अधिकारी';

  @override
  String classBoardSave(int level, String board) {
    return 'सेव · कक्षा $level · $board';
  }

  @override
  String get classBoardYourClass => 'तुम्हारी कक्षा';

  @override
  String get classBoardYourBoard => 'तुम्हारा बोर्ड';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'तुम्हारे विषय और प्लान कक्षा $level · $board पर स्विच होंगे। अब तक का सब सेव रहेगा।';
  }

  @override
  String get classBoardSubjects => 'विषय';

  @override
  String get classBoardStream => 'स्ट्रीम';

  @override
  String get classBoardAllSubjects => 'सभी विषय';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'अब कक्षा $level · $board के विषय दिख रहे हैं';
  }

  @override
  String get reminderPrimerTitle => 'टेस्ट से पहले एक झटका पाओ';

  @override
  String get reminderPrimerPromise1 =>
      'हर टेस्ट से 3 दिन पहले, शाम पहले और उसी सुबह याद';

  @override
  String get reminderPrimerPromise2 =>
      'पढ़ाई का रिमाइंडर, सिर्फ़ चुने हुए दिन और समय पर';

  @override
  String get reminderPrimerPromise3 => 'और कुछ नहीं। कभी भी Me में बदल सकते हो';

  @override
  String get reminderPrimerAllow => 'अनुमति दो';

  @override
  String get paywallWelcomeSnack => 'ACADEMe Pro में स्वागत है';

  @override
  String get paywallTagline =>
      'रोज़ और हफ़्ते की सीमाएँ 3×। वही रीफ़िल घड़ी — पढ़ने के लिए ज़्यादा जगह।';

  @override
  String get paywallOpeningPlay => 'Google Play खुल रहा है…';

  @override
  String get paywallRestoring => 'रीस्टोर हो रहा है…';

  @override
  String get paywallRestore => 'खरीदारी रीस्टोर करो';

  @override
  String get paywallUnavailableTitle => 'इस डिवाइस पर खरीदारी उपलब्ध नहीं है';

  @override
  String get paywallUnavailableBody =>
      'Pro लेने के लिए ACADEMe Google Play से इंस्टॉल करो और Play में साइन इन करो।';

  @override
  String get paywallBenefitAskme => 'हर दिन 3× ASKMe सवाल';

  @override
  String get paywallBenefitScan => 'हर दिन 3× स्कैन';

  @override
  String get paywallBenefitCheck => 'हर दिन 3× जवाब जाँच';

  @override
  String get paywallBenefitLessons => 'तुम्हारे नोट्स से स्वाइप पाठ';

  @override
  String get paywallBenefitProgress => 'माय प्रोग्रेस साप्ताहिक सारांश';

  @override
  String get paywallMonthly => 'मासिक';

  @override
  String get paywallAnnual => 'वार्षिक';

  @override
  String paywallPlanSemantics(String title) {
    return '$title प्लान';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return 'पहले महीने $introPrice, फिर $price/महीना';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/महीना';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/साल';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'लगभग $monthlyPrice/महीना · 17% बचाओ · अपने आप रिन्यू';
  }

  @override
  String get paywallDetailAnnual => '17% बचाओ · अपने आप रिन्यू';

  @override
  String get paywallDetailRenews => 'अपने आप रिन्यू होता है';

  @override
  String get paywallBestValue => 'सबसे बढ़िया वैल्यू';

  @override
  String get paywallSmallPrint =>
      'अपने आप रिन्यू। Google Play में कभी भी रद्द करो।';

  @override
  String get paywallTerms => 'शर्तें';

  @override
  String get paywallPrivacy => 'गोपनीयता';

  @override
  String get upgradeTitle => 'Pro लो · 3× सीमाएँ';

  @override
  String get limitAskmeTitle => 'आज के मुफ़्त सवाल पूरे';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ASKMe सवाल',
      one: '1 ASKMe सवाल',
    );
    return 'फ़्री में दिन में $_temp0। Pro हर दिन 3× देता है।';
  }

  @override
  String get limitScanTitle => 'आज के मुफ़्त स्कैन पूरे';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्कैन',
      one: '1 स्कैन',
    );
    return 'फ़्री में दिन में $_temp0। Pro हर दिन 3× देता है।';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आज की मुफ़्त जाँचें पूरी',
      one: 'आज की मुफ़्त जाँच पूरी',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जवाब जाँच',
      one: 'एक जवाब जाँच',
    );
    return 'फ़्री में दिन में $_temp0। Pro हर दिन 3× देता है।';
  }

  @override
  String get limitLessonsTitle => 'नोट्स से पाठ Pro में हैं';

  @override
  String get limitLessonsBody =>
      'नोट्स रखना मुफ़्त है। Pro में पेबी उन्हें क्विज़ वाले स्वाइप पाठ बना देता है।';

  @override
  String get limitMaybeLater => 'बाद में शायद';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'प्लान और सीमाएँ';

  @override
  String get proCardSubtitleFree => 'प्लान और सीमाएँ · Pro में 3×';

  @override
  String get proCardSubtitleMonthly => 'Pro · मासिक';

  @override
  String get proCardSubtitleAnnual => 'Pro · वार्षिक';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'मैनेज';

  @override
  String get proOnPro => 'तुम Pro पर हो';

  @override
  String get proOnFree => 'तुम फ़्री पर हो';

  @override
  String get proMetaFree => 'रोज़ और हफ़्ते की सीमाएँ · 12:00 AM IST';

  @override
  String get proMetaBillingIssue =>
      'Pro रखने के लिए Google Play में पेमेंट ठीक करो';

  @override
  String get proMetaActiveNoExpiry =>
      '3× रोज़ की सीमाएँ · हफ़्ते की सेफ़्टी कैप';

  @override
  String proMetaAnnualRenews(String date) {
    return 'वार्षिक · $date को रिन्यू · 3× सीमाएँ';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'मासिक · $date को रिन्यू · 3× सीमाएँ';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro $date को खत्म';
  }

  @override
  String get proStatusActive => 'सक्रिय';

  @override
  String get proStatusFree => 'फ़्री';

  @override
  String get proDailyLimits => 'रोज़ की सीमाएँ';

  @override
  String get proResetsDaily => 'हर दिन 12:00 AM IST पर रीसेट';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'Scan';

  @override
  String get proFeatureCheck => 'Check';

  @override
  String get proFeatureLessons => 'पाठ';

  @override
  String get proWeeklyLimit => 'हफ़्ते की सीमा';

  @override
  String get proResetsMondays => 'सोमवार को रीसेट · 12:00 AM IST';

  @override
  String proResetsOnDay(String day) {
    return '$day को रीसेट · 12:00 AM IST';
  }

  @override
  String get proAllFeatures => 'सभी फ़ीचर';

  @override
  String get proManageInPlay => 'Google Play में मैनेज करो';

  @override
  String get proResetsSoon => 'जल्द';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे में',
      one: '1 घंटे में',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'तुम्हारा पेमेंट पेंडिंग है। Google Play कन्फ़र्म करते ही Pro चालू हो जाएगा।';

  @override
  String get proNoticeNoPurchase =>
      'इस Google अकाउंट पर कोई ACADEMe Pro खरीदारी नहीं मिली।';

  @override
  String get proNoticeNotAllowed => 'इस Google अकाउंट पर खरीदारी बंद है।';

  @override
  String get proNoticeAlreadyOwned =>
      'इस Google अकाउंट पर पहले से Pro है। खरीदारी रीस्टोर करो टैप करो।';

  @override
  String get proNoticeUnavailable => 'इस डिवाइस पर खरीदारी उपलब्ध नहीं है।';

  @override
  String get proNoticeStoreError =>
      'Google Play पूरा नहीं कर सका। फिर कोशिश करो।';

  @override
  String get askmeNewChat => 'नई चैट';

  @override
  String askmeStudying(String name) {
    return 'क्या पढ़ रहे हैं, $name?';
  }

  @override
  String get askmeModeExplainLine =>
      'पेबी आसान भाषा में, कदम दर कदम समझाता है।';

  @override
  String get askmeModeSolveLine => 'पेबी संकेत देता है। तुम हल करते हो।';

  @override
  String get askmeModeQuizLine =>
      'पेबी पूछता है, तुम जवाब देते हो, XP मिलता है।';

  @override
  String get askmeSuggestExplain1 =>
      'प्रकाश के परावर्तन को आसान भाषा में समझाओ';

  @override
  String get askmeSuggestExplain2 => 'आसमान नीला क्यों है?';

  @override
  String get askmeSuggestExplain3 => 'प्रकाश संश्लेषण क्या है?';

  @override
  String get askmeSuggestSolve1 =>
      '2x + 3y = 11 और x − 2y = −12 हल करने में मदद करो';

  @override
  String get askmeSuggestSolve2 => 'r = 7 cm वाले वृत्त का क्षेत्रफल बताओ';

  @override
  String get askmeSuggestSolve3 => 'H₂ + O₂ → H₂O को संतुलित करो';

  @override
  String get askmeSuggestQuiz1 => 'Light पर क्विज़ लो';

  @override
  String get askmeSuggestQuiz2 => 'रैखिक समीकरणों पर 5 सवाल दो';

  @override
  String get askmeSuggestQuiz3 => 'French Revolution पर क्विज़ लो';

  @override
  String get askmeModeExplain => 'समझाओ';

  @override
  String get askmeModeSolve => 'हल करो';

  @override
  String get askmeModeQuiz => 'क्विज़ लो';

  @override
  String get askmeFollowNextStep => 'अगला कदम';

  @override
  String get askmeFollowFullSolution => 'पूरा हल';

  @override
  String get askmeFollowNextQuestion => 'अगला सवाल';

  @override
  String get askmeFollowQuizMe => 'क्विज़ लो';

  @override
  String get askmeFollowGoDeeper => 'और गहराई में';

  @override
  String get askmeSendNextStep => 'अगला कदम बताओ।';

  @override
  String get askmeSendFullSolution => 'पूरा हल दिखाओ।';

  @override
  String get askmeSendNextQuestion => 'अगला सवाल।';

  @override
  String get askmeSendGoDeeper => 'और गहराई में बताओ।';

  @override
  String get askmeSendQuizMe => 'इस पर क्विज़ लो।';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe अभी तैयार नहीं है। पेबी जल्द आएगा।';

  @override
  String get askmeFailureSignedOut =>
      'तुम लॉग आउट हो गए हो। फिर से लॉग इन करो।';

  @override
  String get askmeFailureLimitReached =>
      'आज के मुफ़्त सवाल खत्म। आधी रात को वापस मिलेंगे।';

  @override
  String get askmeThinking => 'पेबी सोच रहा है';

  @override
  String get historyTitle => 'हिस्ट्री';

  @override
  String get historySearchHint => 'अपने सवाल खोजो';

  @override
  String get historyLoadError => 'चैट लोड नहीं हो सकीं। फिर कोशिश';

  @override
  String get historyEmpty => 'पेबी से पूछे सवाल यहाँ दिखेंगे।';

  @override
  String get historyThisWeek => 'इस हफ़्ते';

  @override
  String get historyEarlier => 'पहले';

  @override
  String get historyNow => 'अभी';

  @override
  String historyHoursAgo(int hours) {
    return '$hoursघं';
  }

  @override
  String get historyWeekdayMon => 'सोम';

  @override
  String get historyWeekdayTue => 'मंगल';

  @override
  String get historyWeekdayWed => 'बुध';

  @override
  String get historyWeekdayThu => 'गुरु';

  @override
  String get historyWeekdayFri => 'शुक्र';

  @override
  String get historyWeekdaySat => 'शनि';

  @override
  String get historyWeekdaySun => 'रवि';

  @override
  String get historyMonthJan => 'जन';

  @override
  String get historyMonthFeb => 'फर';

  @override
  String get historyMonthMar => 'मार्च';

  @override
  String get historyMonthApr => 'अप्रै';

  @override
  String get historyMonthMay => 'मई';

  @override
  String get historyMonthJun => 'जून';

  @override
  String get historyMonthJul => 'जुल';

  @override
  String get historyMonthAug => 'अग';

  @override
  String get historyMonthSep => 'सित';

  @override
  String get historyMonthOct => 'अक्टू';

  @override
  String get historyMonthNov => 'नव';

  @override
  String get historyMonthDec => 'दिस';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'अपने सवाल में जोड़ो';

  @override
  String get attachCamera => 'कैमरा';

  @override
  String get attachPhotos => 'फ़ोटो';

  @override
  String get replyHelpful => 'मददगार';

  @override
  String get replyNotHelpful => 'मददगार नहीं';

  @override
  String get replyCopy => 'कॉपी';

  @override
  String get replyCopied => 'कॉपी हो गया';

  @override
  String get replyReportTitle => 'इस जवाब की रिपोर्ट करो';

  @override
  String get replyReportThanks => 'शुक्रिया। हम इस जवाब को देखेंगे।';

  @override
  String get reportTooltip => 'रिपोर्ट';

  @override
  String get reportSendFailed => 'रिपोर्ट नहीं भेज सके। फिर कोशिश करो।';

  @override
  String get reportBody => 'हम हर रिपोर्ट पढ़ते हैं ताकि पेबी और सुरक्षित बने।';

  @override
  String get reportReasonWrong => 'यह गलत है';

  @override
  String get reportReasonHarmful => 'यह हानिकारक या असुरक्षित है';

  @override
  String get reportReasonOffensive => 'यह अभद्र या आपत्तिजनक है';

  @override
  String get reportReasonOther => 'कुछ और';

  @override
  String get progressTitle => 'मेरी प्रगति';

  @override
  String get progressLoading => 'इस हफ़्ते का डेटा लोड हो रहा है…';

  @override
  String get progressLoadError => 'इस हफ़्ते का सारांश लोड नहीं हो सका।';

  @override
  String get progressHoldTitle => 'मेरी प्रगति Pro का हिस्सा है';

  @override
  String get progressHoldBody =>
      'ACADEMe Pro के साथ स्ट्रीक, लेवल और पढ़ाई की जानकारी देखो।';

  @override
  String get progressGoProLimits => 'Go Pro · 3× लिमिट';

  @override
  String get progressStudyDays => 'पढ़ाई के दिन';

  @override
  String get progressThisWeek => 'इस हफ़्ते';

  @override
  String get progressTodayStudied => 'आज · पढ़ाई की';

  @override
  String get progressTodayNotYet => 'आज · अभी नहीं';

  @override
  String get progressTabSummary => 'सारांश';

  @override
  String get progressTabProgress => 'प्रगति';

  @override
  String get progressTabActivity => 'एक्टिविटी';

  @override
  String get progressSubjectsThisWeek => 'इस हफ़्ते के विषय';

  @override
  String get progressCompleted => 'पूरे';

  @override
  String get progressOverallGrade => 'कुल ग्रेड';

  @override
  String get progressKeepItUp => 'ऐसे ही चलते रहो';

  @override
  String get progressStartJourney => 'अपनी यात्रा शुरू करो';

  @override
  String get progressCourseProgress => 'कोर्स प्रगति';

  @override
  String get progressLessonsEmpty => 'जो पाठ पूरे करोगे वे यहाँ दिखेंगे।';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'एक्टिविटी';

  @override
  String get progressStudyDaysEmpty => 'तुम्हारे पढ़ाई के दिन यहाँ दिखेंगे।';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस हफ़्ते $count सक्रिय दिन।',
      one: 'इस हफ़्ते 1 सक्रिय दिन।',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'अपनी यात्रा शुरू करने का समय है!';

  @override
  String get progressCtaMomentum => 'अपनी रफ़्तार बनाए रखो';

  @override
  String get progressCtaHabit => 'तुम एक आदत बना रहे हो';

  @override
  String get progressCtaNext => 'आगे क्या करना है देखो';

  @override
  String get progressNextSteps => 'अगले कदम';

  @override
  String get progressYourSetup => 'तुम्हारा सेटअप';

  @override
  String get progressWhatNext => 'आगे क्या करें';

  @override
  String get progressNextWithStudy =>
      'इस हफ़्ते पाठ पूरे करते रहो। पूरे होने पर ग्रेड अपडेट होता है।';

  @override
  String get progressNextNoStudy =>
      'Me में कक्षा और बोर्ड कन्फ़र्म करो। फिर Study खोलकर पहला पाठ पूरा करो।';

  @override
  String get progressWeekEmpty => 'इस हफ़्ते अभी कोई पढ़ाई नहीं लिखी गई।';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सक्रिय दिन',
      one: '1 सक्रिय दिन',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चैप्टर टेस्ट',
      one: '1 चैप्टर टेस्ट',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'इस हफ़्ते: $parts।';
  }

  @override
  String get progressWeekdayMon => 'सो';

  @override
  String get progressWeekdayTue => 'मं';

  @override
  String get progressWeekdayWed => 'बु';

  @override
  String get progressWeekdayThu => 'गु';

  @override
  String get progressWeekdayFri => 'शु';

  @override
  String get progressWeekdaySat => 'श';

  @override
  String get progressWeekdaySun => 'र';

  @override
  String get subjectsStreamTitle => 'तुम्हारा स्ट्रीम';

  @override
  String get subjectsSave => 'सेव';

  @override
  String get subjectsLoadError => 'विषय लोड नहीं हो सके। फिर कोशिश';

  @override
  String get subjectsMain => 'मुख्य';

  @override
  String get subjectsOptional => 'वैकल्पिक';

  @override
  String streamSwipeFor(String name) {
    return '$name के लिए स्वाइप करो। Me में कभी भी बदल सकते हो।';
  }

  @override
  String get streamChangeInMe => 'Me में कभी भी बदल सकते हो।';

  @override
  String streamChoose(String name) {
    return '$name चुनो';
  }

  @override
  String get classDialLabel => 'कक्षा';

  @override
  String classDialSemantics(int level) {
    return 'कक्षा $level';
  }

  @override
  String get studyTitle => 'पढ़ाई';

  @override
  String get studyCourses => 'कोर्सेस';

  @override
  String get studyFolders => 'फ़ोल्डर';

  @override
  String get studyDone => 'हो गया';

  @override
  String get studyKeep => 'रखो';

  @override
  String get studyDelete => 'डिलीट';

  @override
  String get studySave => 'सेव';

  @override
  String get studyCreate => 'बनाओ';

  @override
  String get studyAdd => 'जोड़ो';

  @override
  String get studyOptional => 'वैकल्पिक';

  @override
  String get studyName => 'नाम';

  @override
  String get studyToday => 'आज';

  @override
  String get studyComingSoon => 'जल्द आ रहा है';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'अध्याय $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$done में से $_temp0 पूरे';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जल्द आ रहे हैं',
      one: '1 जल्द आ रहा है',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'बोर्ड परीक्षा में नहीं';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count कार्ड',
      one: '1 कार्ड',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count क्विक चेक',
      one: '1 क्विक चेक',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सवाल',
      one: '1 सवाल',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अध्याय',
      one: '1 अध्याय',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes मिनट';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'लगभग $minutes मिनट';
  }

  @override
  String get coursesNeedSyllabus =>
      'कोर्सेस देखने के लिए होम पर अपनी कक्षा और बोर्ड सेट करो।';

  @override
  String get coursesLoadError => 'कोर्सेस लोड नहीं हो सके। फिर कोशिश';

  @override
  String coursesComingSoon(String syllabus) {
    return '$syllabus के पाठ आ रहे हैं। तब तक ASKMe में पेबी से कुछ भी पूछो।';
  }

  @override
  String get coursesNoFilterMatch => 'इन फ़िल्टर से कोई अध्याय नहीं मिला।';

  @override
  String get coursesFinishedEmpty => 'पूरे हो चुके अध्याय यहाँ दिखेंगे।';

  @override
  String get coursesStartedEmpty => 'जो अध्याय शुरू किए हैं वे यहाँ दिखेंगे।';

  @override
  String get coursesGoAgain => 'फिर से करो';

  @override
  String coursesContinueCard(int current, int total) {
    return 'जारी · कार्ड $current / $total';
  }

  @override
  String get coursesStart => 'शुरू करो';

  @override
  String get filterAll => 'सभी';

  @override
  String get filterInProgress => 'चल रहा है';

  @override
  String get filterDone => 'हो गया';

  @override
  String get filterFilters => 'फ़िल्टर';

  @override
  String filterFiltersOn(int count) {
    return 'फ़िल्टर, $count ऑन';
  }

  @override
  String get filterClear => 'साफ़ करो';

  @override
  String get filterSort => 'सॉर्ट';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अध्याय',
      one: '1 अध्याय',
    );
    return '$_temp0 दिखाओ';
  }

  @override
  String get filterBoardExamOnly => 'सिर्फ बोर्ड परीक्षा';

  @override
  String get filterBoardExamOnlyDesc => 'स्कूल-असेस्ड अध्याय छिपाओ';

  @override
  String get filterReadyToStudy => 'पढ़ने के लिए तैयार';

  @override
  String get filterReadyToStudyDesc => 'जल्द आने वाले अध्याय छिपाओ';

  @override
  String get filterRevisionDue => 'रिवीज़न बाकी';

  @override
  String get filterRevisionDueDesc => 'जिनमें रखे कार्ड रिवाइज़ करने हैं';

  @override
  String get filterSortTextbook => 'किताब';

  @override
  String get filterSortMostMarks => 'ज़्यादा मार्क्स';

  @override
  String get filterSortRecent => 'हाल का';

  @override
  String get filterFlagBoardExam => 'बोर्ड परीक्षा';

  @override
  String get filterFlagReady => 'तैयार';

  @override
  String get filterFlagRevisionDue => 'रिवीज़न बाकी';

  @override
  String filterRemove(String label) {
    return '$label हटाओ';
  }

  @override
  String get folderNew => 'नया फ़ोल्डर';

  @override
  String get folderEdit => 'फ़ोल्डर एडिट';

  @override
  String get folderEmptyHint =>
      'टेस्ट, होमवर्क या किसी भी तैयारी के लिए फ़ोल्डर बनाओ। तारीख डालो तो दिन प्लान हो जाते हैं।';

  @override
  String get folderEmpty => 'खाली';

  @override
  String get folderNothingLeftToday => 'आज कुछ बाकी नहीं';

  @override
  String folderTodoToday(int count) {
    return 'आज $count करने हैं';
  }

  @override
  String get folderNoDate => 'कोई तारीख नहीं';

  @override
  String folderPercentReady(int percent) {
    return '$percent% तैयार';
  }

  @override
  String get folderWhatsFor => 'यह फ़ोल्डर किसके लिए है?';

  @override
  String get folderAddChaptersPlan =>
      'अध्याय जोड़ो और पेबी तुम्हारे दिन प्लान करेगा।';

  @override
  String get folderAddChapters => 'अध्याय जोड़ो';

  @override
  String get folderFromSyllabus => 'तुम्हारे सिलेबस से';

  @override
  String get folderWriteNote => 'नोट लिखो';

  @override
  String get folderNoteSubtitle => 'जो याद रखना हो';

  @override
  String get folderScanNotes => 'नोट्स स्कैन करो';

  @override
  String get folderScanNotesSubtitle => 'पेज की फ़ोटो, पाठ बन जाती हैं';

  @override
  String get folderAddTodo => 'टू-डू जोड़ो';

  @override
  String get folderAddDate => 'तारीख जोड़ो';

  @override
  String get folderRemoveDate => 'तारीख हटाओ';

  @override
  String get folderReminders => 'इस फ़ोल्डर की रिमाइंडर';

  @override
  String get folderDeleteTitle => 'यह फ़ोल्डर डिलीट करें?';

  @override
  String get folderDeleteBody =>
      'नोट्स और टू-डू भी जाएँगे। पाठ और प्रोग्रेस रहेंगे।';

  @override
  String get folderTitle => 'फ़ोल्डर';

  @override
  String get folderEditRemindersTooltip => 'एडिट और रिमाइंडर';

  @override
  String get folderDeleteTooltip => 'फ़ोल्डर डिलीट';

  @override
  String get folderLoadError => 'फ़ोल्डर लोड नहीं हुआ। फिर कोशिश';

  @override
  String folderTodayMinutes(int minutes) {
    return 'आज · $minutes मिनट';
  }

  @override
  String get folderSeePlan => 'प्लान देखो';

  @override
  String get folderAddChaptersOrTodos => 'अध्याय या टू-डू जोड़ो।';

  @override
  String get folderNothingLeftForToday => 'आज के लिए कुछ बाकी नहीं।';

  @override
  String get folderInThisFolder => 'इस फ़ोल्डर में';

  @override
  String get folderFromNotesDone => 'तुम्हारे नोट्स से · हो गया';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'तुम्हारे नोट्स से · $minutes मिनट';
  }

  @override
  String get folderNote => 'नोट';

  @override
  String get folderSaveNote => 'नोट सेव करो';

  @override
  String get folderTypeHere => 'यहाँ लिखो…';

  @override
  String get folderAddTo => 'फ़ोल्डर में जोड़ो';

  @override
  String get folderCouldntMake => 'फ़ोल्डर नहीं बना। फिर कोशिश करो।';

  @override
  String folderAddedTo(String name) {
    return '$name में जोड़ दिया';
  }

  @override
  String get folderYourFolder => 'तुम्हारा फ़ोल्डर';

  @override
  String get folderPlan => 'प्लान';

  @override
  String folderPlanTo(String date) {
    return '$date तक प्लान';
  }

  @override
  String get folderPlanBody =>
      'इस फ़ोल्डर के अध्यायों से बना। कुछ छूट जाए तो अपने आप अगले दिन चला जाता है।';

  @override
  String get folderTestDay => 'टेस्ट दिन · तुम तैयार हो';

  @override
  String get folderRestDay => 'आराम का दिन';

  @override
  String get folderDueTomorrow => 'कल';

  @override
  String get folderDueYesterday => 'बीता कल';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0 पहले';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0 में';
  }

  @override
  String chapterTitle(int number) {
    return 'अध्याय $number';
  }

  @override
  String get chapterLessons => 'पाठ';

  @override
  String get chapterTest => 'अध्याय टेस्ट';

  @override
  String chapterTestLast(int correct, int total) {
    return 'पिछली बार $correct/$total · फिर कोशिश';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सवाल',
      one: '1 सवाल',
    );
    return 'हर पाठ से $_temp0';
  }

  @override
  String get chapterKeptCards => 'रखे कार्ड';

  @override
  String get chapterKeptEmpty => 'किसी भी कार्ड पर Keep टैप करो, यहाँ सेव होगा';

  @override
  String chapterKeptCount(int count) {
    return '$count रिवाइज़ करने हैं';
  }

  @override
  String get chapterAllDoneGoAgain => 'सभी पाठ पूरे · फिर से';

  @override
  String chapterResumeCard(int current, int total) {
    return 'जारी · कार्ड $current / $total';
  }

  @override
  String get chapterNextLesson => 'अगला पाठ';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'पाठ $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes सही';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'जल्द आ रहा है · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'पाठ पूरे · अब टेस्ट';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'हो गया · टेस्ट $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return ' · $count जल्द आ रहे हैं';
  }

  @override
  String get chapterNotInBoardExamSuffix => ' · बोर्ड परीक्षा में नहीं';

  @override
  String get chapterReportGreat => 'शानदार';

  @override
  String get chapterReportGood => 'अच्छी जा रही है';

  @override
  String get chapterReportRetry => 'एक बार और कोशिश';

  @override
  String get chapterReportByLesson => 'पाठ के हिसाब से';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'जो छूटा उसे रिवाइज़ करो';

  @override
  String get chapterAddToFolderAction => 'अध्याय फ़ोल्डर में जोड़ो';

  @override
  String get chapterBackToChapter => 'अध्याय पर वापस';

  @override
  String get chapterNoChaptersYet => 'तुम्हारी कक्षा के अध्याय अभी नहीं हैं।';

  @override
  String get chapterAlreadyInFolder => 'पहले से इस फ़ोल्डर में';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done पूरे';
  }

  @override
  String get chapterPickChapters => 'अध्याय चुनो';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count अध्याय',
      one: '1 अध्याय',
    );
    return '$_temp0 जोड़ो';
  }

  @override
  String get chapterAddChaptersTitle => 'अध्याय जोड़ो';

  @override
  String get deckReportTitle => 'इस पाठ की रिपोर्ट करो';

  @override
  String get deckReportThanks => 'धन्यवाद। हम इस पाठ को देखेंगे।';

  @override
  String get deckLoadError => 'पाठ लोड नहीं हुआ। फिर कोशिश';

  @override
  String get deckPerfect => 'परफेक्ट पाठ!';

  @override
  String get deckLessonDone => 'पाठ पूरा!';

  @override
  String get deckStatRight => 'सही';

  @override
  String get deckStatKept => 'रखे';

  @override
  String deckNextTitle(String title) {
    return 'अगला: $title';
  }

  @override
  String get deckStart => 'शुरू करो';

  @override
  String deckShowStep(int step) {
    return 'स्टेप $step दिखाओ';
  }

  @override
  String get deckCheck => 'चेक';

  @override
  String get deckNext => 'अगला';

  @override
  String get deckFinish => 'खत्म';

  @override
  String get deckPreviousCard => 'पिछला कार्ड';

  @override
  String get deckNewLesson => 'नया पाठ';

  @override
  String get deckByTheEnd => 'अंत तक तुम कर पाओगे:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · लगभग $minutes मिनट';
  }

  @override
  String get deckConcept => 'कॉन्सेप्ट';

  @override
  String get deckInOneLook => 'एक नज़र में';

  @override
  String get deckSummary => 'सार';

  @override
  String get deckThreeLines => 'पाठ तीन लाइनों में';

  @override
  String get deckKeptForRevision => 'रिवीज़न के लिए रखा';

  @override
  String get deckKeptRevisionOne => 'इस पाठ का 1 कार्ड रिवीज़न में वापस आएगा।';

  @override
  String deckKeptRevisionMany(int count) {
    return 'इस पाठ के $count कार्ड रिवीज़न में वापस आएंगे।';
  }

  @override
  String get deckWorkedExample => 'सॉल्व्ड उदाहरण';

  @override
  String deckStepTryFirst(int step) {
    return 'स्टेप $step · पहले खुद कोशिश';
  }

  @override
  String get deckRemember => 'याद रखो';

  @override
  String get deckKept => 'रखा';

  @override
  String get deckAskPebby => 'पेबी से पूछो';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'इसे और आसान करके समझाओ? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return '\"$title\" को एक उदाहरण से समझाओ?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'यह कैसे हल करें समझाओ: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'यह गलत हुआ: $question सही जवाब क्यों: $why';
  }

  @override
  String get deckAskExplainLesson => 'यह पाठ समझाओ?';

  @override
  String get deckGoals => 'लक्ष्य';

  @override
  String get quizQuickCheck => 'क्विक चेक';

  @override
  String quizQuestionOf(int current, int total) {
    return 'सवाल $current / $total';
  }

  @override
  String get quizPraise1 => 'नाइस! सही है।';

  @override
  String get quizPraise2 => 'बिल्कुल सही!';

  @override
  String get quizPraise3 => 'हो गया!';

  @override
  String get quizPraise4 => 'सही, शाबाश!';

  @override
  String get quizPraise5 => 'एकदम सही!';

  @override
  String get quizHeresWhy => 'इसलिए';

  @override
  String get quizYourAnswer => 'तुम्हारा जवाब';

  @override
  String get quizRightAnswer => 'सही जवाब';

  @override
  String get quizKeptForYou => 'तुम्हारे लिए रखा';

  @override
  String get quizComesBack => 'यह सवाल कल रिवीज़न में वापस आएगा।';

  @override
  String get quizNotQuite => 'ठीक नहीं। आगे: क्यों।';

  @override
  String quizStreak(int count) {
    return '$count लगातार';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'रिवीज़न';

  @override
  String get studyRevisionEmptyTitle => 'रिवाइज़ करने को कुछ नहीं';

  @override
  String get studyRevisionEmptyBody =>
      'पाठ में कार्ड Keep करो, या सवाल गलत हो, तो वे यहाँ आते हैं।';

  @override
  String get studyRevisionDone => 'रिवीज़न पूरा';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew जानते थे · $almost लगभग · $again कल फिर देखना';
  }

  @override
  String get studyRevisionHint => 'जवाब सोचो, फिर चेक करने के लिए टैप करो।';

  @override
  String get studyRevisionShowAnswer => 'जवाब दिखाओ';

  @override
  String get studyRevisionAgain => 'नहीं पता था';

  @override
  String get studyRevisionAlmost => 'लगभग';

  @override
  String get studyRevisionKnew => 'पता था';

  @override
  String chapterTestDeckTitle(int number) {
    return 'अध्याय $number टेस्ट';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पाठ',
      one: '1 पाठ',
    );
    return '$done में से $_temp0';
  }

  @override
  String get actionTryAgain => 'फिर कोशिश करो';

  @override
  String get actionGoPro => 'Pro लो';

  @override
  String get actionBack => 'वापस';

  @override
  String get actionClose => 'बंद करें';

  @override
  String get failureNetwork => 'कनेक्शन नहीं। इंटरनेट जाँचकर फिर कोशिश करो।';

  @override
  String get failureUnknown => 'कुछ गलत हो गया। फिर कोशिश करो।';
}
