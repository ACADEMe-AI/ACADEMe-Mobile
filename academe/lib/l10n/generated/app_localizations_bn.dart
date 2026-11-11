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
  String get signUpHiPebbyAction => 'হাই পেবি!';

  @override
  String get signUpCreatingAccount => 'অ্যাকাউন্ট তৈরি হচ্ছে…';

  @override
  String get signUpCreateAccount => 'অ্যাকাউন্ট তৈরি করো';

  @override
  String get signUpLetsGo => 'চলো';

  @override
  String get authContinue => 'এগোও';

  @override
  String get homeSetupTitle => 'তোমার ড্যাশবোর্ড সেট আপ করো';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'ভাষা';

  @override
  String get homeSetupTaskAge => 'তোমার বয়স';

  @override
  String get homeSetupTaskClass => 'তোমার ক্লাস';

  @override
  String get homeSetupTaskBoard => 'তোমার বোর্ড';

  @override
  String get homeSetupTaskSubjects => 'তোমার বিষয়';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'হোমওয়ার্ক সলভ করো';

  @override
  String get homeCheckAnswer => 'উত্তর চেক করো';

  @override
  String get homeFlashcards => 'ফ্ল্যাশকার্ড';

  @override
  String get homePickSubjects => 'তোমার বিষয় বেছে নাও';

  @override
  String homePickSubjectsBody(int xp) {
    return 'হোম ও স্টাডিতে শুধু যেগুলো পড়ো সেগুলোই দেখাবে। +$xp XP';
  }

  @override
  String get setupLanguageTitle => 'তুমি কোন ভাষায় শেখো?';

  @override
  String setupChooseLanguage(String name) {
    return '$name বেছে নাও';
  }

  @override
  String get setupLanguageFootnote => 'সেটিংসে যেকোনো সময় বদলাতে পারো।';

  @override
  String get setupAgeTitle => 'তুমি কখন জন্মেছো?';

  @override
  String get setupAgeSubtitle => 'বয়স অনুযায়ী ঠিক রাখতে।';

  @override
  String get setupBirthYear => 'জন্ম সাল';

  @override
  String setupYouAreAge(int age) {
    return 'তোমার বয়স $age।';
  }

  @override
  String get setupClassTitle => 'তোমার ক্লাসে ঘোরাও';

  @override
  String get setupClassSubtitle => 'ডায়াল ঘোরাও বা নম্বর ট্যাপ করো।';

  @override
  String setupImInClass(int level) {
    return 'আমি ক্লাস $level-এ আছি';
  }

  @override
  String get setupBoardTitle => 'কোন বোর্ড?';

  @override
  String get setupBoardSubtitle => 'আমরা তোমার বোর্ডের সিলেবাস অনুসরণ করি।';

  @override
  String get setupStateBoardsSoon => 'রাজ্য বোর্ড শীঘ্রই আসছে।';

  @override
  String get setupFinish => 'সেটআপ শেষ করো';

  @override
  String setupProgress(int step, int total) {
    return 'সেট আপ · $step/$total';
  }

  @override
  String get setupLater => 'পরে';

  @override
  String get setupChangeInMe => 'Me-এ যেকোনো সময় বদলাতে পারো।';

  @override
  String setupStreamTitle(int level) {
    return 'ক্লাস $level-এ তুমি কী পড়ো?';
  }

  @override
  String get setupAnythingElse => 'আর কিছু?';

  @override
  String get setupWhichSubjects => 'তুমি কোন বিষয় পড়ো?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus. মূল বিষয়গুলো আছে।';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus. যেগুলো পড়ো না সরিয়ে দাও।';
  }

  @override
  String get homeYourSubjects => 'তোমার বিষয়';

  @override
  String get homeEdit => 'এডিট';

  @override
  String get homeSubjectsNeedSyllabus => 'বিষয় দেখতে ক্লাস ও বোর্ড সেট করো';

  @override
  String get homeSubjectsLoading => 'বিষয় লোড হচ্ছে…';

  @override
  String get homeSubjectsSoon => 'তোমার বিষয় এখানে শীঘ্রই দেখাবে।';

  @override
  String homeNextChapter(int number, String title) {
    return 'পরের: Ch $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'সব পাঠ শেষ';

  @override
  String get homeLessonsComingSoon => 'পাঠ শীঘ্রই আসছে';

  @override
  String homeTodayMinutes(int minutes) {
    return 'আজ · $minutes মিনিট';
  }

  @override
  String get homeTodayDone => 'আজ · সব হয়ে গেছে';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ফোল্ডার থেকে',
      one: '১টি ফোল্ডার থেকে',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'আরও $count তোমার ফোল্ডারে';
  }

  @override
  String get homeAskHintTitle => 'পেবিকে যা খুশি জিজ্ঞাসা করো';

  @override
  String get homeAskHintBody =>
      'প্রশ্ন টাইপ করো, বা হোমওয়ার্ক সলভ ট্যাপ করে ছবি তোলো।';

  @override
  String get homeAskHintGotIt => 'বুঝেছি';

  @override
  String get homeDashboardLoadError => 'ড্যাশবোর্ড লোড হয়নি।';

  @override
  String get homeRetry => 'আবার চেষ্টা';

  @override
  String get helloFallbackName => 'বন্ধু';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিনের স্ট্রিক',
      one: '১ দিনের স্ট্রিক',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'নোটস ফোল্ডারে';

  @override
  String get scanModeAsk => 'ছবি নিয়ে জিজ্ঞাসা করো';

  @override
  String get scanWhatsOnPaper => 'কাগজে কী আছে?';

  @override
  String get scanHintSolve => 'আগে হিন্ট';

  @override
  String get scanHintCheck => 'বোর্ড-স্টাইল মার্কস';

  @override
  String get scanHintNotes => 'পেজ থেকে পাঠ';

  @override
  String get scanHintAsk => 'আর যা খুশি';

  @override
  String get scanRecent => 'সাম্প্রতিক স্ক্যান';

  @override
  String get scanStatusRead => 'পড়া হয়েছে';

  @override
  String get scanStatusSolvedInAskMe => 'ASKMe-তে সলভ করা';

  @override
  String get scanStatusAskedInAskMe => 'ASKMe-তে জিজ্ঞাসা করা';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count মার্কস',
      one: '১ মার্ক',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'এখনো মার্ক হয়নি';

  @override
  String get scanStatusLessonInFolder => 'ফোল্ডারে পাঠ';

  @override
  String get scanStatusNotesInFolder => 'ফোল্ডারে নোটস';

  @override
  String get scanStatusNotSaved => 'এখনো সেভ হয়নি';

  @override
  String get scanSourceNotesBlurb =>
      'সর্বোচ্চ ১০ পেজ। শুধু টেক্সট রাখা হয়, ছবি নয়।';

  @override
  String get scanSourceBlurb => 'শুধু টেক্সট রাখা হয়, ছবি নয়।';

  @override
  String get scanTakePhoto => 'ছবি তোলো';

  @override
  String get scanChooseGallery => 'গ্যালারি থেকে বেছে নাও';

  @override
  String get scanCamera => 'ক্যামেরা';

  @override
  String get scanGallery => 'গ্যালারি';

  @override
  String get scanYourPages => 'তোমার পেজ';

  @override
  String scanPagesOf(int current, int max) {
    return '$current / $max';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পেজ পড়ো',
      one: '১ পেজ পড়ো',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'পেজ সরাও';

  @override
  String get scanYourNotes => 'তোমার নোটস';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'পেবি $count পেজ পড়েছে',
      one: 'পেবি ১ পেজ পড়েছে',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'এগুলো কোথায় যাবে?';

  @override
  String get scanChooseFolder => 'একটা ফোল্ডার বেছে নাও';

  @override
  String get scanChange => 'বদলাও';

  @override
  String get scanMakeFromNotes => 'নোটস থেকে বানাও';

  @override
  String get scanSwipeLesson => 'সোয়াইপ পাঠ';

  @override
  String get scanSwipeLessonSubtitle => 'কার্ড আর ছোট চেক, প্ল্যানে যোগ হবে';

  @override
  String get scanKeepNotes => 'শুধু নোটস রাখো';

  @override
  String get scanKeepNotesSubtitle => 'টেক্সট ফোল্ডারে চলে যাবে';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পেজ পড়ছি…',
      one: 'তোমার পেজ পড়ছি…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'কয়েক সেকেন্ড লাগবে।';

  @override
  String get scanMakingLesson => 'তোমার পাঠ বানাচ্ছি…';

  @override
  String get scanSavingNotes => 'তোমার নোটস সেভ হচ্ছে…';

  @override
  String get scanSavingWait => 'এগুলো তোমার ফোল্ডারে থাকবে।';

  @override
  String get scanFailUnavailableTitle => 'স্ক্যান এখনো তৈরি নয়';

  @override
  String get scanFailUnavailableBody =>
      'পেবি এখন ছবি পড়তে পারছে না। পরে আবার চেষ্টা করো।';

  @override
  String get scanFailNoTextTitle => 'এখানে কোনো শব্দ নেই';

  @override
  String get scanFailNoTextBody =>
      'ক্যামেরা হোমওয়ার্ক, বইয়ের পেজ বা নোটসের দিকে রাখো।';

  @override
  String get scanFailTooLargeTitle => 'অনেক বড় ছবি';

  @override
  String get scanFailTooLargeBody => 'একবারে কম পেজ চেষ্টা করো।';

  @override
  String get scanFailNetworkTitle => 'তুমি অফলাইন';

  @override
  String get scanFailNetworkBody => 'ইন্টারনেট চেক করে আবার চেষ্টা করো।';

  @override
  String get scanFailScanLimitTitle => 'আজকের ফ্রি স্ক্যান শেষ';

  @override
  String get scanFailScanLimitBody =>
      'মধ্যরাতে ফিরে আসবে। যত খুশি স্ক্যান করতে Pro নাও।';

  @override
  String get scanFailCheckLimitTitle => 'আজকের ফ্রি চেক শেষ';

  @override
  String get scanFailCheckLimitBody =>
      'মধ্যরাতে ফিরে আসবে। প্রতিটা উত্তর চেক করতে Pro নাও।';

  @override
  String get scanFailProOnlyTitle => 'নোটস থেকে পাঠ Pro';

  @override
  String get scanFailProOnlyBody =>
      'ফ্রিতে নোটস রাখো, অথবা Pro নাও আর পেবি সেগুলো দিয়ে পাঠ বানাক।';

  @override
  String get scanFailUnknownTitle => 'পেবি সেটা পড়তে পারেনি';

  @override
  String get scanFailUnknownBody =>
      'আবার চেষ্টা করো, অথবা ভালো আলোয় আবার ছবি তোলো।';

  @override
  String get scanBackToAnswer => 'তোমার উত্তরে ফিরে যাও';

  @override
  String get scanRetake => 'আবার তোলো';

  @override
  String get scanCameraOpenFailed =>
      'ক্যামেরা খোলা যায়নি। গ্যালারি চেষ্টা করো।';

  @override
  String get scanPebbyReadThis => 'পেবি এটা পড়েছে';

  @override
  String get scanFixAnything => 'যা ভুল আছে ঠিক করো।';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · যা ভুল আছে ঠিক করো।';
  }

  @override
  String get scanFromYourPhoto => 'তোমার ছবি থেকে';

  @override
  String get scanFromMyPhoto => 'আমার ছবি থেকে:';

  @override
  String get scanWhatDoYouWant => 'তুমি কী জানতে চাও?';

  @override
  String get scanSuggestExplain => 'এটা সহজ করে বলো';

  @override
  String get scanSuggestSummarise => 'সারাংশ বলো';

  @override
  String get scanSuggestKeyTerms => 'মূল শব্দগুলো কী?';

  @override
  String get scanSolveThis => 'এটা সলভ করো';

  @override
  String get scanAskPebby => 'পেবিকে জিজ্ঞাসা করো';

  @override
  String get scanHintFirst => 'পেবি আগে একটা হিন্ট দেয়, তারপর ধাপগুলো।';

  @override
  String get checkPebbyReadAnswer => 'পেবি তোমার উত্তর পড়েছে';

  @override
  String get checkTheQuestion => 'প্রশ্ন';

  @override
  String get checkQuestionHint => 'শুধু যদি ছবিতে না থাকে';

  @override
  String get checkMarkIt => 'মার্ক করো';

  @override
  String get checkMarkingAnswer => 'তোমার উত্তর মার্ক হচ্ছে…';

  @override
  String get checkMarkingScheme => 'বোর্ডের মার্কিং স্কিম দিয়ে।';

  @override
  String get checkFullMarks => 'ফুল মার্কস!';

  @override
  String get checkNearlyThere => 'প্রায় পৌঁছে গেছো';

  @override
  String get checkKeepGoing => 'চেষ্টা চালিয়ে যাও';

  @override
  String get checkReportTitle => 'এই মার্কস রিপোর্ট করো';

  @override
  String get checkReportThanks => 'ধন্যবাদ। আমরা এই মার্কস দেখব।';

  @override
  String get checkWhatGotMarks => 'কীতে মার্কস পেয়েছো';

  @override
  String get checkWellDone => 'শাবাশ';

  @override
  String get checkForFullMarks => 'ফুল মার্কসের জন্য';

  @override
  String get checkAgain => 'আবার চেক করো';

  @override
  String get checkShowModelAnswer => 'মডেল উত্তর দেখাও';

  @override
  String get checkHideModelAnswer => 'মডেল উত্তর লুকাও';

  @override
  String checkAskQuestion(String question) {
    return 'প্রশ্ন: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'আমার উত্তর:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'আমি পেয়েছি $awarded/$marks। ফুল মার্কস কীভাবে পাব?';
  }

  @override
  String get meLearningSection => 'শেখা';

  @override
  String get meMyProgress => 'আমার অগ্রগতি';

  @override
  String get meClassAndBoard => 'ক্লাস ও বোর্ড';

  @override
  String get meAppearance => 'চেহারা';

  @override
  String get meNotificationsSection => 'বিজ্ঞপ্তি';

  @override
  String get meRemindersAndDailyGoal => 'রিমাইন্ডার ও দৈনিক লক্ষ্য';

  @override
  String get meAccountSection => 'অ্যাকাউন্ট';

  @override
  String get meAccount => 'অ্যাকাউন্ট';

  @override
  String get meHelpAndFeedback => 'সাহায্য ও মতামত';

  @override
  String get mePrivacyAndTerms => 'গোপনীয়তা ও শর্তাবলী';

  @override
  String get meLogOut => 'লগ আউট';

  @override
  String get meLoggingOut => 'লগ আউট হচ্ছে…';

  @override
  String get meStudentFallback => 'ছাত্র';

  @override
  String get meDayStreak => 'দিনের স্ট্রিক';

  @override
  String meLevelValue(int number) {
    return 'Lv $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return 'Lv $level-এ $xp XP';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'ঠিক আছে';

  @override
  String meOkSwitchTo(String name) {
    return 'ঠিক আছে · $name-এ স্যুইচ করো';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting এখন পেবি $name-এ উত্তর দেবে।';
  }

  @override
  String get meLanguageSwitchFailed => 'ভাষা বদলানো যায়নি। আবার চেষ্টা করো।';

  @override
  String meOpenInBrowser(String url) {
    return 'ব্রাউজারে $url খোলো';
  }

  @override
  String get meNotSet => 'সেট হয়নি';

  @override
  String get meOff => 'বন্ধ';

  @override
  String meClassOnly(int level) {
    return 'ক্লাস $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'ক্লাস $level · $board';
  }

  @override
  String get meLogOutTitle => 'লগ আউট?';

  @override
  String get meLogOutBody =>
      'তোমার অগ্রগতি অ্যাকাউন্টে সেভ আছে। যেকোনো সময় আবার লগ ইন করতে পারো।';

  @override
  String get meLogOutStay => 'থাকো';

  @override
  String get accountSaveName => 'নাম সেভ করো';

  @override
  String get accountNameSaved => 'নাম সেভ হয়েছে';

  @override
  String get accountDangerZone => 'বিপজ্জনক অংশ';

  @override
  String get accountDeleteMyAccount => 'আমার অ্যাকাউন্ট মুছো';

  @override
  String get accountDeleteGraceNote =>
      'চাওয়ার ৩০ দিন পর অ্যাকাউন্ট মুছে যায়। তার আগে লগ ইন করে রাখতে পারো।';

  @override
  String get accountSignIn => 'সাইন-ইন';

  @override
  String get accountChangePassword => 'পাসওয়ার্ড বদলাও';

  @override
  String get accountSetPassword => 'পাসওয়ার্ড সেট করো';

  @override
  String get accountLinkGoogle => 'Google লিঙ্ক করো';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'লিঙ্ক হচ্ছে…';

  @override
  String get accountUnlinking => 'আনলিঙ্ক হচ্ছে…';

  @override
  String get accountNotLinked => 'লিঙ্ক নেই';

  @override
  String get accountGoogleLinked =>
      'Google লিঙ্ক হয়েছে। এখন দিয়ে লগ ইন করতে পারো।';

  @override
  String get accountGoogleUnlinked =>
      'Google আনলিঙ্ক হয়েছে। ইমেইল ও পাসওয়ার্ড দিয়ে লগ ইন করো।';

  @override
  String get accountUnlinkGoogleTitle => 'Google আনলিঙ্ক করবে?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'আর $email দিয়ে লগ ইন করতে পারবে না। ইমেইল ও পাসওয়ার্ড ব্যবহার করো।';
  }

  @override
  String get accountKeepGoogle => 'Google রাখো';

  @override
  String get accountUnlink => 'আনলিঙ্ক';

  @override
  String get passwordSave => 'পাসওয়ার্ড সেভ করো';

  @override
  String get passwordChangeBody =>
      'সাইন আপের মতোই নিয়ম। সেভ করলে অন্য ডিভাইস লগ আউট হয়ে যায়।';

  @override
  String get passwordSetBody =>
      'পাসওয়ার্ড যোগ করো যাতে শুধু Google নয়, ইমেইল দিয়েও লগ ইন করতে পারো।';

  @override
  String get passwordCurrent => 'বর্তমান পাসওয়ার্ড';

  @override
  String get passwordChangedSnack =>
      'পাসওয়ার্ড বদলেছে। অন্য ডিভাইস লগ আউট হয়েছে।';

  @override
  String get passwordSetSnack =>
      'পাসওয়ার্ড সেট হয়েছে। এখন ইমেইল দিয়েও লগ ইন করতে পারো।';

  @override
  String get deleteAccountTitle => 'অ্যাকাউন্ট মুছো';

  @override
  String get deleteDeleting => 'মুছে ফেলা হচ্ছে…';

  @override
  String get deleteSorryTitle => 'তোমাকে যেতে দেখে দুঃখ হচ্ছে';

  @override
  String get deleteBody =>
      'তোমার অ্যাকাউন্ট ৩০ দিনে মুছে যাবে। তার আগে আবার লগ ইন করে রাখতে পারো। ৩০ দিন পর প্রোফাইল, চ্যাট, অগ্রগতি ও XP চিরতরে মুছে যায়।';

  @override
  String get deleteSubscription => 'সাবস্ক্রিপশন';

  @override
  String get deleteSubscriptionNotice =>
      'অ্যাকাউন্ট মুছলে Google Play-তে কেনা ACADEMe Pro সাবস্ক্রিপশন বাতিল হয় না। আবার চার্জ না হওয়ার জন্য Google Play-তে বাতিল করো।';

  @override
  String get deleteManageSubscription => 'সাবস্ক্রিপশন ম্যানেজ করো';

  @override
  String get deleteWhyLeaving => 'কেন যাচ্ছো? (ঐচ্ছিক)';

  @override
  String deleteConfirmLabel(String word) {
    return 'নিশ্চিত করতে $word টাইপ করো';
  }

  @override
  String get deleteReasonNotEnough => 'যথেষ্ট ব্যবহার করি না';

  @override
  String get deleteReasonDidntHelp => 'পড়ায় সাহায্য করেনি';

  @override
  String get deleteReasonTooManyNotifs => 'অনেক বেশি বিজ্ঞপ্তি';

  @override
  String get deleteReasonDataWorry => 'ডেটা নিয়ে চিন্তিত';

  @override
  String get deleteReasonOther => 'অন্য কিছু';

  @override
  String deleteScheduledSnack(String date) {
    return 'তোমার অ্যাকাউন্ট $date-এ মুছে যাবে। তার আগে লগ ইন করে রাখতে পারো।';
  }

  @override
  String get notifRemindersAndGoalTitle => 'রিমাইন্ডার ও লক্ষ্য';

  @override
  String get notifStudyReminder => 'পড়ার রিমাইন্ডার';

  @override
  String get notifRemindMeToStudy => 'পড়তে মনে করাও';

  @override
  String get notifTime => 'সময়';

  @override
  String get notifRemindMeAt => 'এই সময়ে মনে করাও';

  @override
  String get notifAlsoTellMe => 'এগুলোও বলো';

  @override
  String get notifStreakAboutToEnd => 'স্ট্রিক শেষ হতে চললে';

  @override
  String get notifEveningBeforeTest => 'পরীক্ষার আগের সন্ধ্যায়';

  @override
  String get notifWhenLevelUp => 'লেভেল বাড়লে';

  @override
  String get notifNotifications => 'বিজ্ঞপ্তি';

  @override
  String get notifAllowed => 'অনুমোদিত';

  @override
  String get notifNotAllowed => 'অনুমোদিত নয়';

  @override
  String get notifTurnOn => 'বিজ্ঞপ্তি চালু করো';

  @override
  String get notifTurnOnInSettings => 'সেটিংসে চালু করো';

  @override
  String get reminderTimeTitle => 'রিমাইন্ডারের সময়';

  @override
  String get reminderHour => 'ঘণ্টা';

  @override
  String get reminderMinute => 'মিনিট';

  @override
  String get reminderAmPm => 'সকাল বা সন্ধ্যা';

  @override
  String get reminderAm => 'am';

  @override
  String get reminderPm => 'pm';

  @override
  String get dailyGoalTitle => 'দৈনিক লক্ষ্য';

  @override
  String dailyGoalNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes মিনিট',
      one: '1 মিনিট',
    );
    return 'হোমে আজকের ধাপগুলো মোটামুটি $_temp0 হবে।';
  }

  @override
  String get dailyGoalSemantics => 'মিনিটে দৈনিক লক্ষ্য';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes মি';
  }

  @override
  String get dailyGoalStudyEachDay => 'প্রতিদিন পড়ো';

  @override
  String get appearanceTheme => 'থিম';

  @override
  String get appearanceLight => 'লাইট';

  @override
  String get appearanceDark => 'ডার্ক';

  @override
  String get appearanceDarkHint => 'রাতে ডার্ক মোড চোখে আরাম দেয়।';

  @override
  String get appearanceLightsOff => 'লাইট বন্ধ…';

  @override
  String get appearanceGoodMorning => 'শুভ সকাল!';

  @override
  String get appearanceDimming => 'পেবি ঘরটি আবছা করছে';

  @override
  String get appearanceOpeningCurtains => 'পেবি পর্দা খুলছে';

  @override
  String get helpTellUs => 'আমাদের বলো';

  @override
  String get helpEmailUs => 'আমাদের ইমেইল করো';

  @override
  String get helpThanks => 'ধন্যবাদ, তোমার বার্তা পেয়েছি।';

  @override
  String get feedbackWrongAnswer => 'ভুল উত্তর রিপোর্ট করো';

  @override
  String get feedbackBug => 'কিছু কাজ করছে না';

  @override
  String get feedbackFeature => 'একটি ফিচার সাজেস্ট করো';

  @override
  String get feedbackHint => 'কী হয়েছে বলো (কমপক্ষে ১০ অক্ষর)।';

  @override
  String get feedbackSend => 'পাঠাও';

  @override
  String get feedbackLimitNote => 'দিনে ২টি ও সপ্তাহে ৫টি বার্তা পাঠাতে পারো।';

  @override
  String get feedbackFailGeneric => 'পাঠানো যায়নি। আবার চেষ্টা করো।';

  @override
  String get feedbackFailDay =>
      'আজ যত মতামত নিতে পারি নিয়েছি। কাল আবার চেষ্টা করো।';

  @override
  String get feedbackFailWeek =>
      'এই সপ্তাহে যত মতামত নিতে পারি নিয়েছি। পরের সপ্তাহে আবার চেষ্টা করো।';

  @override
  String get feedbackFailTooShort => 'সাহায্য করতে কমপক্ষে ১০ অক্ষর লেখো।';

  @override
  String get feedbackFailOffline =>
      'তুমি অফলাইনে আছো। কানেকশন দেখে আবার চেষ্টা করো।';

  @override
  String get privacySummary1 =>
      'ACADEMe চালাতে তোমার অ্যাকাউন্ট, ক্লাস, বোর্ড ও বিষয়, পড়ার অগ্রগতি ও স্ট্রিক, ফোল্ডার, নোট এবং পেবি চ্যাট রাখি।';

  @override
  String get privacySummary2 =>
      'তোমার প্রশ্ন ও স্ক্যান করা ছবি ভারতের Sarvam AI-তে যায় যাতে পেবি উত্তর দিতে পারে। ছবি রাখি না, শুধু সেখান থেকে পড়া লেখা।';

  @override
  String get privacySummary3 =>
      'কোনো বিজ্ঞাপন নেই, অ্যাড ID নেই, লোকেশন নেই, আর তোমার ডেটা কখনো বিক্রি করি না।';

  @override
  String get privacySummary4 =>
      'অ্যাকাউন্টে যেকোনো সময় অ্যাকাউন্ট মুছতে পারো। ৩০ দিন পর সব মুছে যায়।';

  @override
  String get privacyDocuments => 'নথি';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get privacyTermsOfUse => 'ব্যবহারের শর্তাবলী';

  @override
  String get privacyYourData => 'তোমার ডেটা';

  @override
  String get privacyGetCopy => 'আমার ডেটার কপি নাও';

  @override
  String get privacyGrievanceOfficer => 'অভিযোগ কর্মকর্তা';

  @override
  String classBoardSave(int level, String board) {
    return 'সেভ · ক্লাস $level · $board';
  }

  @override
  String get classBoardYourClass => 'তোমার ক্লাস';

  @override
  String get classBoardYourBoard => 'তোমার বোর্ড';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'তোমার বিষয় ও প্ল্যান ক্লাস $level · $board-এ স্যুইচ হবে। এখন পর্যন্ত যা করেছো সেভ থাকবে।';
  }

  @override
  String get classBoardSubjects => 'বিষয়';

  @override
  String get classBoardStream => 'স্ট্রিম';

  @override
  String get classBoardAllSubjects => 'সব বিষয়';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'এখন ক্লাস $level · $board বিষয় দেখাচ্ছে';
  }

  @override
  String get reminderPrimerTitle => 'পরীক্ষার আগে একটা নাজ পাও';

  @override
  String get reminderPrimerPromise1 =>
      'প্রতি পরীক্ষার ৩ দিন আগে, আগের সন্ধ্যায় ও সেই সকালে মনে করিয়ে দেওয়া';

  @override
  String get reminderPrimerPromise2 =>
      'পড়ার রিমাইন্ডার, শুধু তোমার বেছে নেওয়া দিন ও সময়ে';

  @override
  String get reminderPrimerPromise3 =>
      'আর কিছু নয়। Me-তে যেকোনো সময় বদলাতে পারো';

  @override
  String get reminderPrimerAllow => 'অনুমতি দাও';

  @override
  String get paywallWelcomeSnack => 'ACADEMe Pro-তে স্বাগতম';

  @override
  String get paywallTagline =>
      'দৈনিক ও সাপ্তাহিক সীমা 3×। একই রিফিল ঘড়ি — পড়ার জন্য আরও জায়গা।';

  @override
  String get paywallOpeningPlay => 'Google Play খুলছে…';

  @override
  String get paywallRestoring => 'রিস্টোর হচ্ছে…';

  @override
  String get paywallRestore => 'কেনাকাটা রিস্টোর করো';

  @override
  String get paywallUnavailableTitle => 'এই ডিভাইসে কেনাকাটা নেই';

  @override
  String get paywallUnavailableBody =>
      'Pro নিতে ACADEMe Google Play থেকে ইনস্টল করে Play-এ সাইন ইন করো।';

  @override
  String get paywallBenefitAskme => 'প্রতিদিন 3× ASKMe প্রশ্ন';

  @override
  String get paywallBenefitScan => 'প্রতিদিন 3× স্ক্যান';

  @override
  String get paywallBenefitCheck => 'প্রতিদিন 3× উত্তর যাচাই';

  @override
  String get paywallBenefitLessons => 'তোমার নোট থেকে সোয়াইপ পাঠ';

  @override
  String get paywallBenefitProgress => 'My Progress সাপ্তাহিক সারাংশ';

  @override
  String get paywallMonthly => 'মাসিক';

  @override
  String get paywallAnnual => 'বার্ষিক';

  @override
  String paywallPlanSemantics(String title) {
    return '$title প্ল্যান';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return 'প্রথম মাস $introPrice, তারপর $price/মাস';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/মাস';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/বছর';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'প্রায় $monthlyPrice/মাস · ১৭% বাঁচাও · অটো রিনিউ';
  }

  @override
  String get paywallDetailAnnual => '১৭% বাঁচাও · অটো রিনিউ';

  @override
  String get paywallDetailRenews => 'অটো রিনিউ হয়';

  @override
  String get paywallBestValue => 'সেরা ভ্যালু';

  @override
  String get paywallSmallPrint =>
      'অটো রিনিউ। Google Play-এ যেকোনো সময় বাতিল করো।';

  @override
  String get paywallTerms => 'শর্তাবলী';

  @override
  String get paywallPrivacy => 'গোপনীয়তা';

  @override
  String get upgradeTitle => 'Pro নাও · 3× সীমা';

  @override
  String get limitAskmeTitle => 'আজকের ফ্রি প্রশ্ন শেষ';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ASKMe প্রশ্ন',
      one: '1 ASKMe প্রশ্ন',
    );
    return 'ফ্রিতে দিনে $_temp0। Pro প্রতিদিন 3× দেয়।';
  }

  @override
  String get limitScanTitle => 'আজকের ফ্রি স্ক্যান শেষ';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count স্ক্যান',
      one: '1 স্ক্যান',
    );
    return 'ফ্রিতে দিনে $_temp0। Pro প্রতিদিন 3× দেয়।';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'আজকের ফ্রি যাচাই শেষ',
      one: 'আজকের ফ্রি যাচাই শেষ',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count উত্তর যাচাই',
      one: 'একটি উত্তর যাচাই',
    );
    return 'ফ্রিতে দিনে $_temp0। Pro প্রতিদিন 3× দেয়।';
  }

  @override
  String get limitLessonsTitle => 'নোট থেকে পাঠ Pro-তে';

  @override
  String get limitLessonsBody =>
      'নোট রাখা ফ্রি। Pro-তে পেবি সেগুলো কুইজসহ সোয়াইপ পাঠ বানায়।';

  @override
  String get limitMaybeLater => 'পরে হয়তো';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'প্ল্যান ও সীমা';

  @override
  String get proCardSubtitleFree => 'প্ল্যান ও সীমা · Pro-তে 3×';

  @override
  String get proCardSubtitleMonthly => 'Pro · মাসিক';

  @override
  String get proCardSubtitleAnnual => 'Pro · বার্ষিক';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'ম্যানেজ';

  @override
  String get proOnPro => 'তুমি Pro-তে আছো';

  @override
  String get proOnFree => 'তুমি ফ্রিতে আছো';

  @override
  String get proMetaFree => 'দৈনিক ও সাপ্তাহিক সীমা · 12:00 AM IST';

  @override
  String get proMetaBillingIssue => 'Pro রাখতে Google Play-এ পেমেন্ট ঠিক করো';

  @override
  String get proMetaActiveNoExpiry => '3× দৈনিক সীমা · সাপ্তাহিক সেফটি ক্যাপ';

  @override
  String proMetaAnnualRenews(String date) {
    return 'বার্ষিক · $date-এ রিনিউ · 3× সীমা';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'মাসিক · $date-এ রিনিউ · 3× সীমা';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro $date-এ শেষ';
  }

  @override
  String get proStatusActive => 'সক্রিয়';

  @override
  String get proStatusFree => 'ফ্রি';

  @override
  String get proDailyLimits => 'দৈনিক সীমা';

  @override
  String get proResetsDaily => 'প্রতিদিন 12:00 AM IST-এ রিসেট';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'Scan';

  @override
  String get proFeatureCheck => 'Check';

  @override
  String get proFeatureLessons => 'পাঠ';

  @override
  String get proWeeklyLimit => 'সাপ্তাহিক সীমা';

  @override
  String get proResetsMondays => 'সোমবারে রিসেট · 12:00 AM IST';

  @override
  String proResetsOnDay(String day) {
    return '$day-এ রিসেট · 12:00 AM IST';
  }

  @override
  String get proAllFeatures => 'সব ফিচার';

  @override
  String get proManageInPlay => 'Google Play-এ ম্যানেজ করো';

  @override
  String get proResetsSoon => 'শীঘ্রই';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ঘণ্টায়',
      one: '1 ঘণ্টায়',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'তোমার পেমেন্ট পেন্ডিং। Google Play নিশ্চিত করলেই Pro চালু হবে।';

  @override
  String get proNoticeNoPurchase =>
      'এই Google অ্যাকাউন্টে কোনো ACADEMe Pro কেনাকাটা পাওয়া যায়নি।';

  @override
  String get proNoticeNotAllowed => 'এই Google অ্যাকাউন্টে কেনাকাটা বন্ধ আছে।';

  @override
  String get proNoticeAlreadyOwned =>
      'এই Google অ্যাকাউন্টে আগে থেকেই Pro আছে। কেনাকাটা রিস্টোর করো ট্যাপ করো।';

  @override
  String get proNoticeUnavailable => 'এই ডিভাইসে কেনাকাটা নেই।';

  @override
  String get proNoticeStoreError =>
      'Google Play শেষ করতে পারেনি। আবার চেষ্টা করো।';

  @override
  String get askmeNewChat => 'নতুন চ্যাট';

  @override
  String askmeStudying(String name) {
    return 'কী পড়ছি, $name?';
  }

  @override
  String get askmeModeExplainLine => 'পেবি সহজ করে, ধাপে ধাপে বোঝায়।';

  @override
  String get askmeModeSolveLine => 'পেবি হিন্ট দেয়। তুমি সলভ করো।';

  @override
  String get askmeModeQuizLine => 'পেবি প্রশ্ন করে, তুমি উত্তর দাও, XP পাও।';

  @override
  String get askmeSuggestExplain1 => 'আলোর প্রতিফলন সহজ করে বোঝাও';

  @override
  String get askmeSuggestExplain2 => 'আকাশ নীল কেন?';

  @override
  String get askmeSuggestExplain3 => 'সালোকসংশ্লেষণ কী?';

  @override
  String get askmeSuggestSolve1 =>
      '2x + 3y = 11 এবং x − 2y = −12 সলভ করতে সাহায্য করো';

  @override
  String get askmeSuggestSolve2 => 'r = 7 cm বৃত্তের ক্ষেত্রফল বের করো';

  @override
  String get askmeSuggestSolve3 => 'H₂ + O₂ → H₂O ব্যালেন্স করো';

  @override
  String get askmeSuggestQuiz1 => 'Light নিয়ে কুইজ দাও';

  @override
  String get askmeSuggestQuiz2 => 'রৈখিক সমীকরণে ৫টা প্রশ্ন দাও';

  @override
  String get askmeSuggestQuiz3 => 'French Revolution নিয়ে কুইজ দাও';

  @override
  String get askmeModeExplain => 'বোঝাও';

  @override
  String get askmeModeSolve => 'সলভ';

  @override
  String get askmeModeQuiz => 'কুইজ';

  @override
  String get askmeFollowNextStep => 'পরের ধাপ';

  @override
  String get askmeFollowFullSolution => 'পুরো সমাধান';

  @override
  String get askmeFollowNextQuestion => 'পরের প্রশ্ন';

  @override
  String get askmeFollowQuizMe => 'কুইজ';

  @override
  String get askmeFollowGoDeeper => 'আরও গভীরে';

  @override
  String get askmeSendNextStep => 'পরের ধাপ বলো।';

  @override
  String get askmeSendFullSolution => 'পুরো সমাধান দেখাও।';

  @override
  String get askmeSendNextQuestion => 'পরের প্রশ্ন।';

  @override
  String get askmeSendGoDeeper => 'আরও গভীরে বলো।';

  @override
  String get askmeSendQuizMe => 'এটা নিয়ে কুইজ দাও।';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe এখনও রেডি নয়। পেবি শিগগির আসবে।';

  @override
  String get askmeFailureSignedOut => 'তুমি লগ আউট হয়ে গেছো। আবার লগ ইন করো।';

  @override
  String get askmeFailureLimitReached =>
      'আজকের ফ্রি প্রশ্ন শেষ। মধ্যরাতে ফিরে আসবে।';

  @override
  String get askmeThinking => 'পেবি ভাবছে';

  @override
  String get historyTitle => 'হিস্ট্রি';

  @override
  String get historySearchHint => 'তোমার প্রশ্ন খুঁজো';

  @override
  String get historyLoadError => 'চ্যাট লোড হয়নি। আবার চেষ্টা';

  @override
  String get historyEmpty => 'পেবিকে করা প্রশ্ন এখানে দেখাবে।';

  @override
  String get historyThisWeek => 'এই সপ্তাহ';

  @override
  String get historyEarlier => 'আগে';

  @override
  String get historyNow => 'এখন';

  @override
  String historyHoursAgo(int hours) {
    return '$hoursঘ';
  }

  @override
  String get historyWeekdayMon => 'সোম';

  @override
  String get historyWeekdayTue => 'মঙ্গল';

  @override
  String get historyWeekdayWed => 'বুধ';

  @override
  String get historyWeekdayThu => 'বৃহ';

  @override
  String get historyWeekdayFri => 'শুক্র';

  @override
  String get historyWeekdaySat => 'শনি';

  @override
  String get historyWeekdaySun => 'রবি';

  @override
  String get historyMonthJan => 'জানু';

  @override
  String get historyMonthFeb => 'ফেব';

  @override
  String get historyMonthMar => 'মার্চ';

  @override
  String get historyMonthApr => 'এপ্রি';

  @override
  String get historyMonthMay => 'মে';

  @override
  String get historyMonthJun => 'জুন';

  @override
  String get historyMonthJul => 'জুল';

  @override
  String get historyMonthAug => 'আগ';

  @override
  String get historyMonthSep => 'সেপ্টে';

  @override
  String get historyMonthOct => 'অক্টো';

  @override
  String get historyMonthNov => 'নভে';

  @override
  String get historyMonthDec => 'ডিসে';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'তোমার প্রশ্নে যোগ করো';

  @override
  String get attachCamera => 'ক্যামেরা';

  @override
  String get attachPhotos => 'ফটো';

  @override
  String get replyHelpful => 'সাহায্য করেছে';

  @override
  String get replyNotHelpful => 'সাহায্য করেনি';

  @override
  String get replyCopy => 'কপি';

  @override
  String get replyCopied => 'কপি হয়েছে';

  @override
  String get replyReportTitle => 'এই উত্তর রিপোর্ট করো';

  @override
  String get replyReportThanks => 'ধন্যবাদ। আমরা এই উত্তর দেখব।';

  @override
  String get reportTooltip => 'রিপোর্ট';

  @override
  String get reportSendFailed => 'রিপোর্ট পাঠানো যায়নি। আবার চেষ্টা করো।';

  @override
  String get reportBody => 'পেবিকে আরও নিরাপদ করতে প্রতিটা রিপোর্ট পড়ি।';

  @override
  String get reportReasonWrong => 'এটা ভুল';

  @override
  String get reportReasonHarmful => 'এটা ক্ষতিকর বা অনিরাপদ';

  @override
  String get reportReasonOffensive => 'এটা অশালীন বা আপত্তিকর';

  @override
  String get reportReasonOther => 'অন্য কিছু';

  @override
  String get progressTitle => 'আমার প্রগ্রেস';

  @override
  String get progressLoading => 'এই সপ্তাহ লোড হচ্ছে…';

  @override
  String get progressLoadError => 'এই সপ্তাহের সারাংশ লোড হয়নি।';

  @override
  String get progressHoldTitle => 'আমার প্রগ্রেস Pro-এর অংশ';

  @override
  String get progressHoldBody =>
      'ACADEMe Pro দিয়ে স্ট্রিক, লেভেল আর স্টাডি ইনসাইট দেখো।';

  @override
  String get progressGoProLimits => 'Go Pro · 3× লিমিট';

  @override
  String get progressStudyDays => 'পড়ার দিন';

  @override
  String get progressThisWeek => 'এই সপ্তাহ';

  @override
  String get progressTodayStudied => 'আজ · পড়েছো';

  @override
  String get progressTodayNotYet => 'আজ · এখনও না';

  @override
  String get progressTabSummary => 'সারাংশ';

  @override
  String get progressTabProgress => 'প্রগ্রেস';

  @override
  String get progressTabActivity => 'অ্যাক্টিভিটি';

  @override
  String get progressSubjectsThisWeek => 'এই সপ্তাহের বিষয়';

  @override
  String get progressCompleted => 'শেষ';

  @override
  String get progressOverallGrade => 'মোট গ্রেড';

  @override
  String get progressKeepItUp => 'এভাবেই চালিয়ে যাও';

  @override
  String get progressStartJourney => 'তোমার যাত্রা শুরু করো';

  @override
  String get progressCourseProgress => 'কোর্স প্রগ্রেস';

  @override
  String get progressLessonsEmpty => 'যে পাঠ শেষ করবে সেগুলো এখানে দেখাবে।';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পাঠ',
      one: '১টি পাঠ',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'অ্যাক্টিভিটি';

  @override
  String get progressStudyDaysEmpty => 'তোমার পড়ার দিন এখানে দেখাবে।';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এই সপ্তাহে $countটি সক্রিয় দিন।',
      one: 'এই সপ্তাহে ১টি সক্রিয় দিন।',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'তোমার যাত্রা শুরু করার সময়!';

  @override
  String get progressCtaMomentum => 'তোমার গতি ধরে রাখো';

  @override
  String get progressCtaHabit => 'তুমি একটা অভ্যাস গড়ছো';

  @override
  String get progressCtaNext => 'পরের ধাপ দেখো';

  @override
  String get progressNextSteps => 'পরের ধাপ';

  @override
  String get progressYourSetup => 'তোমার সেটআপ';

  @override
  String get progressWhatNext => 'এবার কী করবে';

  @override
  String get progressNextWithStudy =>
      'এই সপ্তাহে পাঠ শেষ করতে থাকো। শেষ হলে গ্রেড আপডেট হয়।';

  @override
  String get progressNextNoStudy =>
      'Me-এ ক্লাস আর বোর্ড কনফার্ম করো। তারপর Study খুলে প্রথম পাঠ শেষ করো।';

  @override
  String get progressWeekEmpty => 'এই সপ্তাহে এখনও কোনো পড়া লগ হয়নি।';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি সক্রিয় দিন',
      one: '১টি সক্রিয় দিন',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পাঠ',
      one: '১টি পাঠ',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি অধ্যায় টেস্ট',
      one: '১টি অধ্যায় টেস্ট',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'এই সপ্তাহ: $parts।';
  }

  @override
  String get progressWeekdayMon => 'সো';

  @override
  String get progressWeekdayTue => 'মং';

  @override
  String get progressWeekdayWed => 'বু';

  @override
  String get progressWeekdayThu => 'বৃ';

  @override
  String get progressWeekdayFri => 'শু';

  @override
  String get progressWeekdaySat => 'শ';

  @override
  String get progressWeekdaySun => 'র';

  @override
  String get subjectsStreamTitle => 'তোমার স্ট্রিম';

  @override
  String get subjectsSave => 'সেভ';

  @override
  String get subjectsLoadError => 'বিষয় লোড হয়নি। আবার চেষ্টা';

  @override
  String get subjectsMain => 'মূল';

  @override
  String get subjectsOptional => 'ঐচ্ছিক';

  @override
  String streamSwipeFor(String name) {
    return '$name-এর জন্য সোয়াইপ করো। Me-এ যেকোনো সময় বদলাতে পারো।';
  }

  @override
  String get streamChangeInMe => 'Me-এ যেকোনো সময় বদলাতে পারো।';

  @override
  String streamChoose(String name) {
    return '$name বেছে নাও';
  }

  @override
  String get classDialLabel => 'ক্লাস';

  @override
  String classDialSemantics(int level) {
    return 'ক্লাস $level';
  }

  @override
  String get studyTitle => 'পড়াশোনা';

  @override
  String get studyCourses => 'কোর্স';

  @override
  String get studyFolders => 'ফোল্ডার';

  @override
  String get studyDone => 'হয়ে গেছে';

  @override
  String get studyKeep => 'রাখো';

  @override
  String get studyDelete => 'মুছো';

  @override
  String get studySave => 'সেভ';

  @override
  String get studyCreate => 'বানাও';

  @override
  String get studyAdd => 'যোগ করো';

  @override
  String get studyOptional => 'ঐচ্ছিক';

  @override
  String get studyName => 'নাম';

  @override
  String get studyToday => 'আজ';

  @override
  String get studyComingSoon => 'শীঘ্রই আসছে';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'অধ্যায় $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পাঠের',
      one: '1 পাঠের',
    );
    return '$_temp0 মধ্যে $done শেষ';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count শীঘ্রই',
      one: '1 শীঘ্রই',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'বোর্ড পরীক্ষায় নেই';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count কার্ড',
      one: '1 কার্ড',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count কুইক চেক',
      one: '1 কুইক চেক',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count প্রশ্ন',
      one: '1 প্রশ্ন',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count অধ্যায়',
      one: '1 অধ্যায়',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পাঠ',
      one: '1 পাঠ',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'প্রায় $minutes মিনিট';
  }

  @override
  String get coursesNeedSyllabus => 'কোর্স দেখতে হোমে ক্লাস আর বোর্ড সেট করো।';

  @override
  String get coursesLoadError => 'কোর্স লোড হয়নি। আবার চেষ্টা';

  @override
  String coursesComingSoon(String syllabus) {
    return '$syllabus-এর পাঠ আসছে। ততক্ষণ ASKMe-তে পেব্বিকে কিছু জিজ্ঞাসা করো।';
  }

  @override
  String get coursesNoFilterMatch => 'এই ফিল্টারে কোনো অধ্যায় নেই।';

  @override
  String get coursesFinishedEmpty => 'শেষ হওয়া অধ্যায় এখানে দেখাবে।';

  @override
  String get coursesStartedEmpty => 'যে অধ্যায় শুরু করেছ সেগুলো এখানে দেখাবে।';

  @override
  String get coursesGoAgain => 'আবার করো';

  @override
  String coursesContinueCard(int current, int total) {
    return 'চালিয়ে যাও · কার্ড $current / $total';
  }

  @override
  String get coursesStart => 'শুরু করো';

  @override
  String get filterAll => 'সব';

  @override
  String get filterInProgress => 'চলছে';

  @override
  String get filterDone => 'হয়ে গেছে';

  @override
  String get filterFilters => 'ফিল্টার';

  @override
  String filterFiltersOn(int count) {
    return 'ফিল্টার, $count অন';
  }

  @override
  String get filterClear => 'মুছে ফেলো';

  @override
  String get filterSort => 'সর্ট';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count অধ্যায়',
      one: '1 অধ্যায়',
    );
    return '$_temp0 দেখাও';
  }

  @override
  String get filterBoardExamOnly => 'শুধু বোর্ড পরীক্ষা';

  @override
  String get filterBoardExamOnlyDesc => 'স্কুল-অ্যাসেসড অধ্যায় লুকাও';

  @override
  String get filterReadyToStudy => 'পড়ার জন্য তৈরি';

  @override
  String get filterReadyToStudyDesc => 'শীঘ্রই আসা অধ্যায় লুকাও';

  @override
  String get filterRevisionDue => 'রিভিশন বাকি';

  @override
  String get filterRevisionDueDesc => 'যেখানে রাখা কার্ড রিভাইজ করতে হবে';

  @override
  String get filterSortTextbook => 'বই';

  @override
  String get filterSortMostMarks => 'বেশি মার্কস';

  @override
  String get filterSortRecent => 'সাম্প্রতিক';

  @override
  String get filterFlagBoardExam => 'বোর্ড পরীক্ষা';

  @override
  String get filterFlagReady => 'তৈরি';

  @override
  String get filterFlagRevisionDue => 'রিভিশন বাকি';

  @override
  String filterRemove(String label) {
    return '$label সরাও';
  }

  @override
  String get folderNew => 'নতুন ফোল্ডার';

  @override
  String get folderEdit => 'ফোল্ডার এডিট';

  @override
  String get folderEmptyHint =>
      'টেস্ট, হোমওয়ার্ক বা যেকোনো প্রস্তুতির জন্য ফোল্ডার বানাও। তারিখ দিলে দিন প্ল্যান হয়ে যায়।';

  @override
  String get folderEmpty => 'খালি';

  @override
  String get folderNothingLeftToday => 'আজ আর কিছু নেই';

  @override
  String folderTodoToday(int count) {
    return 'আজ $countটা করতে হবে';
  }

  @override
  String get folderNoDate => 'কোনো তারিখ নেই';

  @override
  String folderPercentReady(int percent) {
    return '$percent% তৈরি';
  }

  @override
  String get folderWhatsFor => 'এই ফোল্ডার কীসের জন্য?';

  @override
  String get folderAddChaptersPlan =>
      'অধ্যায় যোগ করো, পেব্বি তোমার দিন প্ল্যান করবে।';

  @override
  String get folderAddChapters => 'অধ্যায় যোগ করো';

  @override
  String get folderFromSyllabus => 'তোমার সিলেবাস থেকে';

  @override
  String get folderWriteNote => 'নোট লেখো';

  @override
  String get folderNoteSubtitle => 'যা মনে রাখতে চাও';

  @override
  String get folderScanNotes => 'নোটস স্ক্যান করো';

  @override
  String get folderScanNotesSubtitle => 'পৃষ্ঠার ছবি, পাঠ হয়ে যায়';

  @override
  String get folderAddTodo => 'টু-ডু যোগ করো';

  @override
  String get folderAddDate => 'তারিখ যোগ করো';

  @override
  String get folderRemoveDate => 'তারিখ সরাও';

  @override
  String get folderReminders => 'এই ফোল্ডারের রিমাইন্ডার';

  @override
  String get folderDeleteTitle => 'এই ফোল্ডার মুছবে?';

  @override
  String get folderDeleteBody => 'নোট আর টু-ডুও যাবে। পাঠ আর প্রোগ্রেস থাকবে।';

  @override
  String get folderTitle => 'ফোল্ডার';

  @override
  String get folderEditRemindersTooltip => 'এডিট আর রিমাইন্ডার';

  @override
  String get folderDeleteTooltip => 'ফোল্ডার মুছো';

  @override
  String get folderLoadError => 'ফোল্ডার লোড হয়নি। আবার চেষ্টা';

  @override
  String folderTodayMinutes(int minutes) {
    return 'আজ · $minutes মিনিট';
  }

  @override
  String get folderSeePlan => 'প্ল্যান দেখো';

  @override
  String get folderAddChaptersOrTodos => 'অধ্যায় বা টু-ডু যোগ করো।';

  @override
  String get folderNothingLeftForToday => 'আজকের জন্য আর কিছু নেই।';

  @override
  String get folderInThisFolder => 'এই ফোল্ডারে';

  @override
  String get folderFromNotesDone => 'তোমার নোট থেকে · হয়ে গেছে';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'তোমার নোট থেকে · $minutes মিনিট';
  }

  @override
  String get folderNote => 'নোট';

  @override
  String get folderSaveNote => 'নোট সেভ করো';

  @override
  String get folderTypeHere => 'এখানে লেখো…';

  @override
  String get folderAddTo => 'ফোল্ডারে যোগ করো';

  @override
  String get folderCouldntMake => 'ফোল্ডার হয়নি। আবার চেষ্টা করো।';

  @override
  String folderAddedTo(String name) {
    return '$name-এ যোগ হয়েছে';
  }

  @override
  String get folderYourFolder => 'তোমার ফোল্ডার';

  @override
  String get folderPlan => 'প্ল্যান';

  @override
  String folderPlanTo(String date) {
    return '$date পর্যন্ত প্ল্যান';
  }

  @override
  String get folderPlanBody =>
      'এই ফোল্ডারের অধ্যায় থেকে তৈরি। কিছু মিস হলে নিজে থেকে পরের দিনে চলে যায়।';

  @override
  String get folderTestDay => 'টেস্টের দিন · তুমি তৈরি';

  @override
  String get folderRestDay => 'বিশ্রামের দিন';

  @override
  String get folderDueTomorrow => 'কাল';

  @override
  String get folderDueYesterday => 'গতকাল';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন',
      one: '1 দিন',
    );
    return '$_temp0 আগে';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিনে',
      one: '1 দিনে',
    );
    return '$_temp0';
  }

  @override
  String chapterTitle(int number) {
    return 'অধ্যায় $number';
  }

  @override
  String get chapterLessons => 'পাঠ';

  @override
  String get chapterTest => 'অধ্যায় টেস্ট';

  @override
  String chapterTestLast(int correct, int total) {
    return 'গতবার $correct/$total · আবার চেষ্টা';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count প্রশ্ন',
      one: '1 প্রশ্ন',
    );
    return 'প্রতি পাঠ থেকে $_temp0';
  }

  @override
  String get chapterKeptCards => 'রাখা কার্ড';

  @override
  String get chapterKeptEmpty => 'যেকোনো কার্ডে Keep ট্যাপ করলে এখানে সেভ হবে';

  @override
  String chapterKeptCount(int count) {
    return '$countটা রিভাইজ করতে হবে';
  }

  @override
  String get chapterAllDoneGoAgain => 'সব পাঠ শেষ · আবার';

  @override
  String chapterResumeCard(int current, int total) {
    return 'চালিয়ে যাও · কার্ড $current / $total';
  }

  @override
  String get chapterNextLesson => 'পরের পাঠ';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'পাঠ $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes ঠিক';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'শীঘ্রই · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'পাঠ শেষ · এখন টেস্ট';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'হয়ে গেছে · টেস্ট $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return ' · $count শীঘ্রই';
  }

  @override
  String get chapterNotInBoardExamSuffix => ' · বোর্ড পরীক্ষায় নেই';

  @override
  String get chapterReportGreat => 'দারুণ';

  @override
  String get chapterReportGood => 'ভালোই যাচ্ছে';

  @override
  String get chapterReportRetry => 'আবার চেষ্টা করো';

  @override
  String get chapterReportByLesson => 'পাঠ অনুযায়ী';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'যা মিস হয়েছে রিভাইজ করো';

  @override
  String get chapterAddToFolderAction => 'অধ্যায় ফোল্ডারে যোগ করো';

  @override
  String get chapterBackToChapter => 'অধ্যায়ে ফিরে যাও';

  @override
  String get chapterNoChaptersYet => 'তোমার ক্লাসের অধ্যায় এখনো নেই।';

  @override
  String get chapterAlreadyInFolder => 'আগে থেকেই এই ফোল্ডারে';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done শেষ';
  }

  @override
  String get chapterPickChapters => 'অধ্যায় বেছে নাও';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count অধ্যায়',
      one: '1 অধ্যায়',
    );
    return '$_temp0 যোগ করো';
  }

  @override
  String get chapterAddChaptersTitle => 'অধ্যায় যোগ করো';

  @override
  String get deckReportTitle => 'এই পাঠ রিপোর্ট করো';

  @override
  String get deckReportThanks => 'ধন্যবাদ। আমরা এই পাঠ দেখব।';

  @override
  String get deckLoadError => 'পাঠ লোড হয়নি। আবার চেষ্টা';

  @override
  String get deckPerfect => 'পারফেক্ট পাঠ!';

  @override
  String get deckLessonDone => 'পাঠ শেষ!';

  @override
  String get deckStatRight => 'ঠিক';

  @override
  String get deckStatKept => 'রাখা';

  @override
  String deckNextTitle(String title) {
    return 'পরের: $title';
  }

  @override
  String get deckStart => 'শুরু করো';

  @override
  String deckShowStep(int step) {
    return 'স্টেপ $step দেখাও';
  }

  @override
  String get deckCheck => 'চেক';

  @override
  String get deckNext => 'পরের';

  @override
  String get deckFinish => 'শেষ';

  @override
  String get deckPreviousCard => 'আগের কার্ড';

  @override
  String get deckNewLesson => 'নতুন পাঠ';

  @override
  String get deckByTheEnd => 'শেষে তুমি পারবে:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · প্রায় $minutes মিনিট';
  }

  @override
  String get deckConcept => 'কনসেপ্ট';

  @override
  String get deckInOneLook => 'এক নজরে';

  @override
  String get deckSummary => 'সারাংশ';

  @override
  String get deckThreeLines => 'পাঠ তিন লাইনে';

  @override
  String get deckKeptForRevision => 'রিভিশনের জন্য রাখা';

  @override
  String get deckKeptRevisionOne => 'এই পাঠের ১টি কার্ড রিভিশনে ফিরে আসবে।';

  @override
  String deckKeptRevisionMany(int count) {
    return 'এই পাঠের $countটি কার্ড রিভিশনে ফিরে আসবে।';
  }

  @override
  String get deckWorkedExample => 'সলভ্ড উদাহরণ';

  @override
  String deckStepTryFirst(int step) {
    return 'স্টেপ $step · আগে নিজে চেষ্টা করো';
  }

  @override
  String get deckRemember => 'মনে রাখো';

  @override
  String get deckKept => 'রাখা হয়েছে';

  @override
  String get deckAskPebby => 'পেব্বিকে জিজ্ঞাসা করো';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'এটা আরও সহজ করে বলো? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return '\"$title\" একটা উদাহরণ দিয়ে বলো?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'এটা কীভাবে সলভ করবে বলো: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'এটা ভুল হয়েছে: $question সঠিক কেন: $why';
  }

  @override
  String get deckAskExplainLesson => 'এই পাঠ বলো?';

  @override
  String get deckGoals => 'লক্ষ্য';

  @override
  String get quizQuickCheck => 'কুইক চেক';

  @override
  String quizQuestionOf(int current, int total) {
    return 'প্রশ্ন $current / $total';
  }

  @override
  String get quizPraise1 => 'নাইস! ঠিক আছে।';

  @override
  String get quizPraise2 => 'একদম সঠিক!';

  @override
  String get quizPraise3 => 'পেয়ে গেছ!';

  @override
  String get quizPraise4 => 'ঠিক, দারুণ!';

  @override
  String get quizPraise5 => 'একদম ঠিক!';

  @override
  String get quizHeresWhy => 'এই জন্য';

  @override
  String get quizYourAnswer => 'তোমার উত্তর';

  @override
  String get quizRightAnswer => 'সঠিক উত্তর';

  @override
  String get quizKeptForYou => 'তোমার জন্য রাখা';

  @override
  String get quizComesBack => 'এই প্রশ্ন কাল রিভিশনে ফিরে আসবে।';

  @override
  String get quizNotQuite => 'ঠিক না। পরে: কেন।';

  @override
  String quizStreak(int count) {
    return '$countবার টানা';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'রিভিশন';

  @override
  String get studyRevisionEmptyTitle => 'রিভাইজ করার কিছু নেই';

  @override
  String get studyRevisionEmptyBody =>
      'পাঠে কার্ড Keep করো, বা প্রশ্ন ভুল হলে সেগুলো এখানে আসে।';

  @override
  String get studyRevisionDone => 'রিভিশন শেষ';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew জানতে · $almost প্রায় · $again কাল আবার';
  }

  @override
  String get studyRevisionHint => 'উত্তর ভাবো, চেক করতে ট্যাপ করো।';

  @override
  String get studyRevisionShowAnswer => 'উত্তর দেখাও';

  @override
  String get studyRevisionAgain => 'জানি না';

  @override
  String get studyRevisionAlmost => 'প্রায়';

  @override
  String get studyRevisionKnew => 'জানি';

  @override
  String chapterTestDeckTitle(int number) {
    return 'অধ্যায় $number টেস্ট';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count পাঠের',
      one: '1 পাঠের',
    );
    return '$_temp0 মধ্যে $done';
  }

  @override
  String get actionTryAgain => 'আবার চেষ্টা করো';

  @override
  String get actionGoPro => 'Pro নাও';

  @override
  String get actionBack => 'পেছনে';

  @override
  String get actionClose => 'বন্ধ করো';

  @override
  String get failureNetwork => 'কানেকশন নেই। ইন্টারনেট দেখে আবার চেষ্টা করো।';

  @override
  String get failureUnknown => 'কিছু ভুল হয়েছে। আবার চেষ্টা করো।';
}
