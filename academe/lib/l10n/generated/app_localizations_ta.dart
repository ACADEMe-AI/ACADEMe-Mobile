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
  String get authFailureUnknown => 'ஏதோ தவறு நடந்தது. மீண்டும் முயலுங்கள்.';

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
  String get signUpTryAgain => 'மீண்டும் முயலுங்கள்';

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
}
