// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'অ্যাপের ভাষা';

  @override
  String get meLanguageSheetBody =>
      'পেবি ও স্ক্যানের উত্তর এই ভাষায় হবে। অ্যাপের ইন্টারফেসও এই ভাষায় আসছে।';

  @override
  String get meMoreLanguagesComing => 'আরও ভাষা শীঘ্রই আসছে';

  @override
  String languageSwitchingTo(String name) {
    return '$name-এ স্যুইচ হচ্ছে…';
  }

  @override
  String get navHome => 'হোম';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'পড়াশোনা';

  @override
  String get navMe => 'আমি';

  @override
  String get navScan => 'স্ক্যান';

  @override
  String get navSend => 'পাঠান';

  @override
  String get askAnythingHint => 'যা খুশি জিজ্ঞাসা করুন…';

  @override
  String get askAttach => 'অ্যাটাচ';

  @override
  String get softUpdateDefaultMessage => 'নতুন ভার্সন এসেছে, মিস করবেন না!';

  @override
  String get softUpdateAction => 'আপডেট';

  @override
  String get softUpdateDismiss => 'এখন নয়';

  @override
  String get updateRequiredTitle => 'একটু দাঁড়ান';

  @override
  String get updateRequiredBody =>
      'এই বিল্ড আর আমাদের সার্ভারের সাথে কথা বলতে পারে না। পড়া চালিয়ে যেতে Play-এ আপডেট করুন।';

  @override
  String updateRequiredBuild(String build) {
    return 'ইনস্টল করা বিল্ড $build।';
  }

  @override
  String get updateRequiredAction => 'Google Play-এ আপডেট করুন';

  @override
  String get pebbySemantics => 'পেবি';

  @override
  String get welcomeHeadlineLead => 'স্মার্টভাবে\nপড়ো।';

  @override
  String get welcomeHeadlineAccent => 'বেশি নয়।';

  @override
  String get welcomeBody =>
      'নোট, কুইজ ও ফ্ল্যাশকার্ড — যা তুমি আসলে পড়ছো সেখান থেকেই।';

  @override
  String get welcomeGetStarted => 'শুরু করো';

  @override
  String get welcomeAlreadyHaveAccount => 'আগে থেকে অ্যাকাউন্ট আছে? ';

  @override
  String get welcomeNewUser => 'নতুন? ';

  @override
  String get welcomeLegal =>
      'এগোলে তুমি আমাদের শর্তাবলী ও গোপনীয়তা নীতিতে সম্মত হচ্ছো।';

  @override
  String get authSignUp => 'সাইন আপ';

  @override
  String get authLogIn => 'লগ ইন';

  @override
  String get authContinueGoogle => 'Google দিয়ে চালিয়ে যাও';

  @override
  String get authContinueApple => 'Apple দিয়ে চালিয়ে যাও';

  @override
  String get authContinueEmail => 'ইমেইল দিয়ে চালিয়ে যাও';

  @override
  String get loginHeadlineLead => 'আবার';

  @override
  String get loginHeadlineAccent => 'স্বাগত।';

  @override
  String get loginSubtitle => 'যেখানে ছেড়েছিলে সেখান থেকে চালিয়ে যাও।';

  @override
  String get authEmail => 'ইমেইল';

  @override
  String get authPassword => 'পাসওয়ার্ড';

  @override
  String get authShowPassword => 'পাসওয়ার্ড দেখাও';

  @override
  String get authHidePassword => 'পাসওয়ার্ড লুকাও';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছো?';

  @override
  String get authLoggingIn => 'লগ ইন হচ্ছে…';

  @override
  String get authNewHere => 'নতুন? ';

  @override
  String get forgotPasswordLead => 'পাসওয়ার্ড';

  @override
  String get forgotPasswordAccent => 'ভুলে গেছো?';

  @override
  String get forgotPasswordSubtitle =>
      'তোমার ইমেইল লিখো, আমি ৬ অঙ্কের কোড পাঠাব।';

  @override
  String get authSending => 'পাঠানো হচ্ছে…';

  @override
  String get authSendCode => 'কোড পাঠাও';

  @override
  String get resetCodeLead => 'তোমার';

  @override
  String get resetCodeAccent => 'ইমেইল দেখো।';

  @override
  String resetCodeSubtitle(String email) {
    return '$email-এ ACADEMe অ্যাকাউন্ট থাকলে, ৬ অঙ্কের কোড আসছে। এটি ১৫ মিনিটে মেয়াদ শেষ হবে।';
  }

  @override
  String get authPasteCode => 'কোড পেস্ট করো';

  @override
  String get authChecking => 'যাচাই হচ্ছে…';

  @override
  String get authVerify => 'যাচাই';

  @override
  String get resetDidntGetIt => 'পাওনি? ';

  @override
  String get resetSendNewCode => 'নতুন কোড পাঠাও';

  @override
  String get resetSendingNewCode => 'নতুন কোড পাঠানো হচ্ছে…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'নতুন কোড পাঠানো হয়েছে। আবার চাইতে পারো ০:$seconds-এ';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'নতুন কোড ০:$seconds-এ চাইতে পারো';
  }

  @override
  String get newPasswordLead => 'নতুন';

  @override
  String get newPasswordAccent => 'পাসওয়ার্ড বেছে নাও।';

  @override
  String get newPasswordSubtitle =>
      'কমপক্ষে ৮ অক্ষর। চিন্তা কোরো না, আমি দেখব না।';

  @override
  String get authNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ অক্ষর';
  }

  @override
  String get authStartAgain => 'আবার শুরু করো';

  @override
  String get authSaving => 'সেভ হচ্ছে…';

  @override
  String get authSaveAndLogIn => 'সেভ করে লগ ইন';
}
