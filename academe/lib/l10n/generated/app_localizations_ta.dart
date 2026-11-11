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
}
