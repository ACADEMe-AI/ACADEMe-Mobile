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
  String get authFailureUnknown => 'कुछ गलत हो गया। फिर कोशिश करो।';

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
  String get signUpTryAgain => 'फिर कोशिश करो';

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
}
