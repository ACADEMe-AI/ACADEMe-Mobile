// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Assamese (`as`).
class AppLocalizationsAs extends AppLocalizations {
  AppLocalizationsAs([String locale = 'as']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'এপৰ ভাষা';

  @override
  String get meLanguageSheetBody =>
      'Pebby আৰু Scan ৰ শিকোৱাৰ উত্তৰসমূহত এই ভাষা ব্যৱহাৰ কৰা হয়। অনুবাদ সম্পূৰ্ণ হোৱাৰ লগে লগে এপৰ বাকী অংশও সলনি হ\'ব।';

  @override
  String get meMoreLanguagesComing => 'আৰু অধিক ভাষা সোনকালেই আহি আছে';

  @override
  String languageSwitchingTo(String name) {
    return 'চিহ্নিত কৰা হৈছে $name…';
  }

  @override
  String get navHome => 'মূল পৃষ্ঠা';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'পঢ়া-শুনা';

  @override
  String get navMe => 'মই';

  @override
  String get navScan => 'স্কেন';

  @override
  String get navSend => 'প্ৰেৰণ কৰক';

  @override
  String get askAnythingHint => 'যিকোনো কথা সোধক…';

  @override
  String get askAttach => 'সংলগ্ন কৰক';

  @override
  String get softUpdateDefaultMessage =>
      'নতুন সংস্কৰণ আহি গ’ল, আপুনি এইটো মিছ কৰিব নিবিচাৰিব!';

  @override
  String get softUpdateAction => 'আপডেট';

  @override
  String get softUpdateDismiss => 'এতিয়া নহয়';

  @override
  String get updateRequiredTitle => 'ৰাখক';

  @override
  String get updateRequiredBody =>
      'এই সংস্কৰণটোৱে এতিয়া আমাৰ চাৰ্ভাৰৰ সৈতে সংযোগ কৰিব নোৱাৰে। পঢ়া অব্যাহত ৰাবলৈ Play ত আপডেট কৰক।';

  @override
  String updateRequiredBuild(String build) {
    return 'ইনষ্টল কৰা সংস্কৰণ $build।';
  }

  @override
  String get updateRequiredAction => 'Google Play ত আপডেট কৰক';

  @override
  String get pebbySemantics => 'Pebby';

  @override
  String get welcomeHeadlineLead => 'অধিক চতুৰতাৰে';

  @override
  String get welcomeHeadlineAccent => 'পঢ়ক, বেছি সময় নহয়।';

  @override
  String get welcomeBody =>
      'আপুনি আচলতে যি পঢ়ি আছে তাৰ পৰা বনোৱা টোকা, কুইজ আৰু ফ্লেশ্ব কাৰ্ড।';

  @override
  String get welcomeGetStarted => 'আৰম্ভ কৰক';

  @override
  String get welcomeAlreadyHaveAccount => 'ইতিমধ্যে একাউণ্ট আছে নেকি?';

  @override
  String get welcomeNewUser => 'নতুন ব্যৱহাৰকাৰী নেকি?';

  @override
  String get welcomeLegal =>
      'আগবাঢ়ি গ’লে আপুনি আমাৰ চৰ্ত আৰু গোপনীয়তা নীতি মানি লয়।';

  @override
  String get authSignUp => 'ছাইন আপ';

  @override
  String get authLogIn => 'লগ ইন';

  @override
  String get authContinueGoogle => 'Google ৰ সৈতে অব্যাহত ৰাখক';

  @override
  String get authContinueApple => 'Apple ৰ সৈতে অব্যাহত ৰাখক';

  @override
  String get authContinueEmail => 'ইমেইলৰ সৈতে অব্যাহত ৰাখক';

  @override
  String get loginHeadlineLead => 'স্বাগতম';

  @override
  String get loginHeadlineAccent => 'পুনৰায়।';

  @override
  String get loginSubtitle =>
      'য’ৰ পৰা এৰিছিলো তাৰ পৰাই পুনৰ আৰম্ভ কৰিবলৈ লগ ইন কৰক।';

  @override
  String get authEmail => 'ইমেইল';

  @override
  String get authPassword => 'পাছৱৰ্ড';

  @override
  String get authShowPassword => 'পাছৱৰ্ড দেখুৱাওক';

  @override
  String get authHidePassword => 'পাছৱৰ্ড লুকুৱাওক';

  @override
  String get authForgotPassword => 'পাছৱৰ্ড পাহৰি গ’ل়ে নেকি?';

  @override
  String get authLoggingIn => 'লগ ইন হৈ আছে…';

  @override
  String get authNewHere => 'নতুন নেকি?';

  @override
  String get forgotPasswordLead => 'আপোনাৰ';

  @override
  String get forgotPasswordAccent => 'পাছৱৰ্ড পাহৰি গ’ল?';

  @override
  String get forgotPasswordSubtitle =>
      'আপোনাৰ ইমেইল লিখক আৰু মই এটা ৬-অংকৰ ক’ড পঠাম।';

  @override
  String get authSending => 'পঠিওৱা হৈছে…';

  @override
  String get authSendCode => 'ক’ড পঠাওক';

  @override
  String get resetCodeLead => 'আপোনাৰ';

  @override
  String get resetCodeAccent => 'ইমেইল পৰীক্ষা কৰক।';

  @override
  String resetCodeSubtitle(String email) {
    return 'যদি $email ৰ এটা ACADEMe একাউণ্ট আছে, তেন্তে এটা ৬-অংকৰ ক’ড আহি আছে। ই ১৫ মিনিটৰ পিছত মেয়াদ শেষ হ’ব।';
  }

  @override
  String get authPasteCode => 'ক’ড পেষ্ট কৰক';

  @override
  String get authChecking => 'পৰীক্ষা কৰা হৈছে…';

  @override
  String get authVerify => 'প্ৰমাণীকৰণ কৰক';

  @override
  String get resetDidntGetIt => 'নাপালে নেকি?';

  @override
  String get resetSendNewCode => 'এটা নতুন ক’ড পঠাওক';

  @override
  String get resetSendingNewCode => 'নতুন ক’ড পঠিওৱা হৈছে…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'নতুন ক’ড পঠিওৱা হ’ল। আপুনি 0:$seconds ত আকৌ সুধিব পাৰে';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'আপুনি 0:$seconds ত নতুন ক’ডৰ বাবে অনুৰোধ কৰিব পাৰে';
  }

  @override
  String get newPasswordLead => 'এটা নতুন';

  @override
  String get newPasswordAccent => 'পাছৱৰ্ড বাছনি কৰক।';

  @override
  String get newPasswordSubtitle =>
      'কমপক্ষে ৮ টা আখৰ। চিন্তা নকৰিব, মই নাচাওঁ।';

  @override
  String get authNewPassword => 'নতুন পাছৱৰ্ড';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ আখৰ';
  }

  @override
  String get authStartAgain => 'আকৌ আৰম্ভ কৰক';

  @override
  String get authSaving => 'সংৰক্ষণ কৰা হৈছে…';

  @override
  String get authSaveAndLogIn => 'সংৰক্ষণ কৰি লগ ইন কৰক';

  @override
  String get authFailureEmailTaken =>
      'এই ইমেইলটো ইতিমধ্যে এটা একাউণ্টত ব্যৱহাৰ কৰা হৈছে। তাৰ সলনি লগ ইন কৰক।';

  @override
  String get authFailureWrongCredentials => 'সেই ইমেইল আৰু পাছৱৰ্ড নিমিলে।';

  @override
  String get authFailureInvalidInput =>
      'আপোনাৰ বিৱৰণ পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get authFailureSignedOut => 'আপোনাৰ ছেছন শেষ হ’ল। আকৌ লগ ইন কৰক।';

  @override
  String get authFailureNetwork =>
      'ACADEMe ৰ সৈতে সংযোগ স্থাপন কৰিব পৰা নাই। আপোনাৰ সংযোগ পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get authFailureCanceled => 'ছাইন-ইন বাতিল কৰা হৈছিল।';

  @override
  String get authFailureProviderUnavailable =>
      'এই ছাইন-ইন বিকল্পটো এতিয়াও প্ৰস্তুত হোৱা নাই। বৰ্তমান ইমেইল ব্যৱহাৰ কৰক।';

  @override
  String get authFailureWrongCode =>
      'কোডটো সঠিক নহয়। ইমেইলটো পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get authFailureTooManyAttempts =>
      'বহুত বেছি ভুল চেষ্টা কৰা হ\'ল। নিজকে এটা নতুন কোড পঠাওক।';

  @override
  String get authFailureCodeExpired =>
      'সেই কোডটোৰ ম্যাদ শেষ হৈছে। নিজকে এটা নতুন কোড পঠাওক।';

  @override
  String get authFailureResetExpired =>
      'এই ৰিছেট লিংকটোৰ সময়সীমা শেষ হ\'ল। পাছৱৰ্ড পাহৰি গ’ল তাৰ পৰা আকৌ আৰম্ভ কৰক।';

  @override
  String get authFailureTooManyRequests =>
      'সেয়া বহুতো চেষ্টা হৈ গ’ল। অলপ অপেক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get authFailureWrongPassword => 'সেয়া আপোনাৰ বৰ্তমানৰ পাছৱৰ্ড নহয়।';

  @override
  String get authFailureGoogleTaken =>
      'সেই Google একাউণ্টটো আন এটা ACADEMe একাউণ্টৰ লগত সংলগ্ন হৈ আছে।';

  @override
  String get authFailurePasswordRequired =>
      'প্ৰথমে এটা পাছৱৰ্ড ছেট কৰক, যাতে আপুনি Google অবিহনেও লগ ইন কৰিব পাৰে।';

  @override
  String get signUpHiPebby => 'নমস্কাৰ, মই Pebby!';

  @override
  String signUpHiNamed(String name) {
    return 'নমস্কাৰ $name, মই Pebby!';
  }

  @override
  String get signUpAskFirstName => 'আৰম্ভ কৰাৰ আগতে, মই আপোনাক কি বুলি মাতিম?';

  @override
  String get signUpFirstName => 'প্ৰথম নাম';

  @override
  String signUpAskLastName(String name) {
    return 'আপোনাক লগ পাই ভাল লাগিল, $name! আৰু আপোনাৰ উপাধি কি?';
  }

  @override
  String get signUpLastName => 'উপাধি';

  @override
  String signUpAskEmail(String name) {
    return 'আপোনাৰ ইমেইল কি, $name?';
  }

  @override
  String get signUpEmailHint => 'আপুনি ইয়াকে লগ ইন কৰিবলৈ ব্যৱহাৰ কৰিব।';

  @override
  String get signUpEmailInvalid => 'ইটো ইমেইলৰ দৰে দেখা হোৱা নাই।';

  @override
  String get signUpCreatePassword => 'এটা পাছৱৰ্ড সৃষ্টি কৰক';

  @override
  String signUpPasswordHint(int count) {
    return 'কমপক্ষে $count টা আখৰ। চিন্তা নকৰিব, মই নাচাওঁ।';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'স্বাগতম, $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'আপোনাৰ ইতিমধ্যে এটা একাউণ্ট আছে, গতিকে আপুনি লগ ইন হৈ আছে।';

  @override
  String signUpYoureIn(String name) {
    return 'আপুনি সোমাইছে, $name!';
  }

  @override
  String get signUpAccountReady =>
      'আপোনাৰ একাউণ্ট প্ৰস্তুত হৈছে। ইয়াৰ পিছত, আপুনি কি পঢ়ে মোক কওক।';

  @override
  String get signUpHelloEmail =>
      'মই আপোনাক অধিক স্মাৰ্টভাৱে পঢ়াত সহায় কৰিম। আহক আপোনাৰ একাউণ্টটো ছেট আপ কৰোঁ, মাত্ৰ এটা মিনিট সময় লাগে।';

  @override
  String get signUpConnectingAccount => 'আপোনাৰ একাউণ্ট সংযোগ কৰা হৈছে…';

  @override
  String get signUpCheckName =>
      'আহক আপোনাৰ নামটো পৰীক্ষা কৰোঁ, তাৰ পিছত আপুনি সোমাব পাৰিব।';

  @override
  String get signUpConnecting => 'সংযোগ কৰা হৈছে…';

  @override
  String get signUpHiPebbyAction => 'নমস্কাৰ Pebby!';

  @override
  String get signUpCreatingAccount => 'আপোনাৰ একাউণ্ট সৃষ্টি কৰা হৈছে…';

  @override
  String get signUpCreateAccount => 'একাউণ্ট সৃষ্টি কৰক';

  @override
  String get signUpLetsGo => 'আহক যাওঁ';

  @override
  String get authContinue => 'অব্যাহত ৰাখক';

  @override
  String get homeSetupTitle => 'আপোনাৰ ডেশ্ববোৰ্ড ছেট আপ কৰক';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'ভাষা';

  @override
  String get homeSetupTaskAge => 'আপোনাৰ বয়স';

  @override
  String get homeSetupTaskClass => 'আপোনাৰ শ্রেণী';

  @override
  String get homeSetupTaskBoard => 'আপোনাৰ বোৰ্ড';

  @override
  String get homeSetupTaskSubjects => 'আপোনাৰ বিষয়সমূহ';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'হোমৱৰ্ক সমাধান কৰক';

  @override
  String get homeCheckAnswer => 'মোৰ উত্তৰ পৰীক্ষা কৰক';

  @override
  String get homeFlashcards => 'ফ্লেছকাৰ্ডসমূহ';

  @override
  String get homePickSubjects => 'আপোনাৰ বিষয়সমূহ বাছক';

  @override
  String homePickSubjectsBody(int xp) {
    return 'হোম আৰু ষ্টাডীত কেৱল আপুনি লোৱা বিষয়বোৰেই দেখুৱা হ’ব। +$xp XP';
  }

  @override
  String get setupLanguageTitle => 'আপুনি কোনটো ভাষাত পঢ়ে?';

  @override
  String setupChooseLanguage(String name) {
    return '$name বাছক';
  }

  @override
  String get setupLanguageFootnote =>
      'আপুনি চেটিংছত যিকোনো সময়তে ইয়াৰ সলনি কৰিব পাৰে।';

  @override
  String get setupAgeTitle => 'আপোনাৰ জন্ম কেতিয়া হৈছিল?';

  @override
  String get setupAgeSubtitle =>
      'যাতে আমি আপোনাৰ বয়সৰ উপযোগী কৰি ৰাখিব পাৰোঁ।';

  @override
  String get setupBirthYear => 'জন্মৰ বছৰ';

  @override
  String setupYouAreAge(int age) {
    return 'আপোনাৰ বয়স $age বছৰ।';
  }

  @override
  String get setupClassTitle => 'আপোনাৰ শ্ৰেণীলৈ ঘূৰাওক';

  @override
  String get setupClassSubtitle => 'ডায়েলটো ঘূৰাওক বা এটা নম্বৰত টিপক।';

  @override
  String setupImInClass(int level) {
    return 'মই ক্লাছ $level ত আছোঁ';
  }

  @override
  String get setupBoardTitle => 'কোনটো বোৰ্ড?';

  @override
  String get setupBoardSubtitle => 'আমি আপোনাৰ বোৰ্ডৰ পাঠ্যক্ৰম অনুসৰণ কৰোঁ।';

  @override
  String get setupStateBoardsSoon => 'ৰাজ্যিক বোৰ্ডসমূহ শীঘ্ৰেই আহি আছে।';

  @override
  String get setupFinish => 'ছেটআপ সম্পূৰ্ণ কৰক';

  @override
  String setupProgress(int step, int total) {
    return 'ছেট আপ · $step/$total';
  }

  @override
  String get setupLater => 'পিছত';

  @override
  String get setupChangeInMe =>
      'আপুনি ‘মই’ (Me) ত যিকোনো সময়তে ইয়াৰ সলনি কৰিব পাৰে।';

  @override
  String setupStreamTitle(int level) {
    return 'আপুনি ক্লাছ $level ত কি কি পঢ়ে?';
  }

  @override
  String get setupAnythingElse => 'আৰু কিবা আছে নেকি?';

  @override
  String get setupWhichSubjects => 'আপুনি কোনবোৰ বিষয় পঢ়ে?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus। আপোনাৰ মূল বিষয়সমূহ অন্তৰ্ভুক্ত কৰা হৈছে।';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus। যিকোনো নিলোৱা বিষয় বাদ দিবলৈ টিপক।';
  }

  @override
  String get homeYourSubjects => 'আপোনাৰ বিষয়সমূহ';

  @override
  String get homeEdit => 'সম্পাদনা কৰক';

  @override
  String get homeSubjectsNeedSyllabus =>
      'আপোনাৰ বিষয়সমূহ চাবলৈ আপোনাৰ শ্ৰেণী আৰু ব’ৰ্ড নিৰ্ধাৰণ কৰক';

  @override
  String get homeSubjectsLoading => 'আপোনাৰ বিষয়সমূহ ল’ড হৈ আছে…';

  @override
  String get homeSubjectsSoon => 'আপোনাৰ বিষয়সমূহ সোনকালে ইয়াত দেখুওৱা হ’ব।';

  @override
  String homeNextChapter(int number, String title) {
    return 'পৰৱৰ্তী: অধ্যায় $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'আটাইবোৰ পাঠ সম্পূৰ্ণ হ’ল';

  @override
  String get homeLessonsComingSoon => 'পাঠসমূহ সোনকালে আহি আছে';

  @override
  String homeTodayMinutes(int minutes) {
    return 'জিজ্ঞাসা · $minutes মিনিট';
  }

  @override
  String get homeTodayDone => 'আজি · আটাইবোৰ সম্পূৰ্ণ হ’ল';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা ফ’ল্ডাৰৰ পৰা',
      one: '১ টা ফ’ল্ডাৰৰ পৰা',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'আৰু আপোনাৰ ফ’ল্ডাৰত অধিক $count টা';
  }

  @override
  String get homeAskHintTitle => 'Pebby-ক যিকোনো কথা সোধক';

  @override
  String get homeAskHintBody =>
      'এটা প্ৰশ্ন টাইপ কৰক,বা ফটো তুলিবলৈ গৃহকৰ্য সমাধানত টিপক।';

  @override
  String get homeAskHintGotIt => 'বুজি পালোঁ';

  @override
  String get homeDashboardLoadError => 'আপুনি বৰ্তমান অফলাইনত আছে।';

  @override
  String get homeRetry => 'পুনৰ চেষ্টা কৰক';

  @override
  String get helloFallbackName => 'তাতে';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিনৰ ষ্ট্ৰীক',
      one: '১ দিনৰ ষ্ট্ৰীক',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'এটা ফ’ল্ডাৰলৈ টোকা';

  @override
  String get scanModeAsk => 'ফটো এটাৰ বিষয়ে সোধক';

  @override
  String get scanWhatsOnPaper => 'কাগজখনত কি আছে?';

  @override
  String get scanHintSolve => 'প্ৰথমতে ইংগিতসমূহ';

  @override
  String get scanHintCheck => 'ব’ৰ্ড-শৈলীৰ নম্বৰ';

  @override
  String get scanHintNotes => 'পাঠ এটুলৈ পৃষ্ঠাসমূহ';

  @override
  String get scanHintAsk => 'অন্য যিকোনো কথা';

  @override
  String get scanRecent => 'শেহতীয়া স্কেনসমূহ';

  @override
  String get scanStatusRead => 'পঢ়ক';

  @override
  String get scanStatusSolvedInAskMe => 'ASKMe-ত সমাধান কৰা হ’ল';

  @override
  String get scanStatusAskedInAskMe => 'ASKMe-ত সোধা হ’ল';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count নম্বৰ',
      one: '১ নম্বৰ',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'এতিয়ালৈকে নম্বৰ দিয়া হোৱা নাই';

  @override
  String get scanStatusLessonInFolder => 'ফ’ল্ডাৰত পাঠ';

  @override
  String get scanStatusNotesInFolder => 'ফ’ল্ডাৰত টোকা';

  @override
  String get scanStatusNotSaved => 'এতিয়ালৈকে ছেভ কৰা হোৱা নাই';

  @override
  String get scanSourceNotesBlurb =>
      '১০ টা পৃষ্ঠালৈকে। কেৱল পাঠখিনিহে ৰখা হয়, ফটোবোৰ নহয়।';

  @override
  String get scanSourceBlurb => 'কেৱল পাঠখিনিহে ৰখা হয়, ফটোখন নহয়।';

  @override
  String get scanTakePhoto => 'এটা ফটো লওক';

  @override
  String get scanChooseGallery => 'গেলৰীৰ পৰা বাছক';

  @override
  String get scanCamera => 'কেমেৰা';

  @override
  String get scanGallery => 'গেলৰী';

  @override
  String get scanYourPages => 'আপোনাৰ পৃষ্ঠাসমূহ';

  @override
  String scanPagesOf(int current, int max) {
    return '$max ৰ ভিতৰত $current';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পৃষ্ঠা পঢ়া হ’ল',
      one: '১ টা পৃষ্ঠা পঢ়া হ’ল',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'পৃষ্ঠা আতৰাওক';

  @override
  String get scanYourNotes => 'আপোনাৰ টোকাসমূহ';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pebby-য়ে $count টা পৃষ্ঠা পঢ়িলে',
      one: 'Pebby-য়ে ১ টা পৃষ্ঠা পঢ়িলে',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'এইবোৰ ক’লৈ যাব লাগে?';

  @override
  String get scanChooseFolder => 'এটা ফ’ল্ডাৰ বাছক';

  @override
  String get scanChange => 'সলনি কৰক';

  @override
  String get scanMakeFromNotes => 'আপোনাৰ টোকাসমূহৰ পৰা তৈয়াৰ কৰক';

  @override
  String get scanSwipeLesson => 'পাঠ স্বাইপ কৰক';

  @override
  String get scanSwipeLessonSubtitle =>
      'কাৰ্ড আৰু দ্ৰুত পৰীক্ষাসমূহ, পৰিকল্পনাত যোগ কৰা হ’ল';

  @override
  String get scanKeepNotes => 'কেৱল টোকাসমূহ ৰাখক';

  @override
  String get scanKeepNotesSubtitle => 'পাঠখিনি ফ’ল্ডাৰটোত সোমাই যাব';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পৃষ্ঠা পঢ়া হৈ আছে…',
      one: 'আপোনাৰ পৃষ্ঠা পঢ়া হৈ আছে…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'ইি কেইটামান ছেকেণ্ড লয়।';

  @override
  String get scanMakingLesson => 'আপোনাৰ পাঠ তৈয়াৰ কৰা হৈ আছে…';

  @override
  String get scanSavingNotes => 'আপোনাৰ টোকাসমূহ সংৰক্ষণ কৰা হৈ আছে…';

  @override
  String get scanSavingWait => 'ই আপোনাৰ ফ’ল্ডাৰত থাকিব।';

  @override
  String get scanFailUnavailableTitle => 'স্কেন এতিয়াও প্ৰস্তুত হোৱা নাই';

  @override
  String get scanFailUnavailableBody =>
      'Pebby-য়ে এতিয়া ফটো পঢ়িব নোৱাৰে। পিছত আকৌ চেষ্টা কৰক।';

  @override
  String get scanFailNoTextTitle => 'ইয়াত কোনো শব্দ নাই';

  @override
  String get scanFailNoTextBody =>
      'আপোনাৰ গৃহকৰ্ম, পাঠ্যপুথিৰ পৃষ্ঠা বা টোকাত কেমেৰাটো নিৰ্দেশ কৰক।';

  @override
  String get scanFailTooLargeTitle => 'বহুত বেছি ডাঙৰ ফটো';

  @override
  String get scanFailTooLargeBody => 'এবাৰত কম পৃষ্ঠাযুক্ত চেষ্টা কৰক।';

  @override
  String get scanFailNetworkTitle => 'আপুনি অফলাইনত আছে';

  @override
  String get scanFailNetworkBody =>
      'আপোনাৰ ইণ্টাৰনেট পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get scanFailScanLimitTitle => 'সেইটো হৈছে আজিৰ বিনামূলীয়া স্কেনসমূহ';

  @override
  String get scanFailScanLimitBody =>
      'সেইবোৰ মাজনিশা ঘূৰি আহিব। যিমান ইচ্ছা সিমান স্কেন কৰিবলৈ Pro লওক।';

  @override
  String get scanFailCheckLimitTitle => 'সেইটো হৈছে আজিৰ বিনামূলীয়া পৰীক্ষা';

  @override
  String get scanFailCheckLimitBody =>
      'ই মাজনিশা ঘূৰি আহিব। প্ৰতিটো উত্তৰ পৰীক্ষা কৰিবলৈ Go Pro ব্যৱহাৰ কৰক।';

  @override
  String get scanFailProOnlyTitle => 'ন\'টৰ পৰা লোৱা পাঠসমূহ Pro';

  @override
  String get scanFailProOnlyBody =>
      'আপোনাৰ ন\'টসমূহ বিনামূলীয়াকৈ ৰাখক, নতুবা Pro লৈ যাওক আৰু Pebby এ ইয়াক এটা পাঠে লৈ পৰিণত কৰিব।';

  @override
  String get scanFailUnknownTitle => 'Pebby এটো পঢ়িব নোৱাৰিলে';

  @override
  String get scanFailUnknownBody =>
      'পুনৰ চেষ্টা কৰক, বা উন্নত পোহৰত ফটোখন আকৌ তুলক।';

  @override
  String get scanBackToAnswer => 'আপোনাৰ উত্তৰলৈ ঘূৰি যাওক';

  @override
  String get scanRetake => 'পুনৰ তুলক';

  @override
  String get scanCameraOpenFailed =>
      'কেমেৰাটো খুলিব পৰা নগ\'ল। গেলেৰীটো চেষ্টা কৰক।';

  @override
  String get scanPebbyReadThis => 'Pebby এ এইটো পঢ়িলে';

  @override
  String get scanFixAnything => 'যিকোনো ভুল থাকিলে ঠিক কৰক।';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · যিকোনো ভুল থাকিলে ঠিক কৰক।';
  }

  @override
  String get scanFromYourPhoto => 'আপোনাৰ ফটোখনৰ পৰা';

  @override
  String get scanFromMyPhoto => 'মোৰ ফটোখনৰ পৰা:';

  @override
  String get scanWhatDoYouWant => 'আপুনি কি জানিব বিচাৰে?';

  @override
  String get scanSuggestExplain => 'এইটো সহজভাৱে বুজাই দিয়ক';

  @override
  String get scanSuggestSummarise => 'এইটো সাৰাংশ কৰক';

  @override
  String get scanSuggestKeyTerms => 'মুখ্য শব্দবোৰ কি কি?';

  @override
  String get scanSolveThis => 'এইটো সমাধান কৰক';

  @override
  String get scanAskPebby => 'Pebby ক সোধক';

  @override
  String get scanHintFirst =>
      'Pebby এ প্ৰথমে এটা ইঙ্গিত দিয়ে, তাৰ পিছত পদক্ষেপসমূহ দিয়ে।';

  @override
  String get checkPebbyReadAnswer => 'Pebby এ আপোনাৰ উত্তৰ পঢ়িলে';

  @override
  String get checkTheQuestion => 'প্ৰশ্নটো';

  @override
  String get checkQuestionHint => 'কেৱল যদি ই ফটোখনত নাথাকে';

  @override
  String get checkMarkIt => 'চিহ্নিত কৰক';

  @override
  String get checkMarkingAnswer => 'আপোনাৰ উত্তৰ চিহ্নিত কৰা হৈছে…';

  @override
  String get checkMarkingScheme => 'ব’ৰ্ডৰ নম্বৰ দিয়া পদ্ধতি ব্যৱহাৰ কৰি।';

  @override
  String get checkFullMarks => 'সম্পূৰ্ণ নম্বৰ!';

  @override
  String get checkNearlyThere => 'প্ৰায় হৈ গ\'ল';

  @override
  String get checkKeepGoing => 'আগবাঢ়ি যাওক';

  @override
  String get checkReportTitle => 'এই নম্বৰসমূহ ৰিপ\'ৰ্ট কৰক';

  @override
  String get checkReportThanks => 'ধন্যবাদ। আমি এই নম্বৰসমূহ পৰ্যালোচনা কৰিম।';

  @override
  String get checkWhatGotMarks => 'কিমান নম্বৰ পালে';

  @override
  String get checkWellDone => 'ভাল কাম কৰিলে';

  @override
  String get checkForFullMarks => 'সম্পূৰ্ণ নম্বৰৰ বাবে';

  @override
  String get checkAgain => 'পুনৰ পৰীক্ষা কৰক';

  @override
  String get checkShowModelAnswer => 'আদৰ্শ উত্তৰ দেখুৱক';

  @override
  String get checkHideModelAnswer => 'আদৰ্শ উত্তৰ লুকুৱক';

  @override
  String checkAskQuestion(String question) {
    return 'প্ৰশ্ন: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'মোৰ উত্তৰ:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'মই $awarded/$marks পালোঁ। মই কেনেকৈ সম্পূৰ্ণ নম্বৰ পাব পাৰোঁ?';
  }

  @override
  String get meLearningSection => 'শিকণ';

  @override
  String get meMyProgress => 'মোৰ প্ৰগতি';

  @override
  String get meClassAndBoard => 'শ্ৰণী আৰু ব’ৰ্ড';

  @override
  String get meAppearance => 'চেহেৰা';

  @override
  String get meNotificationsSection => 'নটিফিকেচন';

  @override
  String get meRemindersAndDailyGoal => 'ৰিমেইণ্ডাৰ আৰু দৈনিক লক্ষ্য';

  @override
  String get meAccountSection => 'একাউণ্ট';

  @override
  String get meAccount => 'একাউণ্ট';

  @override
  String get meHelpAndFeedback => 'সহায় আৰু মতামত';

  @override
  String get mePrivacyAndTerms => 'গোপনীয়তা আৰু চৰ্তাৱলী';

  @override
  String get meLogOut => 'লগ আউট';

  @override
  String get meLoggingOut => 'লগ আউট হৈ আছে…';

  @override
  String get meStudentFallback => 'ছাত্ৰ-ছাত্ৰী';

  @override
  String get meDayStreak => 'দিনৰ ষ্ট্ৰীক';

  @override
  String meLevelValue(int number) {
    return 'লেভেল $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return 'লেভেল $level হ’বলৈ $xp XP বাকী';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'ঠিক আছে';

  @override
  String meOkSwitchTo(String name) {
    return 'ঠিক আছে · $name লৈ সলনি কৰক';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting Pebby এ এতিয়া $name ত উত্তৰ দিব।';
  }

  @override
  String get meLanguageSwitchFailed =>
      'ভাষা সলনি কৰিব পৰা নগ’ল। পুনৰ চেষ্টা কৰক।';

  @override
  String meOpenInBrowser(String url) {
    return 'আপোনাৰ ব্ৰাউজাৰত $url খোলক';
  }

  @override
  String get meNotSet => 'নিৰ্ধাৰণ কৰা হোৱা নাই';

  @override
  String get meOff => 'বন্ধ';

  @override
  String meClassOnly(int level) {
    return 'শ্ৰেণী $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'শ্ৰেণী $level · $board';
  }

  @override
  String get meLogOutTitle => 'লগ আউট কৰিবনে?';

  @override
  String get meLogOutBody =>
      'আপোনাৰ প্ৰগতি আপোনাৰ একাউণ্টত সংৰক্ষিত কৰা হৈছে। যিকোনো সময়তে আকৌ লগ ইন কৰক।';

  @override
  String get meLogOutStay => 'থাকক';

  @override
  String get accountSaveName => 'নাম ছেভ কৰক';

  @override
  String get accountNameSaved => 'নাম ছেভ কৰা হ\'ল';

  @override
  String get accountDangerZone => 'বিপদজনক অঞ্চল';

  @override
  String get accountDeleteMyAccount => 'মোৰ একাউণ্ট ডিলিট কৰক';

  @override
  String get accountDeleteGraceNote =>
      'অনুরোধ কৰাৰ ৩০ দিনৰ পিছত আপোনাৰ একাউণ্ট ডিলিট কৰা হ\'ব। ইয়াক ৰাখিবলৈ তাৰ আগতে লগ ইন কৰক।';

  @override
  String get accountSignIn => 'লগ-ইন';

  @override
  String get accountChangePassword => 'পাছৱৰ্ড সলনি কৰক';

  @override
  String get accountSetPassword => 'এটা পাছৱৰ্ড ছেট কৰক';

  @override
  String get accountLinkGoogle => 'Google লিংক কৰক';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'লিংক কৰা হৈ আছে…';

  @override
  String get accountUnlinking => 'আনলিংক কৰা হৈ আছে…';

  @override
  String get accountNotLinked => 'লিংক কৰা হোৱা নাই';

  @override
  String get accountGoogleLinked =>
      'Google লিংক কৰা হ’ল। আপুনি এতিয়া ইয়াৰ জৰিয়তে লগ ইন কৰিব পাৰিব।';

  @override
  String get accountGoogleUnlinked =>
      'Google আনলিংক কৰা হ’ল। আপোনাৰ ইমেইল আৰু পাছৱৰ্ডেৰে লগ ইন কৰক।';

  @override
  String get accountUnlinkGoogleTitle => 'Google আনলিংক কৰিবনে?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'আপুনি আৰু $email ব্যৱহাৰ কৰি লগ ইন কৰিব নোৱাৰিব। ইয়াৰ সলনি আপোনাৰ ইমেইল আৰু পাছৱৰ্ড ব্যৱহাৰ কৰক।';
  }

  @override
  String get accountKeepGoogle => 'Google ৰাখক';

  @override
  String get accountUnlink => 'আনলিংক কৰক';

  @override
  String get passwordSave => 'পাছৱৰ্ড ছেভ কৰক';

  @override
  String get passwordChangeBody =>
      'আপুনি ছাইন আপ কৰোঁতে ব্যৱহাৰ কৰা নিয়মবোৰেই পালন কৰক। ছেভ কৰাৰ পিছত অন্যান্য ডিভাইচৰ লগ-আউট হৈ যাব।';

  @override
  String get passwordSetBody =>
      'এটা পাছৱৰ্ড যোগ কৰক যাতে আপুনি কেৱল Google-য়েই নহয়, আপোনাৰ ইমেইলেৰেও লগ ইন কৰিব পাৰে।';

  @override
  String get passwordCurrent => 'বৰ্তমানৰ পাছৱৰ্ড';

  @override
  String get passwordChangedSnack =>
      'পাছৱৰ্ড সলনি কৰা হ’ল। অন্যান্য ডিভাইচসমূহৰ লগ-আউট হৈ গৈছে।';

  @override
  String get passwordSetSnack =>
      'পাছৱৰ্ড ছেট কৰা হ’ল। আপুনি এতিয়া আপোনাৰ ইমেইলেৰেও লগ ইন কৰিব পাৰিব।';

  @override
  String get deleteAccountTitle => 'একাউণ্ট ডিলিট কৰক';

  @override
  String get deleteDeleting => 'ডিলিট কৰা হৈ আছে…';

  @override
  String get deleteSorryTitle => 'আপুনি গুচি যোৱাত আমি দুঃখিত';

  @override
  String get deleteBody =>
      'আপোনাৰ একাউণ্ট ৩০ দিনৰ ভিতৰত ডিলিট কৰা হ’ব। ইয়াক ৰাখিবলৈ তাৰ আগতে আকৌ লগ ইন কৰক। ৩০ দিনৰ পিছত আপোনাৰ প্ৰফাইল, চাট, প্ৰগ্ৰেছ আৰু XP চিৰদিনৰ বাবে মচি পেলোৱা হ’ব আৰু ঘূৰাই আনিব নোৱাৰি।';

  @override
  String get deleteSubscription => 'চাবস্ক্ৰিপশ্বন';

  @override
  String get deleteSubscriptionNotice =>
      'Google Play ত কিনোৱা ACADEMe Pro চাবস্ক্ৰিপশ্বন আপোনাৰ একাউণ্ট ডিলিট কৰিলে কেনচেল নহয়। আপোনাক যাতে আকৌ চাৰ্জ কৰা নহয়, তাৰ বাবে Google Play ত ইয়াক কেনচেল কৰক।';

  @override
  String get deleteManageSubscription => 'চাবস্ক্ৰিপশ্বন পৰিচালনা কৰক';

  @override
  String get deleteWhyLeaving => 'আপুনি কিয় এৰি গৈছে? (ঐচ্ছিক)';

  @override
  String deleteConfirmLabel(String word) {
    return 'নিশ্চিত কৰিবলৈ $word টাইপ কৰক';
  }

  @override
  String get deleteReasonNotEnough => 'মই ইয়াক পৰ্যাপ্তভাৱে ব্যৱহাৰ নকৰোঁ';

  @override
  String get deleteReasonDidntHelp => 'ই মোৰ পঢ়া-শুনাত সহায় কৰা নাই';

  @override
  String get deleteReasonTooManyNotifs => 'অত্যন্ত বেছি জাননী';

  @override
  String get deleteReasonDataWorry => 'মই মোৰ ডেটাক লৈ চিন্তিত';

  @override
  String get deleteReasonOther => 'অন্য কিছু';

  @override
  String deleteScheduledSnack(String date) {
    return '$date তাৰিখে আপোনাৰ একাউণ্ট মচি পেলোৱা হ’ব। ইয়াক সক্ৰিয় কৰি ৰাখিবলৈ তাৰ আগতে লগ ইন কৰক।';
  }

  @override
  String get notifRemindersAndGoalTitle => 'স্মাৰক আৰু লক্ষ্য';

  @override
  String get notifStudyReminder => 'পঢ়াৰ স্মাৰক';

  @override
  String get notifRemindMeToStudy => 'মোক পঢ়িবলৈ সোঁৱৰাই দিয়ক';

  @override
  String get notifTime => 'সময়';

  @override
  String get notifRemindMeAt => 'মোক সোঁৱৰাই দিয়ক যেতিয়া';

  @override
  String get notifAlsoTellMe => 'মোক এইটোও কওক';

  @override
  String get notifStreakAboutToEnd => 'যেতিয়া মোৰ ষ্ট্ৰীক শেষ হ’বলৈ ধৰিছে';

  @override
  String get notifEveningBeforeTest => 'পৰীক্ষাৰ আগৰ সন্ধিয়া';

  @override
  String get notifWhenLevelUp => 'যেতিয়া মই লেভেল আপ কৰোঁ';

  @override
  String get notifNotifications => 'জাননীসমূহ';

  @override
  String get notifAllowed => 'অনুমতি দিয়া হৈছে';

  @override
  String get notifNotAllowed => 'অনুমতি দিয়া হোৱা নাই';

  @override
  String get notifTurnOn => 'জাননীসমূহ অন কৰক';

  @override
  String get notifTurnOnInSettings => 'ছেটিংছত অন কৰক';

  @override
  String get reminderTimeTitle => 'সোঁৱৰণিৰ সময়';

  @override
  String get reminderHour => 'ঘণ্টা';

  @override
  String get reminderMinute => 'মিনিট';

  @override
  String get reminderAmPm => 'পুৱা বা সন্ধিয়া';

  @override
  String get reminderAm => 'ৰাতিপুৱা';

  @override
  String get reminderPm => 'আবেলি';

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
    return 'ঘৰৰ আজিৰ পদক্ষেপসমূহ প্ৰায় $_temp0 যোগ হ\'ব।';
  }

  @override
  String get dailyGoalSemantics => 'মিনিটত দৈনিক লক্ষ্য';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get dailyGoalStudyEachDay => 'প্ৰতিদিনে পঢ়ক';

  @override
  String get appearanceTheme => 'থিম';

  @override
  String get appearanceLight => 'পাতল';

  @override
  String get appearanceDark => 'আন্ধাৰ';

  @override
  String get appearanceDarkHint =>
      'আন্ধাৰ ম’ডে নিশা আপোনাৰ চকুৰ বাবে আৰামদায়ক।';

  @override
  String get appearanceLightsOff => 'বতি নিৰ্বাপিত হ’ল…';

  @override
  String get appearanceGoodMorning => 'সুপ্রভাত!';

  @override
  String get appearanceDimming => 'Pebby-য়ে কোঠাটোৰ পোহৰ কমাই দিছে';

  @override
  String get appearanceOpeningCurtains => 'Pebby-য়ে পৰ্দাখন খুলি আছে';

  @override
  String get helpTellUs => 'আমাক কওক';

  @override
  String get helpEmailUs => 'আমাক ইমেইল কৰক';

  @override
  String get helpThanks => 'ধন্যবাদ, আমি আপোনাৰ বাৰ্তা পাইছো।';

  @override
  String get feedbackWrongAnswer => 'এটা ভুল উত্তৰ ৰিপ\'ৰ্ট কৰক';

  @override
  String get feedbackBug => 'কিবা এটা কাম কৰা নাই';

  @override
  String get feedbackFeature => 'এটা ফিচাৰ পৰামৰ্শ দিয়ক';

  @override
  String get feedbackHint => 'কি হ’ল আমাক কওক (কমপক্ষে ১০ টা আখৰ)।';

  @override
  String get feedbackSend => 'প্ৰেৰণ কৰক';

  @override
  String get feedbackLimitNote =>
      'আপুনি দিনে সৰ্বোচ্চ ২ টা আৰু সপ্তাহত ৫ টা বাৰ্তা পঠিয়াব পাৰে।';

  @override
  String get feedbackFailGeneric => 'পঠিওৱা নহ\'ল। আকৌ চেষ্টা কৰক।';

  @override
  String get feedbackFailDay =>
      'আপুনি আজি গ্ৰহণ কৰিব পৰା সৰ্বোচ্চ ফিডবেক পঠিয়াইছে। কাইলৈ আকৌ চেষ্টা কৰক।';

  @override
  String get feedbackFailWeek =>
      'আপুনি এই সপ্তাহত গ্ৰহণ কৰিব পৰা সৰ্বোচ্চ ফিডবেক পঠিয়াইছে। অহা সপ্তাহত আকৌ চেষ্টা কৰক।';

  @override
  String get feedbackFailTooShort =>
      'আমি সহায় কৰিব পৰা কৈ কমপক্ষে ১০ টা আখৰ লিখক।';

  @override
  String get feedbackFailOffline =>
      'আপুনি অফলাইনত আছে। আপোনাৰ সংযোগ পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get privacySummary1 =>
      'আপোনাৰ বাবে ACADEMe চলাবলენ আমি আপোনাৰ একাউণ্ট, ক্লাচ, ব\'ৰ্ড আৰু বিষয়সমূহ, পঢ়া-শুনাৰ অগ্ৰগতি আৰু ষ্ট্ৰীক, ফোল্ডাৰ, টোকা আৰু Pebby-ৰ সৈতে হোৱা চাট সংৰক্ষণ কৰোঁ।';

  @override
  String get privacySummary2 =>
      'Pebby-য়ে উত্তৰ দিব পৰা কৈ আপোনাৰ প্ৰশ্ন আৰু স্কেন কৰা ফটোসমূহ ভাৰতৰ Sarvam AI লৈ যায়। আমি আপোনাৰ ফটোসমূহ সংৰক্ষণ নকৰোঁ, কেৱল তাৰ পৰা পঢ়া টেক্সটহে সংৰক্ষণ কৰোঁ।';

  @override
  String get privacySummary3 =>
      'কোনো বিজ্ঞাপন নাই, কোনো বিজ্ঞাপন আইডি নাই, কোনো অৱস্থান নাই, আৰু আমি কেতিয়াও আপোনাৰ তথ্য বিক্ৰী নকৰোঁ।';

  @override
  String get privacySummary4 =>
      'একাউণ্টত গৈ যিকোনো সময়তে আপোনাৰ একাউণ্ট ডিলিট কৰক। ৩০ দিনৰ পিছত সকলো মচি পেলোৱা হয়।';

  @override
  String get privacyDocuments => 'নথি পত্ৰসমূহ';

  @override
  String get privacyPolicy => 'গোপনীয়তা নীতি';

  @override
  String get privacyTermsOfUse => 'ব্যৱহাৰৰ চৰ্তাৱলী';

  @override
  String get privacyYourData => 'আপোনাৰ তথ্য';

  @override
  String get privacyGetCopy => 'মোৰ তথ্যৰ এটা কপি লওক';

  @override
  String get privacyGrievanceOfficer => 'অভিযোগ নিবারণ বিষয়া';

  @override
  String classBoardSave(int level, String board) {
    return 'সংৰক্ষণ কৰক · ক্লাচ $level · $board';
  }

  @override
  String get classBoardYourClass => 'আপোনাৰ ক্লাচ';

  @override
  String get classBoardYourBoard => 'আপোনাৰ ব\'ৰ্ড';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'আপোনাৰ বিষয় আৰু পৰিকল্পনা ক্লাচ $level · $board লৈ সলনি হ\'ব। ইমানদিন আপুনি কৰা সকলো কাম সংৰক্ষিত হৈ থাকিব।';
  }

  @override
  String get classBoardSubjects => 'বিষয়সমূহ';

  @override
  String get classBoardStream => 'স্ৰীম';

  @override
  String get classBoardAllSubjects => 'সকলো বিষয়';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'এতিয়া শ্ৰেণী $level · $board ৰ বিষয়সমূহ দেখুওৱা হৈছে';
  }

  @override
  String get reminderPrimerTitle => 'পৰীক্ষাৰ আগতে এটা জাননী বাৰ্তা পাওক';

  @override
  String get reminderPrimerPromise1 =>
      'প্ৰতিটো পৰীক্ষাৰ ৩ দিন আগতে, আগবেলা আৰু পৰীক্ষাৰ দিনাৰ পুৱা এটা আগতীয়া খবৰ';

  @override
  String get reminderPrimerPromise2 =>
      'আপোনাৰ পঢ়া-শুনাৰ সোঁৱৰণি, কেৱল আপুনি বাছি লোৱা দিন আৰু সময়ত';

  @override
  String get reminderPrimerPromise3 =>
      'আৰু একো নহয়। \'Me\' ত ইয়াক যিকোনো সময়তে সলনি কৰক';

  @override
  String get reminderPrimerAllow => 'অনুমতি দিয়ক';

  @override
  String get paywallWelcomeSnack => 'ACADEMe Pro লৈ স্বাগতম';

  @override
  String get paywallTagline =>
      '৩× দৈনিক আৰু সাপ্তাহিক সীমা। একে ৰিফিল ঘড়ী — পঢ়িবলৈ অধিক সুবিধা।';

  @override
  String get paywallOpeningPlay => 'Google Play খোল হৈছে…';

  @override
  String get paywallRestoring => 'পুনৰুদ্ধাৰ কৰা হৈছে…';

  @override
  String get paywallRestore => 'ক্ৰয়সমূহ পুনৰুদ্ধাৰ কৰক';

  @override
  String get paywallUnavailableTitle => 'এই ডিভাইচত ক্ৰয়সমূহ উপলব্ধ নহয়';

  @override
  String get paywallUnavailableBody =>
      'Pro হ’বলৈ Google Play ৰ পৰা ACADEMe ইনষ্টল কৰক আৰু Play ত ছাইন ইন কৰক।';

  @override
  String get paywallBenefitAskme => 'প্ৰতিদিন ৩× ASKMe প্ৰশ্ন';

  @override
  String get paywallBenefitScan => 'প্ৰতিদিন ৩× স্কেন';

  @override
  String get paywallBenefitCheck => 'প্ৰতিদিন ৩× উত্তৰ পৰীক্ষা';

  @override
  String get paywallBenefitLessons =>
      'আপোনাৰ টোকাৰ পৰা তৈয়াৰ কৰা চুইপ পাঠসমূহ';

  @override
  String get paywallBenefitProgress =>
      'মোৰ অগ্ৰগতি সাপ্তাহিক পঢ়া-শুনাৰ সাৰাংশ';

  @override
  String get paywallMonthly => 'মাহত';

  @override
  String get paywallAnnual => 'বাৰ্ষিক';

  @override
  String paywallPlanSemantics(String title) {
    return '$title পৰিকল্পনা';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return 'প্ৰথম মাহৰ বাবে $introPrice, তাৰ পিছত $price/মাহ';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/মাহ';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/বছৰ';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'প্ৰতি $monthlyPrice/মাহ মান · ১৭% ৰাহি কৰক · আপোনা-আপুনি নৱীকৰণ হয়';
  }

  @override
  String get paywallDetailAnnual => '১৭% ৰাহি কৰক · আপোনা-আপুনি নৱীকৰণ হয়';

  @override
  String get paywallDetailRenews => 'আপোনা-আপুনি নৱীকৰণ হয়';

  @override
  String get paywallBestValue => 'শ্ৰেষ্ঠ মূল্য';

  @override
  String get paywallSmallPrint =>
      'আপোনা-আপুনি নৱীকৰণ হয়। Google Play ত যিকোনো সময়তে বাতিল কৰক।';

  @override
  String get paywallTerms => 'চৰ্তাৱলী';

  @override
  String get paywallPrivacy => 'গোপনীয়তা';

  @override
  String get upgradeTitle => 'Go Pro · ৩× সীমা';

  @override
  String get limitAskmeTitle => 'সেয়া হৈছে আজিৰ বিনামূলীয়া প্ৰশ্নসমূহ';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা ASKMe প্ৰশ্ন',
      one: '1 টা ASKMe প্ৰশ্ন',
    );
    return 'বিনামূলীয়াত অন্তৰ্ভুক্ত আছে প্ৰতিদিন $_temp0। Pro য়ে প্ৰতিদিন ৩× দিয়ে।';
  }

  @override
  String get limitScanTitle => 'সেয়া হৈছে আজিৰ বিনামূলীয়া স্কেনসমূহ';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা স্কেন',
      one: '১ টা স্কেন',
    );
    return 'বিনামূলীয়াত প্রতিদিনে $_temp0 আছে। Pro-ত প্ৰতিদিনে ৩ গুণ পোৱা যায়।';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এইকেইটা হৈছে আজিৰ বিনামূলীয়া পৰীক্ষাসমূহ',
      one: 'এইটো হৈছে আজিৰ বিনামূলীয়া পৰীক্ষা',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা উত্তৰ পৰীক্ষা',
      one: 'এটা উত্তৰ পৰীক্ষা',
    );
    return 'বিনামূলীয়াত প্রতিদিনে $_temp0 আছে। Pro-ত প্ৰতিদিনে ৩ গুণ পোৱা যায়।';
  }

  @override
  String get limitLessonsTitle => 'ন\'টৰ পৰা পাঠসমূহ Pro হয়';

  @override
  String get limitLessonsBody =>
      'আপোনাৰ ন\'টসমূহ সুৰক্ষিত ৰখা বিনামূলীয়া। Pro-ৰ সৈতে, Pebby-য়ে কুৱিজৰ সৈতে সেইবোৰক স্বাইপ পাঠলৈ ৰূপান্তৰিত কৰে।';

  @override
  String get limitMaybeLater => 'হয়তো পিছত';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'প্নান আৰু সীমা';

  @override
  String get proCardSubtitleFree => 'প্নান আৰু সীমা · Pro-ৰ সৈতে ৩×';

  @override
  String get proCardSubtitleMonthly => 'Pro · মাহেকীয়া';

  @override
  String get proCardSubtitleAnnual => 'Pro · বাৰ্ষিক';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'মেনেজ কৰক';

  @override
  String get proOnPro => 'আপুনি Pro-ত আছে';

  @override
  String get proOnFree => 'আপুনি Free-ত আছে';

  @override
  String get proMetaFree => 'দৈনিক আৰু সাপ্তাহিক সীমা · পুৱা ১২:০০ বজা IST';

  @override
  String get proMetaBillingIssue =>
      'Pro বৰ্তাই ৰখախ Google Play-ত পৰিশোধ ঠিক কৰক';

  @override
  String get proMetaActiveNoExpiry => '৩× দৈনিক সীমা · সাপ্তাহিক সুৰক্ষা কেপ';

  @override
  String proMetaAnnualRenews(String date) {
    return 'বাৰ্ষিক · নৱীকৰণ হয় $date · ৩× সীমা';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'মাহেকীয়া · নৱীকৰণ হয় $date · ৩× সীমা';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro শেষ হ’ব $date তাৰিখে';
  }

  @override
  String get proStatusActive => 'সক্ৰিয়';

  @override
  String get proStatusFree => 'বিনামূল্যে';

  @override
  String get proDailyLimits => 'দৈনিক সীমা';

  @override
  String get proResetsDaily => 'প্ৰতিদিনে ৰাতি ১২:০০ বজা IST-ত ৰিছেট হয়';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'স্কেন';

  @override
  String get proFeatureCheck => 'পৰীক্ষা কৰক';

  @override
  String get proFeatureLessons => 'পাঠসমূহ';

  @override
  String get proWeeklyLimit => 'সাপ্তাহিক সীমা';

  @override
  String get proResetsMondays => 'সোমবাৰে ৰিছেট হয় · ৰাতি ১২:০০ বজা IST';

  @override
  String proResetsOnDay(String day) {
    return 'ৰিছেট হয় $day · ৰাতি ১২:০০ বজা IST';
  }

  @override
  String get proAllFeatures => 'সকলো ফিচাৰ';

  @override
  String get proManageInPlay => 'Google Play-ত পৰিচালনা কৰক';

  @override
  String get proResetsSoon => 'শীঘ্ৰেই আহি আছে';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ঘণ্টাৰ ভিতৰত',
      one: '১ ঘণ্টাৰ ভিতৰত',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'আপোনাৰ পেমেণ্ট বাকী আছে। Google Play-য়ে নিশ্চিত কৰাৰ লগে লগে Pro সক্ৰিয় হৈ যাব।';

  @override
  String get proNoticeNoPurchase =>
      'এই Google একাউণ্টত কোনো ACADEMe Pro ক্ৰয় পোৱা নগ’ল।';

  @override
  String get proNoticeNotAllowed =>
      'এই Google একাউণ্টৰ বাবে ক্ৰয় কৰা কাৰ্য بند কৰা হৈছে।';

  @override
  String get proNoticeAlreadyOwned =>
      'এই Google একাউণ্টত ইতিমধ্যে Pro আছে। \"Restore purchases\" ত টিপক।';

  @override
  String get proNoticeUnavailable => 'এই ডিভাইচত ক্ৰয় কৰিব নোৱাৰি।';

  @override
  String get proNoticeStoreError =>
      'Google Play-য়ে সেয়া সম্পূৰ্ণ কৰিব নোৱাৰিলে। আকৌ চেষ্টা কৰক।';

  @override
  String get askmeNewChat => 'নতুন চাট';

  @override
  String askmeStudying(String name) {
    return 'আজি আমি কি পঢ়িম, $name?';
  }

  @override
  String get askmeModeExplainLine =>
      'Pebby-য়ে ইয়াক সহজভাৱে, একে একে স্তৰত বুজাই দিয়ে।';

  @override
  String get askmeModeSolveLine =>
      'Pebby-য়ে ইংগিত দিয়ে। আপুনি নিজে সমাধান কৰক।';

  @override
  String get askmeModeQuizLine =>
      'Pebby-য়ে সুধিব, আপুনি উত্তৰ দিব, আৰু XP অৰ্জন কৰিব।';

  @override
  String get askmeSuggestExplain1 => 'পোহৰৰ প্ৰতিফলন সহজভাৱে বুজাই দিয়ক';

  @override
  String get askmeSuggestExplain2 => 'আকাশখন কিয় নীলা?';

  @override
  String get askmeSuggestExplain3 => 'সালোক সংশ্লেষণ (Photosynthesis) কি?';

  @override
  String get askmeSuggestSolve1 =>
      '2x + 3y = 11 আৰু x − 2y = −12 সমাধান কৰাত মোক সহায় কৰক';

  @override
  String get askmeSuggestSolve2 => 'r = 7 cm থকা এটা বৃত্তৰ কালি নিৰ্ণয় কৰক';

  @override
  String get askmeSuggestSolve3 => 'H₂ + O₂ → H₂O সমীকৰণটো সমতা কৰক (Balance)';

  @override
  String get askmeSuggestQuiz1 => 'পোহৰৰ ওপৰত মোক এটা কুইজ সোধক';

  @override
  String get askmeSuggestQuiz2 => 'ৰৈখিক সমীকৰণৰ ওপৰত মোক ৫ টা প্ৰশ্ন দিয়ক';

  @override
  String get askmeSuggestQuiz3 => 'ফ্ৰান্স বিপ্লৱৰ ওপৰত মোক কুইজ সোধক';

  @override
  String get askmeModeExplain => 'বুজাই দিয়ক';

  @override
  String get askmeModeSolve => 'সমাধান কৰক';

  @override
  String get askmeModeQuiz => 'মোক কুইজ সোধক';

  @override
  String get askmeFollowNextStep => 'পৰৱৰ্তী স্তৰ';

  @override
  String get askmeFollowFullSolution => 'সম্পূৰ্ণ সমাধান';

  @override
  String get askmeFollowNextQuestion => 'পৰৱৰ্তী প্ৰশ্ন';

  @override
  String get askmeFollowQuizMe => 'মোক কুইজ সোধক';

  @override
  String get askmeFollowGoDeeper => 'আৰু গভীৰভাৱে জানক';

  @override
  String get askmeSendNextStep => 'পৰৱৰ্তী স্তৰ, অনুগ্ৰহ কৰি।';

  @override
  String get askmeSendFullSolution => 'মোক সম্পূৰ্ণ সমাধানটো দেখুৱাওক।';

  @override
  String get askmeSendNextQuestion => 'পৰৱৰ্তী প্ৰশ্ন।';

  @override
  String get askmeSendGoDeeper => 'আৰু গভীৰলৈ যাওক।';

  @override
  String get askmeSendQuizMe => 'এইটোৰ ওপৰত মোক কুইজ সোধক।';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe এতিয়াও প্ৰস্তুত হোৱা নাই। Pebby সোনকালে আহিব।';

  @override
  String get askmeFailureSignedOut => 'আপোনাক লগ আউট কৰা হৈছে। পুনৰ লগ ইন কৰক।';

  @override
  String get askmeFailureLimitReached =>
      'আজিৰ বাবে আপোনাৰ বিনামূলীয়া প্ৰশ্নসমূহ শেষ হ’ল। এইবোৰ মাজনিশা পুনر আহিব।';

  @override
  String get askmeThinking => 'Pebby এ চিন্তা কৰি আছে';

  @override
  String get historyTitle => 'ইতিহাস';

  @override
  String get historySearchHint => 'আপোনাৰ প্ৰশ্নসমূহ বিচাৰক';

  @override
  String get historyLoadError =>
      'আপোনাৰ চাটসমূহ লোড কৰিব পৰা নগ’ল। পুনر চেষ্টা কৰক';

  @override
  String get historyEmpty =>
      'Pebby লৈ কৰা আপোনাৰ প্ৰশ্নসমূহ এখানে দেখুওৱা হ’ব।';

  @override
  String get historyThisWeek => 'এই সপ্তাহত';

  @override
  String get historyEarlier => 'পূৰ্বৰ';

  @override
  String get historyNow => 'এতিয়া';

  @override
  String historyHoursAgo(int hours) {
    return '$hoursঘণ্টা';
  }

  @override
  String get historyWeekdayMon => 'সোম';

  @override
  String get historyWeekdayTue => 'মঙ্গল';

  @override
  String get historyWeekdayWed => 'বুধ';

  @override
  String get historyWeekdayThu => 'বৃহস্পতি';

  @override
  String get historyWeekdayFri => 'শুক্র';

  @override
  String get historyWeekdaySat => 'শনি';

  @override
  String get historyWeekdaySun => 'ৰবি';

  @override
  String get historyMonthJan => 'জানুৱাৰী';

  @override
  String get historyMonthFeb => 'ফেব্ৰুৱাৰী';

  @override
  String get historyMonthMar => 'মাৰ্চ';

  @override
  String get historyMonthApr => 'এপ্ৰিল';

  @override
  String get historyMonthMay => 'মে’';

  @override
  String get historyMonthJun => 'জুন';

  @override
  String get historyMonthJul => 'জুলাই';

  @override
  String get historyMonthAug => 'আগষ্ট';

  @override
  String get historyMonthSep => 'ছেপ্টেম্বৰ';

  @override
  String get historyMonthOct => 'অক্টোবৰ';

  @override
  String get historyMonthNov => 'নৱেম্বৰ';

  @override
  String get historyMonthDec => 'ডিচেম্বৰ';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'আপোনাৰ প্ৰশ্নত যোগ কৰক';

  @override
  String get attachCamera => 'কেমেৰা';

  @override
  String get attachPhotos => 'ফ’টোগুলি';

  @override
  String get replyHelpful => 'সহায়ক';

  @override
  String get replyNotHelpful => 'সহায়ক নহ’ল';

  @override
  String get replyCopy => 'ক’পী কৰক';

  @override
  String get replyCopied => 'ক’পী কৰা হ’ল';

  @override
  String get replyReportTitle => 'এই উত্তৰটো প্রতিবেদন কৰক';

  @override
  String get replyReportThanks => 'ধন্যবাদ। আমি এই উত্তৰটো পৰ্যালোচনা কৰিম।';

  @override
  String get reportTooltip => 'প্রতিবেদন';

  @override
  String get reportSendFailed => 'প্রতিবেদন পঠিয়াব নোৱাৰিলে। আকৌ চেষ্টা কৰক।';

  @override
  String get reportBody =>
      'আমি প্ৰতিটো প্রতিবেদন পঢ়োঁ আৰু Pebby অধিক সুৰক্ষিত কৰিবলৈ ইয়াক ব্যৱহাৰ কৰোঁ।';

  @override
  String get reportReasonWrong => 'ই ভুল';

  @override
  String get reportReasonHarmful => 'ই ক্ষতিকারক বা অসুৰক্ষিত';

  @override
  String get reportReasonOffensive => 'ই অশিষ্ট বা আক্ৰমণাত্মক';

  @override
  String get reportReasonOther => 'অন্য কিবা';

  @override
  String get progressTitle => 'মোৰ অগ্ৰগতি';

  @override
  String get progressLoading => 'এই সপ্তাহটো ল’ড হৈ আছে…';

  @override
  String get progressLoadError => 'এই সপ্তাহৰ সাৰাংশ ল’ড কৰিব নোৱাৰিলে।';

  @override
  String get progressHoldTitle => 'মোৰ অগ্ৰগতি Pro ৰ এটা অংশ';

  @override
  String get progressHoldBody =>
      'ACADEMe Pro ৰ সৈতে ষ্ট্ৰীক, স্তৰ আৰু পঢ়াৰ অন্তৰ্দৃষ্টি চাওক।';

  @override
  String get progressGoProLimits => 'Go Pro · ৩× সীমা';

  @override
  String get progressStudyDays => 'পঢ়া দিনসমূহ';

  @override
  String get progressThisWeek => 'এই সপ্তাহ';

  @override
  String get progressTodayStudied => 'আজি · পঢ়া হৈছে';

  @override
  String get progressTodayNotYet => 'আজি · এতিয়াও পঢ়া নাই';

  @override
  String get progressTabSummary => 'সাৰাংশ';

  @override
  String get progressTabProgress => 'অগ্ৰগতি';

  @override
  String get progressTabActivity => 'কাৰ্যকলাপ';

  @override
  String get progressSubjectsThisWeek => 'এই সপ্তাহৰ বিষয়সমূহ';

  @override
  String get progressCompleted => 'সম্পূৰ্ণ হ’ল';

  @override
  String get progressOverallGrade => 'সামগ্ৰিক গ্ৰেড';

  @override
  String get progressKeepItUp => 'এয়াই অব্যাহত ৰাখক';

  @override
  String get progressStartJourney => 'আপোনাৰ যাত্ৰা আৰম্ভ কৰক';

  @override
  String get progressCourseProgress => 'কোৰ্চৰ অগ্ৰগতি';

  @override
  String get progressLessonsEmpty =>
      'আপুনি সম্পূৰ্ণ কৰা পাঠসমূহ ইয়াত দেখা যাব।';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটা পাঠ',
      one: '১টা পাঠ',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'কাৰ্যকলাপ';

  @override
  String get progressStudyDaysEmpty => 'আপোনাৰ পঢ়া দিনসমূহ ইয়াত দেখা যাব।';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'এই সপ্তাহত $count দিন সক্ৰিয়।',
      one: 'এই সপ্তাহত ১ দিন সক্ৰিয়।',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'আপোনাৰ যাত্ৰা আৰম্ভ কৰাৰ সময় হ’ল!';

  @override
  String get progressCtaMomentum => 'আপোনাৰ গতি বৰ্তাই ৰাখক';

  @override
  String get progressCtaHabit => 'আপুনি এটা অভ্যাস গঢ়ি তুলিছে';

  @override
  String get progressCtaNext => 'পৰৱৰ্তী সময়ত কি কৰিব লাগিব চাওক';

  @override
  String get progressNextSteps => 'পৰৱৰ্তী পদক্ষেপসমূহ';

  @override
  String get progressYourSetup => 'আপোনাৰ চেটআপ';

  @override
  String get progressWhatNext => 'পৰৱৰ্তী সময়ত কি কৰিব';

  @override
  String get progressNextWithStudy =>
      'এই সপ্তাহত পাঠসমূহ শেষ কৰি থাকক। আপুনি সম্পূৰ্ণ কৰাৰ পিছত আপোনাৰ গ্ৰেড আপডেট হয়।';

  @override
  String get progressNextNoStudy =>
      'Me ত, ক্লাছ আৰু বোৰ্ড নিশ্চিত কৰক। তাৰ পিছত Study খোলক আৰু আপোনাৰ প্ৰথম পাঠটো সম্পূৰ্ণ কৰক।';

  @override
  String get progressWeekEmpty =>
      'এই সপ্তাহত এতিয়ালৈ কোনো পঢ়া ৰেকৰ্ড কৰা হোৱা নাই।';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন সক্ৰিয়',
      one: '১ দিন সক্ৰিয়',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পাঠ',
      one: '১ টা পাঠ',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা চেপ্টাৰ টেষ্ট',
      one: '১ টা চেপ্টাৰ টেষ্ট',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'এই সপ্তাহত: $parts।';
  }

  @override
  String get progressWeekdayMon => 'সো';

  @override
  String get progressWeekdayTue => 'ম';

  @override
  String get progressWeekdayWed => 'বু';

  @override
  String get progressWeekdayThu => 'বৃ';

  @override
  String get progressWeekdayFri => 'শু';

  @override
  String get progressWeekdaySat => 'শ';

  @override
  String get progressWeekdaySun => 'ৰ';

  @override
  String get subjectsStreamTitle => 'আপোনাৰ ষ্ট্ৰীম';

  @override
  String get subjectsSave => 'ছেভ কৰক';

  @override
  String get subjectsLoadError =>
      'আপোনাৰ বিষয়সমূহ লোড কৰিব পৰা নগ’ল। পুনৰ চেষ্টা কৰক';

  @override
  String get subjectsMain => 'মুখ্য';

  @override
  String get subjectsOptional => 'বৈচ্ছিক';

  @override
  String streamSwipeFor(String name) {
    return '$name ৰ বাবে চুইপ কৰক। Me ত ইয়াক যিকোনো সময়তে সলনি কৰক।';
  }

  @override
  String get streamChangeInMe => 'Me ত ইয়াক যিকোনো সময়তে সলনি কৰক।';

  @override
  String streamChoose(String name) {
    return '$name বাছক';
  }

  @override
  String get classDialLabel => 'ক্লাছ';

  @override
  String classDialSemantics(int level) {
    return 'ক্লাছ $level';
  }

  @override
  String get studyTitle => 'অধ্যয়ন';

  @override
  String get studyCourses => 'কোৰ্চসমূহ';

  @override
  String get studyFolders => 'ফ\'ল্ডাৰসমূহ';

  @override
  String get studyDone => 'সম্পূৰ্ণ';

  @override
  String get studyKeep => 'ৰাখক';

  @override
  String get studyDelete => 'মচি পেলাওক';

  @override
  String get studySave => 'সংৰক্ষণ কৰক';

  @override
  String get studyCreate => 'সৃষ্টি কৰক';

  @override
  String get studyAdd => 'যোগ কৰক';

  @override
  String get studyOptional => 'ঐচ্ছিক';

  @override
  String get studyName => 'নাম';

  @override
  String get studyToday => 'আজি';

  @override
  String get studyComingSoon => 'শীঘ্ৰেই আহি আছে';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'অধ্যায় $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পাঠৰ',
      one: '1 টা পাঠৰ',
    );
    return '$_temp0 ভিতৰত $done সম্পূৰ্ণ';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা শীঘ্ৰেই আহি আছে',
      one: '১ টা শীঘ্ৰেই আহি আছে',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'ব’ৰ্ড পৰীক্ষাত নাহে';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা কাৰ্ড',
      one: '১ টা কাৰ্ড',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা দ্ৰুত পৰীক্ষা',
      one: '১ টা দ্ৰুত পৰীক্ষা',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা প্ৰশ্ন',
      one: '১ টা প্ৰশ্ন',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা অধ্যায়',
      one: '১ টা অধ্যায়',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পাঠ',
      one: '১ টা পাঠ',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes মিনিট';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'প্ৰায় $minutes মিনিট';
  }

  @override
  String get coursesNeedSyllabus =>
      'আপোনাৰ পাঠ্যক্ৰম চাবলৈ হোম পেজত আপোনাৰ শ্ৰী আৰু ব’ৰ্ড ছেট কৰক।';

  @override
  String get coursesLoadError =>
      'আপোনাৰ পাঠ্যক্ৰম ল’ড কৰিব পৰা নগ’ল। পুনৰ চেষ্টা কৰক';

  @override
  String coursesComingSoon(String syllabus) {
    return '$syllabus ৰ বাবে পাঠসমূহ আহি আছে। ইয়াৰ ভিতৰতে ASKMe ত Pebby ক যিকোনো প্রশ্ন সুধক।';
  }

  @override
  String get coursesNoFilterMatch =>
      'এই ফিল্টাৰসমূহৰ সৈতে কোনো অধ্যায় মিল খোৱা নাই।';

  @override
  String get coursesFinishedEmpty => 'সম্পূৰ্ণ কৰা অধ্যায়সমূহ ইয়াত দেখা যাব।';

  @override
  String get coursesStartedEmpty => 'আপুনি আৰম্ভ কৰা অধ্যায়সমূহ ইয়াত দেখা যাব।';

  @override
  String get coursesGoAgain => 'পুনৰ যাওক';

  @override
  String coursesContinueCard(int current, int total) {
    return 'আৰম্ভ কৰক · কাৰ্ড $current / $total';
  }

  @override
  String get coursesStart => 'আৰম্ভ কৰক';

  @override
  String get filterAll => 'সকলো';

  @override
  String get filterInProgress => 'চলিম আছে';

  @override
  String get filterDone => 'সম্পূৰ্ণ';

  @override
  String get filterFilters => 'ফিল্টাৰসমূহ';

  @override
  String filterFiltersOn(int count) {
    return 'ফিল্টাৰসমূহ, $count টা সক্ৰিয়';
  }

  @override
  String get filterClear => 'মহাৰক';

  @override
  String get filterSort => 'সজাওক';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা অধ্যায়',
      one: '১ টা অধ্যায়',
    );
    return '$_temp0 দেখুৱাওক';
  }

  @override
  String get filterBoardExamOnly => 'বোৰ্ড পৰীক্ষা কেৱল';

  @override
  String get filterBoardExamOnlyDesc =>
      'স্কুলত মূল্যায়িত অধ্যায়সমূহ লুকুৱাওক';

  @override
  String get filterReadyToStudy => 'পঢ়িবলৈ প্ৰস্তুত';

  @override
  String get filterReadyToStudyDesc => 'শীঘ্ৰেই আহি থকা অধ্যায়সমূহ লুকুৱাওক';

  @override
  String get filterRevisionDue => 'ৰিভিজন বাকী আছে';

  @override
  String get filterRevisionDueDesc => 'ৰিভিজন কৰিবলৈ ৰখা কাৰ্ড থকা অধ্যায়সমূহ';

  @override
  String get filterSortTextbook => 'পাঠ্যপুথি';

  @override
  String get filterSortMostMarks => 'সাত্বাধিক নম্বৰ';

  @override
  String get filterSortRecent => 'শেহতীয়া';

  @override
  String get filterFlagBoardExam => 'বোৰ্ড পৰীক্ষা';

  @override
  String get filterFlagReady => 'প্ৰস্তুত';

  @override
  String get filterFlagRevisionDue => 'ৰিভিজন বাকী আছে';

  @override
  String filterRemove(String label) {
    return '$label আতৰাওক';
  }

  @override
  String get folderNew => 'নতুন ফ\'ল্ডাৰ';

  @override
  String get folderEdit => 'ফ\'ল্ডাৰ সম্পাদনা কৰক';

  @override
  String get folderEmptyHint =>
      'পৰীক্ষা, হোমৱৰ্ক বা যিকোনো প্ৰস্তুতিৰ বাবে এটা ফ\'ল্ডাৰ বনাওক। এটা তাৰিখ যোগ কৰক আৰু ই আপোনাৰ দিনবোৰ পৰিকল্পনা কৰিব।';

  @override
  String get folderEmpty => 'খালী';

  @override
  String get folderNothingLeftToday => 'আজি একো বাকী নাই';

  @override
  String folderTodoToday(int count) {
    return 'আজি কৰিবলগীয়া $count টা';
  }

  @override
  String get folderNoDate => 'তাৰিখ নাই';

  @override
  String folderPercentReady(int percent) {
    return '$percent% প্ৰস্তুত';
  }

  @override
  String get folderWhatsFor => 'এই ফ\'ল্ডাৰটো কিহৰ বাবে?';

  @override
  String get folderAddChaptersPlan =>
      'অধ্যায়সমূহ যোগ কৰক আৰু Pebby এ আপোনাৰ দিনবোৰ পৰিকল্পনা কৰিব।';

  @override
  String get folderAddChapters => 'অধ্যায়সমূহ যোগ কৰক';

  @override
  String get folderFromSyllabus => 'আপোনাৰ পাঠ্যক্ৰমৰ পৰা';

  @override
  String get folderWriteNote => 'এটা টোকা লিখক';

  @override
  String get folderNoteSubtitle => 'আপুনি যি মনত ৰাখিব বিচাৰে';

  @override
  String get folderScanNotes => 'টোকা স্কেন কৰক';

  @override
  String get folderScanNotesSubtitle => 'পাঠৰ ছবি, এটা পাঠলৈ পৰিণত কৰা হৈছে';

  @override
  String get folderAddTodo => 'এটা কৰণীয় কাম যোগ কৰক';

  @override
  String get folderAddDate => 'তাৰিখ যোগ কৰক';

  @override
  String get folderRemoveDate => 'তাৰিখ আতৰ a';

  @override
  String get folderReminders => 'এই ফোল্ডাৰটোৰ বাবে সোঁৱৰণি';

  @override
  String get folderDeleteTitle => 'এই ফোল্ডাৰটো মচি পেলাব নেকি?';

  @override
  String get folderDeleteBody =>
      'ইয়াৰ টোকা আৰু কামবোৰো গুচি যাব। আপোনাৰ পাঠ আৰু প্ৰগতি থাকি যাব।';

  @override
  String get folderTitle => 'ফোল্ডাৰ';

  @override
  String get folderEditRemindersTooltip => 'সম্পাদনা আৰু সোঁৱৰণি';

  @override
  String get folderDeleteTooltip => 'ফোল্ডাৰ মচি পেলাওক';

  @override
  String get folderLoadError =>
      'এই ফোল্ডাৰটো ল\'ড কৰিব পৰা নগ\'ল। পুনৰ চেষ্টা কৰক';

  @override
  String folderTodayMinutes(int minutes) {
    return 'আজি · $minutes মিনিট';
  }

  @override
  String get folderSeePlan => 'পিকল্প চাওক';

  @override
  String get folderAddChaptersOrTodos => 'অধ্যায় বা কৰণীয় কাম যোগ কৰক।';

  @override
  String get folderNothingLeftForToday => 'আজিলৈ আৰু একো বাকী নাই।';

  @override
  String get folderInThisFolder => 'এই ফোল্ডাৰত';

  @override
  String get folderFromNotesDone => 'আপোনাৰ টোকাৰ পৰা · সম্পূৰ্ণ হ\'ল';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'আপোনাৰ টোকাৰ পৰা · $minutes মিনিট';
  }

  @override
  String get folderNote => 'টোকা';

  @override
  String get folderSaveNote => 'টোকা ছেভ কৰক';

  @override
  String get folderTypeHere => 'ইয়াত টাইপ কৰক…';

  @override
  String get folderAddTo => 'এটা ফোল্ডাৰত যোগ কৰক';

  @override
  String get folderCouldntMake => 'ফোল্ডাৰটো বনাৰ নোৱাৰিলে। পুনৰ চেষ্টা কৰক।';

  @override
  String folderAddedTo(String name) {
    return '$name লৈ যোগ কৰা হ\'ল';
  }

  @override
  String get folderYourFolder => 'আপোনাৰ ফোল্ডাৰ';

  @override
  String get folderPlan => 'পিকল্প';

  @override
  String folderPlanTo(String date) {
    return '$date লৈকে পৰিকল্পনা';
  }

  @override
  String get folderPlanBody =>
      'এই ফোল্ডাৰৰ অধ্যায়সমূহৰ পৰা তৈয়াৰ কৰা হৈছে। কিবা বাদ পৰিল নেকি? ই নিজেই পিছৰ দিনালৈ গুচি যায়।';

  @override
  String get folderTestDay => 'পৰীক্ষাৰ দিন · আপুনি প্ৰস্তুত';

  @override
  String get folderRestDay => 'বিশ্ৰামৰ দিন';

  @override
  String get folderDueTomorrow => 'কাইলৈ';

  @override
  String get folderDueYesterday => 'যোৱাকালী';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন',
      one: '১ দিন',
    );
    return '$_temp0ৰ আগতে';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count দিন',
      one: '১ দিন',
    );
    return '$_temp0ৰ পিছত';
  }

  @override
  String chapterTitle(int number) {
    return 'অধ্যায় $number';
  }

  @override
  String get chapterLessons => 'পাঠসমূহ';

  @override
  String get chapterTest => 'অধ্যায় পৰীক্ষা';

  @override
  String chapterTestLast(int correct, int total) {
    return 'যোৱাবাৰ $correct/$total · আকৌ চেষ্টা কৰক';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা প্ৰশ্ন',
      one: '১ টা প্ৰশ্ন',
    );
    return 'প্ৰতিটো পাঠৰ পৰা $_temp0';
  }

  @override
  String get chapterKeptCards => 'সংৰক্ষিত কাৰ্ডসমূহ';

  @override
  String get chapterKeptEmpty => 'ইয়াত ছেভ কৰিবলৈ যিকোনো কাৰ্ডত Keep টিপক';

  @override
  String chapterKeptCount(int count) {
    return 'ৰিভিজন কৰিবলৈ $count টা';
  }

  @override
  String get chapterAllDoneGoAgain => 'সকলো পাঠ শেষ · আকৌ যাওক';

  @override
  String chapterResumeCard(int current, int total) {
    return 'পুনৰ আৰম্ভ কৰক · কাৰ্ড $current / $total';
  }

  @override
  String get chapterNextLesson => 'পৰৱৰ্তী পাঠ';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'পাঠ $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes টা সঠিক';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'শীঘ্ৰেই আহি আছে · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'পাঠসমূহ শেষ · পৰৱৰ্তী পৰীক্ষা';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'সম্পূৰ্ণ হ’ল · পৰীক্ষা $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return '· $count টা শীঘ্ৰেই আহি আছে';
  }

  @override
  String get chapterNotInBoardExamSuffix => '· ব’ৰ্ড পৰীক্ষাত নাই';

  @override
  String get chapterReportGreat => 'দৰ্শনীয় কাম';

  @override
  String get chapterReportGood => 'ভাল চলিছে';

  @override
  String get chapterReportRetry => 'আকৌ এটা চেষ্টাৰ যোগ্য';

  @override
  String get chapterReportByLesson => 'পাঠ অনুসৰি';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'আপুনি যিবোৰ বাদ দিছে সেইবোৰ ৰিভিজন কৰক';

  @override
  String get chapterAddToFolderAction => 'এটা ফ’ল্ডাৰত চেপ্টাৰ যোগ কৰক';

  @override
  String get chapterBackToChapter => 'চেপ্টাৰলৈ ঘূৰি যাওক';

  @override
  String get chapterNoChaptersYet =>
      'আপোনাৰ শ্ৰেণীৰ বাবে এতিয়াও কোনো চেপ্টাৰ নাই।';

  @override
  String get chapterAlreadyInFolder => 'ইতিমধ্যে এই ফ’ল্ডাৰত আছে';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done টা শেষ';
  }

  @override
  String get chapterPickChapters => 'চেপ্টাৰ বাছনি কৰক';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা চেপ্টাৰ',
      one: '১ টা চেপ্টাৰ',
    );
    return '$_temp0 যোগ কৰক';
  }

  @override
  String get chapterAddChaptersTitle => 'চেপ্টাৰ যোগ কৰক';

  @override
  String get deckReportTitle => 'এই পাঠটো ৰিপ’ৰ্ট কৰক';

  @override
  String get deckReportThanks => 'ধন্যবাদ। আমি এই পাঠটো পৰীক্ষা কৰি চাম।';

  @override
  String get deckLoadError => 'এই পাঠটো ল’ড কৰিব পৰা নগ’ল। পুনৰ চেষ্টা কৰক';

  @override
  String get deckPerfect => 'পৰিপূৰ্ণ পাঠ!';

  @override
  String get deckLessonDone => 'পাঠ শেষ!';

  @override
  String get deckStatRight => 'সঠিক';

  @override
  String get deckStatKept => 'সংরক্ষণ কৰা হ’ল';

  @override
  String deckNextTitle(String title) {
    return 'পৰৱৰ্তী: $title';
  }

  @override
  String get deckStart => 'আৰম্ভ কৰক';

  @override
  String deckShowStep(int step) {
    return '$step নম্বৰ স্তৰ দেখুৱাওক';
  }

  @override
  String get deckCheck => 'যাচাই কৰক';

  @override
  String get deckNext => 'পৰৱৰ্তী';

  @override
  String get deckFinish => 'শেষ কৰক';

  @override
  String get deckPreviousCard => 'আগৰ কাৰ্ড';

  @override
  String get deckNewLesson => 'নতুন পাঠ';

  @override
  String get deckByTheEnd => 'শেষলৈ আপুনি পাৰিব:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · প্ৰায় $minutes মিনিট';
  }

  @override
  String get deckConcept => 'ধাৰণা';

  @override
  String get deckInOneLook => 'এপলকত';

  @override
  String get deckSummary => 'সাৰাংশ';

  @override
  String get deckThreeLines => 'তিনিশাৰীত পাঠটো';

  @override
  String get deckKeptForRevision => 'পুনৰালোচনাৰ বাবে সংৰক্ষিত';

  @override
  String get deckKeptRevisionOne =>
      'এই পাঠৰ পৰা ১ টা কাৰ্ড আপোনাৰ পুনৰালোচনালৈ ঘূৰি আহিব।';

  @override
  String deckKeptRevisionMany(int count) {
    return 'এই পাঠৰ পৰা $count টা কাৰ্ড আপোনাৰ পুনৰালোচনালৈ ঘূৰি আহিব।';
  }

  @override
  String get deckWorkedExample => 'কৰা উদাহৰণ';

  @override
  String deckStepTryFirst(int step) {
    return 'স্তৰ $step · প্ৰথমে চেষ্টা কৰক';
  }

  @override
  String get deckRemember => 'মনত ৰাখিব';

  @override
  String get deckKept => 'সংৰক্ষিত';

  @override
  String get deckAskPebby => 'Pebby-ক সোধক';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'আপুনি ইয়াক আৰু সহজে বুজাব পাৰেনে? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return 'আপুনি এটা উদাহৰণসহ \"$title\" বুজাব পাৰেনে?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'এইটো কেনেকৈ সমাধান কৰিব বুজাব পাৰেনে: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'মোৰ এইটো ভুল হ’ল: $question কিয় এনে হ’ল: $why';
  }

  @override
  String get deckAskExplainLesson => 'আপুনি এই পাঠটো বুজাব পাৰেনে?';

  @override
  String get deckGoals => 'লক্ষ্যসমূহ';

  @override
  String get quizQuickCheck => 'দুতীয়া পৰীক্ষা';

  @override
  String quizQuestionOf(int current, int total) {
    return 'প্ৰশ্ন $current / $total';
  }

  @override
  String get quizPraise1 => 'ধুনীয়া! সেয়া সঠিক।';

  @override
  String get quizPraise2 => 'একেবাৰে সঠিক!';

  @override
  String get quizPraise3 => 'আপুনি বুজি পালে!';

  @override
  String get quizPraise4 => 'শুদ্ধ, বৰ ভাল হ’ল!';

  @override
  String get quizPraise5 => 'একেবাৰে সঠিক!';

  @override
  String get quizHeresWhy => 'ইয়াৰ কাৰণটো হ’ল';

  @override
  String get quizYourAnswer => 'আপোনাৰ উত্তৰ';

  @override
  String get quizRightAnswer => 'সঠিক উত্তৰ';

  @override
  String get quizKeptForYou => 'আপোনাৰ বাবে সংৰক্ষিত';

  @override
  String get quizComesBack =>
      'এই প্ৰশ্নটো কাইলৈ আপোনাৰ সংশোধনী (revision) ত আকৌ আহিব।';

  @override
  String get quizNotQuite => 'অলপৰ বাবে মিল নহ’ল। পৰৱৰ্তী: কিয়।';

  @override
  String quizStreak(int count) {
    return '$count টা একেৰাহে';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'সংশোধনী (Revision)';

  @override
  String get studyRevisionEmptyTitle => 'সংশোধন কৰিবলৈ একো নাই';

  @override
  String get studyRevisionEmptyBody =>
      'পাঠ এটাত কাৰ্ডবোৰ ৰাখক, বা এটা প্ৰশ্ন বাদ পৰক, আৰু সিহঁত ইয়ালৈ ঘূৰি আহিব।';

  @override
  String get studyRevisionDone => 'সংশোধনী সম্পূৰ্ণ হ’ল';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew জানিছিলোঁ · $almost প্ৰায় · $again কাইলৈ আকৌ চাব লাগিব';
  }

  @override
  String get studyRevisionHint => 'উত্তৰটো ভাবক, তাৰপিছত চাবলৈ টিপক।';

  @override
  String get studyRevisionShowAnswer => 'উত্তৰ দেখুৱাওক';

  @override
  String get studyRevisionAgain => 'নাজানিছিলোঁ';

  @override
  String get studyRevisionAlmost => 'প্ৰায়';

  @override
  String get studyRevisionKnew => 'জানিছিলোঁ';

  @override
  String chapterTestDeckTitle(int number) {
    return 'অধ্যায় $number পৰীক্ষা';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count টা পাঠ',
      one: '১ টা পাঠ',
    );
    return '$_temp0 ৰ ভিতৰত $done টা';
  }

  @override
  String get actionTryAgain => 'আকৌ চেষ্টা কৰক';

  @override
  String get actionGoPro => 'প্ৰ’ লৈ যাওক (Go Pro)';

  @override
  String get actionBack => 'পিছুৱাই যাওক (Back)';

  @override
  String get actionClose => 'বন্ধ কৰক';

  @override
  String get failureNetwork =>
      'কোনো সংযোগ নাই। আপোনাৰ ইণ্টাৰনেট পৰীক্ষা কৰি আকৌ চেষ্টা কৰক।';

  @override
  String get failureUnknown => 'কিবা এটা ভুল হ’ল। আকৌ চেষ্টা কৰক।';
}
