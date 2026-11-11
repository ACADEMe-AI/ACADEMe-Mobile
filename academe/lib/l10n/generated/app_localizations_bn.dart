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

  @override
  String get authFailureEmailTaken =>
      'এই ইমেইলে আগে থেকে অ্যাকাউন্ট আছে। লগ ইন করো।';

  @override
  String get authFailureWrongCredentials => 'ইমেইল ও পাসওয়ার্ড মেলে না।';

  @override
  String get authFailureInvalidInput => 'বিবরণ চেক করে আবার চেষ্টা করো।';

  @override
  String get authFailureSignedOut => 'সেশন শেষ। আবার লগ ইন করো।';

  @override
  String get authFailureNetwork =>
      'ACADEMe-এ পৌঁছানো যাচ্ছে না। কানেকশন চেক করে আবার চেষ্টা করো।';

  @override
  String get authFailureCanceled => 'সাইন-ইন বাতিল হয়েছে।';

  @override
  String get authFailureProviderUnavailable =>
      'এই সাইন-ইন অপশন এখনো তৈরি নয়। আপাতত ইমেইল ব্যবহার করো।';

  @override
  String get authFailureWrongCode =>
      'কোড ঠিক নয়। ইমেইল চেক করে আবার চেষ্টা করো।';

  @override
  String get authFailureTooManyAttempts =>
      'অনেক ভুল চেষ্টা। নতুন কোড পাঠিয়ে নাও।';

  @override
  String get authFailureCodeExpired => 'কোডের মেয়াদ শেষ। নতুনটা পাঠিয়ে নাও।';

  @override
  String get authFailureResetExpired =>
      'রিসেট লিংকের মেয়াদ শেষ। পাসওয়ার্ড ভুলে গেছি থেকে আবার শুরু করো।';

  @override
  String get authFailureTooManyRequests =>
      'অনেক চেষ্টা হয়ে গেছে। একটু অপেক্ষা করে আবার চেষ্টা করো।';

  @override
  String get authFailureWrongPassword => 'এটা তোমার বর্তমান পাসওয়ার্ড নয়।';

  @override
  String get authFailureGoogleTaken =>
      'এই Google অ্যাকাউন্ট অন্য ACADEMe অ্যাকাউন্টের সাথে লিংক করা।';

  @override
  String get authFailurePasswordRequired =>
      'আগে পাসওয়ার্ড সেট করো, যাতে Google ছাড়াও লগ ইন করতে পারো।';

  @override
  String get authFailureUnknown => 'কিছু ভুল হয়েছে। আবার চেষ্টা করো।';

  @override
  String get signUpHiPebby => 'হাই, আমি পেবি!';

  @override
  String signUpHiNamed(String name) {
    return 'হাই $name, আমি পেবি!';
  }

  @override
  String get signUpAskFirstName => 'শুরুর আগে, তোমাকে কী বলে ডাকব?';

  @override
  String get signUpFirstName => 'প্রথম নাম';

  @override
  String signUpAskLastName(String name) {
    return 'দেখা করে ভালো লাগলো, $name! আর তোমার শেষ নাম?';
  }

  @override
  String get signUpLastName => 'শেষ নাম';

  @override
  String signUpAskEmail(String name) {
    return 'তোমার ইমেইল কী, $name?';
  }

  @override
  String get signUpEmailHint => 'লগ ইনের জন্য এটাই ব্যবহার করবে।';

  @override
  String get signUpEmailInvalid => 'এটা এখনো ইমেইলের মতো লাগছে না।';

  @override
  String get signUpCreatePassword => 'পাসওয়ার্ড তৈরি করো';

  @override
  String signUpPasswordHint(int count) {
    return 'কমপক্ষে $count অক্ষর। চিন্তা কোরো না, আমি দেখব না।';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'আবার স্বাগত, $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'তোমার আগে থেকে অ্যাকাউন্ট আছে, তাই তুমি লগ ইন আছো।';

  @override
  String signUpYoureIn(String name) {
    return 'তুমি ভিতরে এসেছো, $name!';
  }

  @override
  String get signUpAccountReady => 'অ্যাকাউন্ট তৈরি। এবার বলো তুমি কী পড়ো।';

  @override
  String get signUpHelloEmail =>
      'আমি স্মার্টভাবে পড়তে সাহায্য করব। অ্যাকাউন্ট সেট আপ করি, এক মিনিট লাগবে।';

  @override
  String get signUpConnectingAccount => 'অ্যাকাউন্ট কানেক্ট হচ্ছে…';

  @override
  String get signUpCheckName => 'নাম চেক করি, তারপর তুমি ভিতরে।';

  @override
  String get signUpConnecting => 'কানেক্ট হচ্ছে…';

  @override
  String get signUpTryAgain => 'আবার চেষ্টা করো';

  @override
  String get signUpHiPebbyAction => 'হাই পেবি!';

  @override
  String get signUpCreatingAccount => 'অ্যাকাউন্ট তৈরি হচ্ছে…';

  @override
  String get signUpCreateAccount => 'অ্যাকাউন্ট তৈরি করো';

  @override
  String get signUpLetsGo => 'চলো';

  @override
  String get authContinue => 'এগোও';
}
