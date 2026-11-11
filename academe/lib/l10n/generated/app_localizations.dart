import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
    Locale('hi'),
    Locale('ta'),
    Locale('te'),
  ];

  /// MaterialApp title and brand name
  ///
  /// In en, this message translates to:
  /// **'ACADEMe'**
  String get appTitle;

  /// Me settings row and language sheet title
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get meAppLanguage;

  /// Language sheet explainer while remaining screens migrate
  ///
  /// In en, this message translates to:
  /// **'Pebby and Scan teaching replies use this language. App chrome follows it as we finish translating.'**
  String get meLanguageSheetBody;

  /// Footer on language sheet for languages not yet shipped
  ///
  /// In en, this message translates to:
  /// **'More languages coming soon'**
  String get meMoreLanguagesComing;

  /// Language switch screen primary line; name is native language name
  ///
  /// In en, this message translates to:
  /// **'Switching to {name}…'**
  String languageSwitchingTo(String name);

  /// Bottom nav Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav ASKMe tab label
  ///
  /// In en, this message translates to:
  /// **'ASKMe'**
  String get navAskMe;

  /// Bottom nav Study tab label
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get navStudy;

  /// Bottom nav Me tab label
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// Semantics label for the Scan camera key
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// Semantics label for the ask-bar send key
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get navSend;

  /// Placeholder in the shell ask text field
  ///
  /// In en, this message translates to:
  /// **'Ask anything…'**
  String get askAnythingHint;

  /// Tooltip for attach on the ask bar
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get askAttach;

  /// Fallback soft-update banner copy when the server sends an empty message
  ///
  /// In en, this message translates to:
  /// **'New version just dropped, you don\'t wanna miss this!'**
  String get softUpdateDefaultMessage;

  /// Soft-update banner primary action
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get softUpdateAction;

  /// Soft-update banner dismiss tooltip
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get softUpdateDismiss;

  /// Force-update screen title
  ///
  /// In en, this message translates to:
  /// **'Hold up'**
  String get updateRequiredTitle;

  /// Force-update explanation under the server message
  ///
  /// In en, this message translates to:
  /// **'This build can’t talk to our servers anymore. Update on Play to keep studying.'**
  String get updateRequiredBody;

  /// Force-update footer showing the installed build number
  ///
  /// In en, this message translates to:
  /// **'Installed build {build}.'**
  String updateRequiredBuild(String build);

  /// Force-update primary button
  ///
  /// In en, this message translates to:
  /// **'Update on Google Play'**
  String get updateRequiredAction;

  /// Accessibility label for the Pebby mascot
  ///
  /// In en, this message translates to:
  /// **'Pebby'**
  String get pebbySemantics;

  /// Welcome hero lead; keep the line break
  ///
  /// In en, this message translates to:
  /// **'Study\nsmarter.'**
  String get welcomeHeadlineLead;

  /// Welcome hero accent next to the lead
  ///
  /// In en, this message translates to:
  /// **'Not longer.'**
  String get welcomeHeadlineAccent;

  /// Welcome hero body under the headline
  ///
  /// In en, this message translates to:
  /// **'Notes, quizzes and flashcards made from what you are actually studying.'**
  String get welcomeBody;

  /// Welcome start primary button
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeGetStarted;

  /// Inline link lead on welcome start and sign-up sheet
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get welcomeAlreadyHaveAccount;

  /// Inline link lead on welcome log-in sheet
  ///
  /// In en, this message translates to:
  /// **'New user? '**
  String get welcomeNewUser;

  /// Welcome legal footer under start actions
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy Policy.'**
  String get welcomeLegal;

  /// Sign-up sheet title and footer action
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUp;

  /// Log-in sheet title and footer action
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// OAuth Google button on welcome account options
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// OAuth Apple button on welcome account options
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// Email auth button on welcome account options
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get authContinueEmail;

  /// Login email screen headline lead
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginHeadlineLead;

  /// Login email screen headline accent
  ///
  /// In en, this message translates to:
  /// **'back.'**
  String get loginHeadlineAccent;

  /// Login email screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Log in to pick up where you left off.'**
  String get loginSubtitle;

  /// Email field label on auth screens
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Default password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Password field reveal tooltip
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// Password field conceal tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// Login link to password reset
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Login button while the request runs
  ///
  /// In en, this message translates to:
  /// **'Logging in…'**
  String get authLoggingIn;

  /// Login footer lead linking to sign up
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get authNewHere;

  /// Forgot-password headline lead
  ///
  /// In en, this message translates to:
  /// **'Forgot your'**
  String get forgotPasswordLead;

  /// Forgot-password headline accent
  ///
  /// In en, this message translates to:
  /// **'password?'**
  String get forgotPasswordAccent;

  /// Forgot-password subtitle
  ///
  /// In en, this message translates to:
  /// **'Type your email and I\'ll send you a 6-digit code.'**
  String get forgotPasswordSubtitle;

  /// Send-code button while the request runs
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get authSending;

  /// Forgot-password primary action
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get authSendCode;

  /// Reset-code headline lead
  ///
  /// In en, this message translates to:
  /// **'Check your'**
  String get resetCodeLead;

  /// Reset-code headline accent
  ///
  /// In en, this message translates to:
  /// **'email.'**
  String get resetCodeAccent;

  /// Reset-code subtitle including the target email
  ///
  /// In en, this message translates to:
  /// **'If {email} has an ACADEMe account, a 6-digit code is on its way. It expires in 15 minutes.'**
  String resetCodeSubtitle(String email);

  /// Reset-code paste action
  ///
  /// In en, this message translates to:
  /// **'Paste code'**
  String get authPasteCode;

  /// Verify button while the request runs
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get authChecking;

  /// Reset-code verify action
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// Resend link lead when resend is available
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it? '**
  String get resetDidntGetIt;

  /// Resend link action
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resetSendNewCode;

  /// Resend status while the request runs
  ///
  /// In en, this message translates to:
  /// **'Sending a new code…'**
  String get resetSendingNewCode;

  /// Resend cooldown after a successful resend
  ///
  /// In en, this message translates to:
  /// **'New code sent. You can ask again in 0:{seconds}'**
  String resetNewCodeSent(String seconds);

  /// Resend cooldown before the next request
  ///
  /// In en, this message translates to:
  /// **'You can ask for a new code in 0:{seconds}'**
  String resetAskAgainIn(String seconds);

  /// New-password headline lead
  ///
  /// In en, this message translates to:
  /// **'Choose a new'**
  String get newPasswordLead;

  /// New-password headline accent
  ///
  /// In en, this message translates to:
  /// **'password.'**
  String get newPasswordAccent;

  /// New-password subtitle
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters. Don\'t worry, I won\'t look.'**
  String get newPasswordSubtitle;

  /// New-password field label
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// Password length checklist row
  ///
  /// In en, this message translates to:
  /// **'{count}+ characters'**
  String authPasswordMinLength(int count);

  /// Expired reset primary action
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get authStartAgain;

  /// Save button while the request runs
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get authSaving;

  /// New-password primary action
  ///
  /// In en, this message translates to:
  /// **'Save and log in'**
  String get authSaveAndLogIn;

  /// AuthFailure.emailTaken and sign-up email taken
  ///
  /// In en, this message translates to:
  /// **'An account already uses this email. Log in instead.'**
  String get authFailureEmailTaken;

  /// AuthFailure.wrongCredentials
  ///
  /// In en, this message translates to:
  /// **'That email and password don\'t match.'**
  String get authFailureWrongCredentials;

  /// AuthFailure.invalidInput
  ///
  /// In en, this message translates to:
  /// **'Check your details and try again.'**
  String get authFailureInvalidInput;

  /// AuthFailure.signedOut
  ///
  /// In en, this message translates to:
  /// **'Your session ended. Log in again.'**
  String get authFailureSignedOut;

  /// AuthFailure.network
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach ACADEMe. Check your connection and try again.'**
  String get authFailureNetwork;

  /// AuthFailure.canceled
  ///
  /// In en, this message translates to:
  /// **'Sign-in was canceled.'**
  String get authFailureCanceled;

  /// AuthFailure.providerUnavailable
  ///
  /// In en, this message translates to:
  /// **'This sign-in option isn\'t ready yet. Use email for now.'**
  String get authFailureProviderUnavailable;

  /// AuthFailure.wrongCode
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t right. Check the email and try again.'**
  String get authFailureWrongCode;

  /// AuthFailure.tooManyAttempts
  ///
  /// In en, this message translates to:
  /// **'Too many wrong tries. Send yourself a new code.'**
  String get authFailureTooManyAttempts;

  /// AuthFailure.codeExpired
  ///
  /// In en, this message translates to:
  /// **'That code has expired. Send yourself a new one.'**
  String get authFailureCodeExpired;

  /// AuthFailure.resetExpired
  ///
  /// In en, this message translates to:
  /// **'This reset link timed out. Start again from Forgot password.'**
  String get authFailureResetExpired;

  /// AuthFailure.tooManyRequests
  ///
  /// In en, this message translates to:
  /// **'That\'s a lot of tries. Wait a little and try again.'**
  String get authFailureTooManyRequests;

  /// AuthFailure.wrongPassword
  ///
  /// In en, this message translates to:
  /// **'That isn\'t your current password.'**
  String get authFailureWrongPassword;

  /// AuthFailure.googleTaken
  ///
  /// In en, this message translates to:
  /// **'That Google account is linked to another ACADEMe account.'**
  String get authFailureGoogleTaken;

  /// AuthFailure.passwordRequired
  ///
  /// In en, this message translates to:
  /// **'Set a password first, so you can still log in without Google.'**
  String get authFailurePasswordRequired;

  /// Sign-up hello title for email or unnamed Google
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m Pebby!'**
  String get signUpHiPebby;

  /// Sign-up hello title when Google already gave a first name
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, I\'m Pebby!'**
  String signUpHiNamed(String name);

  /// Sign-up first-name step title
  ///
  /// In en, this message translates to:
  /// **'Before we start, what should I call you?'**
  String get signUpAskFirstName;

  /// Sign-up first-name field label
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get signUpFirstName;

  /// Sign-up last-name step title
  ///
  /// In en, this message translates to:
  /// **'Nice to meet you, {name}! And your last name?'**
  String signUpAskLastName(String name);

  /// Sign-up last-name field label
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get signUpLastName;

  /// Sign-up email step title
  ///
  /// In en, this message translates to:
  /// **'What\'s your email, {name}?'**
  String signUpAskEmail(String name);

  /// Sign-up email step subtitle
  ///
  /// In en, this message translates to:
  /// **'You\'ll use it to log in.'**
  String get signUpEmailHint;

  /// Sign-up email field validation
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like an email yet.'**
  String get signUpEmailInvalid;

  /// Sign-up password step title
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get signUpCreatePassword;

  /// Sign-up password step subtitle
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters. Don\'t worry, I won\'t look.'**
  String signUpPasswordHint(int count);

  /// Sign-up done title for a returning account
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}!'**
  String signUpWelcomeBack(String name);

  /// Sign-up done subtitle for a returning account
  ///
  /// In en, this message translates to:
  /// **'You already have an account, so you\'re logged in.'**
  String get signUpAlreadyLoggedIn;

  /// Sign-up done title for a new account
  ///
  /// In en, this message translates to:
  /// **'You\'re in, {name}!'**
  String signUpYoureIn(String name);

  /// Sign-up done subtitle for a new account
  ///
  /// In en, this message translates to:
  /// **'Your account is ready. Next, tell me what you study.'**
  String get signUpAccountReady;

  /// Sign-up hello subtitle for email method
  ///
  /// In en, this message translates to:
  /// **'I\'ll help you study smarter. Let\'s set up your account, it takes a minute.'**
  String get signUpHelloEmail;

  /// Sign-up hello subtitle while OAuth runs
  ///
  /// In en, this message translates to:
  /// **'Connecting your account…'**
  String get signUpConnectingAccount;

  /// Sign-up hello subtitle after OAuth succeeds
  ///
  /// In en, this message translates to:
  /// **'Let\'s check your name, then you\'re in.'**
  String get signUpCheckName;

  /// Sign-up primary button while OAuth runs
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get signUpConnecting;

  /// Sign-up primary button on hello step
  ///
  /// In en, this message translates to:
  /// **'Hi Pebby!'**
  String get signUpHiPebbyAction;

  /// Sign-up primary button while createAccount runs
  ///
  /// In en, this message translates to:
  /// **'Creating your account…'**
  String get signUpCreatingAccount;

  /// Sign-up primary button on password step
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpCreateAccount;

  /// Sign-up primary button on done step
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get signUpLetsGo;

  /// Generic continue primary button on sign-up steps
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// Home setup checklist card title
  ///
  /// In en, this message translates to:
  /// **'Set up your dashboard'**
  String get homeSetupTitle;

  /// Setup checklist XP progress pill
  ///
  /// In en, this message translates to:
  /// **'{done} / {total} XP'**
  String homeSetupXpProgress(int done, int total);

  /// Setup checklist language row
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeSetupTaskLanguage;

  /// Setup checklist age row
  ///
  /// In en, this message translates to:
  /// **'Your age'**
  String get homeSetupTaskAge;

  /// Setup checklist class row
  ///
  /// In en, this message translates to:
  /// **'Your class'**
  String get homeSetupTaskClass;

  /// Setup checklist board row
  ///
  /// In en, this message translates to:
  /// **'Your board'**
  String get homeSetupTaskBoard;

  /// Setup checklist subjects row
  ///
  /// In en, this message translates to:
  /// **'Your subjects'**
  String get homeSetupTaskSubjects;

  /// Setup checklist earned XP label
  ///
  /// In en, this message translates to:
  /// **'✓ {xp} XP'**
  String homeSetupXpDone(int xp);

  /// Setup checklist pending XP label
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String homeSetupXpEarn(int xp);

  /// Home quick action for Scan solve
  ///
  /// In en, this message translates to:
  /// **'Solve homework'**
  String get homeSolveHomework;

  /// Home quick action for Check
  ///
  /// In en, this message translates to:
  /// **'Check my answer'**
  String get homeCheckAnswer;

  /// Home quick action for flashcards
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get homeFlashcards;

  /// Home card prompting subject selection
  ///
  /// In en, this message translates to:
  /// **'Pick your subjects'**
  String get homePickSubjects;

  /// Home pick-subjects card body with XP reward
  ///
  /// In en, this message translates to:
  /// **'Home and Study show only the ones you take. +{xp} XP'**
  String homePickSubjectsBody(int xp);

  /// Setup language step title
  ///
  /// In en, this message translates to:
  /// **'Which language do you learn in?'**
  String get setupLanguageTitle;

  /// Setup language/stream choose button
  ///
  /// In en, this message translates to:
  /// **'Choose {name}'**
  String setupChooseLanguage(String name);

  /// Setup language footnote
  ///
  /// In en, this message translates to:
  /// **'You can change it any time in Settings.'**
  String get setupLanguageFootnote;

  /// Setup age step title
  ///
  /// In en, this message translates to:
  /// **'When were you born?'**
  String get setupAgeTitle;

  /// Setup age step subtitle
  ///
  /// In en, this message translates to:
  /// **'So we keep things right for your age.'**
  String get setupAgeSubtitle;

  /// Birth year wheel semantics
  ///
  /// In en, this message translates to:
  /// **'Birth year'**
  String get setupBirthYear;

  /// Setup age confirmation
  ///
  /// In en, this message translates to:
  /// **'You’re {age}.'**
  String setupYouAreAge(int age);

  /// Setup class step title
  ///
  /// In en, this message translates to:
  /// **'Spin to your class'**
  String get setupClassTitle;

  /// Setup class step subtitle
  ///
  /// In en, this message translates to:
  /// **'Turn the dial or tap a number.'**
  String get setupClassSubtitle;

  /// Setup class confirm button
  ///
  /// In en, this message translates to:
  /// **'I’m in Class {level}'**
  String setupImInClass(int level);

  /// Setup board step title
  ///
  /// In en, this message translates to:
  /// **'Which board?'**
  String get setupBoardTitle;

  /// Setup board step subtitle
  ///
  /// In en, this message translates to:
  /// **'We follow your board’s syllabus.'**
  String get setupBoardSubtitle;

  /// Setup board footnote
  ///
  /// In en, this message translates to:
  /// **'State boards are coming soon.'**
  String get setupStateBoardsSoon;

  /// Setup last-step primary action
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get setupFinish;

  /// Setup sheet progress caption
  ///
  /// In en, this message translates to:
  /// **'SET UP · {step}/{total}'**
  String setupProgress(int step, int total);

  /// Setup sheet dismiss
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get setupLater;

  /// Subjects picker footnote
  ///
  /// In en, this message translates to:
  /// **'You can change this any time in Me.'**
  String get setupChangeInMe;

  /// Setup stream pick title
  ///
  /// In en, this message translates to:
  /// **'What do you study in Class {level}?'**
  String setupStreamTitle(int level);

  /// Setup senior subjects title
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get setupAnythingElse;

  /// Setup junior subjects title
  ///
  /// In en, this message translates to:
  /// **'Which subjects do you study?'**
  String get setupWhichSubjects;

  /// Setup senior subjects subtitle
  ///
  /// In en, this message translates to:
  /// **'{syllabus}. Your main subjects are in.'**
  String setupMainSubjectsIn(String syllabus);

  /// Setup junior subjects subtitle
  ///
  /// In en, this message translates to:
  /// **'{syllabus}. Tap to remove any you don’t take.'**
  String setupTapToRemove(String syllabus);

  /// Home subjects section header
  ///
  /// In en, this message translates to:
  /// **'Your subjects'**
  String get homeYourSubjects;

  /// Home subjects edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homeEdit;

  /// Home subjects empty before syllabus
  ///
  /// In en, this message translates to:
  /// **'Set your class and board to see your subjects'**
  String get homeSubjectsNeedSyllabus;

  /// Home subjects loading
  ///
  /// In en, this message translates to:
  /// **'Loading your subjects…'**
  String get homeSubjectsLoading;

  /// Home subjects empty after load
  ///
  /// In en, this message translates to:
  /// **'Your subjects show up here soon.'**
  String get homeSubjectsSoon;

  /// Home subject row next lesson
  ///
  /// In en, this message translates to:
  /// **'Next: Ch {number} · {title}'**
  String homeNextChapter(int number, String title);

  /// Home subject row complete
  ///
  /// In en, this message translates to:
  /// **'All lessons done'**
  String get homeAllLessonsDone;

  /// Home subject row no lessons
  ///
  /// In en, this message translates to:
  /// **'Lessons coming soon'**
  String get homeLessonsComingSoon;

  /// Today card title with minutes left
  ///
  /// In en, this message translates to:
  /// **'Today · {minutes} min'**
  String homeTodayMinutes(int minutes);

  /// Today card title when done
  ///
  /// In en, this message translates to:
  /// **'Today · all done'**
  String get homeTodayDone;

  /// Today card folder count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{from 1 folder} other{from {count} folders}}'**
  String homeFromFolders(int count);

  /// Today card overflow
  ///
  /// In en, this message translates to:
  /// **'and {count} more in your folders'**
  String homeMoreInFolders(int count);

  /// Ask hint bubble title
  ///
  /// In en, this message translates to:
  /// **'Ask Pebby anything'**
  String get homeAskHintTitle;

  /// Ask hint bubble body
  ///
  /// In en, this message translates to:
  /// **'Type a question, or tap Solve homework to snap one.'**
  String get homeAskHintBody;

  /// Ask hint dismiss
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get homeAskHintGotIt;

  /// Dashboard load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your dashboard.'**
  String get homeDashboardLoadError;

  /// Dashboard retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// Fallback first name in greeting
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get helloFallbackName;

  /// Home greeting streak semantics label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String homeStreakSemantics(int count);

  /// Scan mode tile title for notes
  ///
  /// In en, this message translates to:
  /// **'Notes to a folder'**
  String get scanModeNotes;

  /// Scan mode tile title for ask
  ///
  /// In en, this message translates to:
  /// **'Ask about a photo'**
  String get scanModeAsk;

  /// Scan tab subtitle under the Scan headline
  ///
  /// In en, this message translates to:
  /// **'What’s on the paper?'**
  String get scanWhatsOnPaper;

  /// Scan solve mode tile caption
  ///
  /// In en, this message translates to:
  /// **'Hints first'**
  String get scanHintSolve;

  /// Scan check mode tile caption
  ///
  /// In en, this message translates to:
  /// **'Board-style marks'**
  String get scanHintCheck;

  /// Scan notes mode tile caption
  ///
  /// In en, this message translates to:
  /// **'Pages into a lesson'**
  String get scanHintNotes;

  /// Scan ask mode tile caption
  ///
  /// In en, this message translates to:
  /// **'Anything else'**
  String get scanHintAsk;

  /// Scan tab recent list section title
  ///
  /// In en, this message translates to:
  /// **'Recent scans'**
  String get scanRecent;

  /// Recent scan subtitle when OCR finished but not opened in ASKMe
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get scanStatusRead;

  /// Recent solve scan linked to an ASKMe thread
  ///
  /// In en, this message translates to:
  /// **'Solved in ASKMe'**
  String get scanStatusSolvedInAskMe;

  /// Recent ask scan linked to an ASKMe thread
  ///
  /// In en, this message translates to:
  /// **'Asked in ASKMe'**
  String get scanStatusAskedInAskMe;

  /// Recent check scan marks summary
  ///
  /// In en, this message translates to:
  /// **'{awarded}/{count, plural, =1{1 mark} other{{count} marks}}'**
  String scanStatusMarks(int awarded, int count);

  /// Recent check scan with no marking yet
  ///
  /// In en, this message translates to:
  /// **'Not marked yet'**
  String get scanStatusNotMarked;

  /// Recent notes scan saved as a lesson
  ///
  /// In en, this message translates to:
  /// **'Lesson in a folder'**
  String get scanStatusLessonInFolder;

  /// Recent notes scan saved as text only
  ///
  /// In en, this message translates to:
  /// **'Notes in a folder'**
  String get scanStatusNotesInFolder;

  /// Recent notes scan not yet filed
  ///
  /// In en, this message translates to:
  /// **'Not saved yet'**
  String get scanStatusNotSaved;

  /// Source sheet blurb for multi-page notes
  ///
  /// In en, this message translates to:
  /// **'Up to 10 pages. Only the text is kept, not the photos.'**
  String get scanSourceNotesBlurb;

  /// Source sheet blurb for single-photo modes
  ///
  /// In en, this message translates to:
  /// **'Only the text is kept, not the photo.'**
  String get scanSourceBlurb;

  /// Source sheet camera button
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get scanTakePhoto;

  /// Source sheet gallery button
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get scanChooseGallery;

  /// Notes pages view add-from-camera button
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get scanCamera;

  /// Notes pages view add-from-gallery button
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// Notes multi-page picker title
  ///
  /// In en, this message translates to:
  /// **'Your pages'**
  String get scanYourPages;

  /// Notes page count progress under the title
  ///
  /// In en, this message translates to:
  /// **'{current} of {max}'**
  String scanPagesOf(int current, int max);

  /// Notes primary button to OCR the pages
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Read 1 page} other{Read {count} pages}}'**
  String scanReadPages(int count);

  /// Tooltip to remove a page thumbnail
  ///
  /// In en, this message translates to:
  /// **'Remove page'**
  String get scanRemovePage;

  /// Notes review title when page count is zero
  ///
  /// In en, this message translates to:
  /// **'Your notes'**
  String get scanYourNotes;

  /// Notes review title after OCR
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Pebby read 1 page} other{Pebby read {count} pages}}'**
  String scanPebbyReadPages(int count);

  /// Notes folder picker section title
  ///
  /// In en, this message translates to:
  /// **'Where should these go?'**
  String get scanWhereShouldTheseGo;

  /// Notes folder row placeholder
  ///
  /// In en, this message translates to:
  /// **'Choose a folder'**
  String get scanChooseFolder;

  /// Notes folder row change action
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get scanChange;

  /// Notes save options section title
  ///
  /// In en, this message translates to:
  /// **'Make from your notes'**
  String get scanMakeFromNotes;

  /// Notes option to build a swipe lesson
  ///
  /// In en, this message translates to:
  /// **'Swipe lesson'**
  String get scanSwipeLesson;

  /// Notes swipe-lesson option subtitle
  ///
  /// In en, this message translates to:
  /// **'Cards and quick checks, added to the plan'**
  String get scanSwipeLessonSubtitle;

  /// Notes option / Pro fallback to save text only
  ///
  /// In en, this message translates to:
  /// **'Just keep the notes'**
  String get scanKeepNotes;

  /// Notes keep-text option subtitle
  ///
  /// In en, this message translates to:
  /// **'The text goes into the folder'**
  String get scanKeepNotesSubtitle;

  /// OCR waiting title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Reading your page…} other{Reading {count} pages…}}'**
  String scanReadingPages(int count);

  /// OCR waiting subtitle
  ///
  /// In en, this message translates to:
  /// **'This takes a few seconds.'**
  String get scanReadingWait;

  /// Notes save waiting title when making a lesson
  ///
  /// In en, this message translates to:
  /// **'Making your lesson…'**
  String get scanMakingLesson;

  /// Notes save waiting title for text-only save
  ///
  /// In en, this message translates to:
  /// **'Saving your notes…'**
  String get scanSavingNotes;

  /// Notes save waiting subtitle
  ///
  /// In en, this message translates to:
  /// **'It’ll be in your folder.'**
  String get scanSavingWait;

  /// Scan unavailable failure title
  ///
  /// In en, this message translates to:
  /// **'Scan isn’t ready yet'**
  String get scanFailUnavailableTitle;

  /// Scan unavailable failure body
  ///
  /// In en, this message translates to:
  /// **'Pebby can’t read photos right now. Try again later.'**
  String get scanFailUnavailableBody;

  /// Scan no-text failure title
  ///
  /// In en, this message translates to:
  /// **'No words here'**
  String get scanFailNoTextTitle;

  /// Scan no-text failure body
  ///
  /// In en, this message translates to:
  /// **'Point the camera at your homework, a textbook page or your notes.'**
  String get scanFailNoTextBody;

  /// Scan too-large failure title
  ///
  /// In en, this message translates to:
  /// **'Too many big photos'**
  String get scanFailTooLargeTitle;

  /// Scan too-large failure body
  ///
  /// In en, this message translates to:
  /// **'Try fewer pages at a time.'**
  String get scanFailTooLargeBody;

  /// Scan network failure title
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get scanFailNetworkTitle;

  /// Scan network failure body
  ///
  /// In en, this message translates to:
  /// **'Check your internet and try again.'**
  String get scanFailNetworkBody;

  /// Daily scan limit title
  ///
  /// In en, this message translates to:
  /// **'That’s today’s free scans'**
  String get scanFailScanLimitTitle;

  /// Daily scan limit body
  ///
  /// In en, this message translates to:
  /// **'They come back at midnight. Go Pro to scan as much as you like.'**
  String get scanFailScanLimitBody;

  /// Daily check limit title
  ///
  /// In en, this message translates to:
  /// **'That’s today’s free check'**
  String get scanFailCheckLimitTitle;

  /// Daily check limit body
  ///
  /// In en, this message translates to:
  /// **'It comes back at midnight. Go Pro to check every answer.'**
  String get scanFailCheckLimitBody;

  /// Pro-only lessons-from-notes title
  ///
  /// In en, this message translates to:
  /// **'Lessons from notes are Pro'**
  String get scanFailProOnlyTitle;

  /// Pro-only lessons-from-notes body
  ///
  /// In en, this message translates to:
  /// **'Keep your notes for free, or go Pro and Pebby makes them a lesson.'**
  String get scanFailProOnlyBody;

  /// Unknown scan failure title
  ///
  /// In en, this message translates to:
  /// **'Pebby couldn’t read that'**
  String get scanFailUnknownTitle;

  /// Unknown scan failure body
  ///
  /// In en, this message translates to:
  /// **'Try again, or retake the photo in better light.'**
  String get scanFailUnknownBody;

  /// Check-limit secondary action
  ///
  /// In en, this message translates to:
  /// **'Back to your answer'**
  String get scanBackToAnswer;

  /// Scan failure retake photo button
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get scanRetake;

  /// Snack when camera open fails at scan start
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the camera. Try the gallery.'**
  String get scanCameraOpenFailed;

  /// Solve/ask read review title
  ///
  /// In en, this message translates to:
  /// **'Pebby read this'**
  String get scanPebbyReadThis;

  /// Read review subtitle without chapter
  ///
  /// In en, this message translates to:
  /// **'Fix anything that’s wrong.'**
  String get scanFixAnything;

  /// Read review subtitle with chapter
  ///
  /// In en, this message translates to:
  /// **'{chapter} · fix anything that’s wrong.'**
  String scanChapterFix(String chapter);

  /// OCR text field label on read review
  ///
  /// In en, this message translates to:
  /// **'From your photo'**
  String get scanFromYourPhoto;

  /// Prefix when sending ask photo text to ASKMe
  ///
  /// In en, this message translates to:
  /// **'From my photo:'**
  String get scanFromMyPhoto;

  /// Ask-mode extra question field label
  ///
  /// In en, this message translates to:
  /// **'What do you want to know?'**
  String get scanWhatDoYouWant;

  /// Ask-mode suggestion chip and default question
  ///
  /// In en, this message translates to:
  /// **'Explain this simply'**
  String get scanSuggestExplain;

  /// Ask-mode suggestion chip
  ///
  /// In en, this message translates to:
  /// **'Summarise it'**
  String get scanSuggestSummarise;

  /// Ask-mode suggestion chip
  ///
  /// In en, this message translates to:
  /// **'What are the key terms?'**
  String get scanSuggestKeyTerms;

  /// Solve-mode primary action
  ///
  /// In en, this message translates to:
  /// **'Solve this'**
  String get scanSolveThis;

  /// Ask-mode / check-result Ask Pebby button
  ///
  /// In en, this message translates to:
  /// **'Ask Pebby'**
  String get scanAskPebby;

  /// Solve-mode caption under the primary button
  ///
  /// In en, this message translates to:
  /// **'Pebby gives you a hint first, then the steps.'**
  String get scanHintFirst;

  /// Check-mode read review title
  ///
  /// In en, this message translates to:
  /// **'Pebby read your answer'**
  String get checkPebbyReadAnswer;

  /// Check-mode question field label
  ///
  /// In en, this message translates to:
  /// **'The question'**
  String get checkTheQuestion;

  /// Check-mode question field hint
  ///
  /// In en, this message translates to:
  /// **'Only if it isn’t in the photo'**
  String get checkQuestionHint;

  /// Check-mode primary action
  ///
  /// In en, this message translates to:
  /// **'Mark it'**
  String get checkMarkIt;

  /// Check marking waiting title
  ///
  /// In en, this message translates to:
  /// **'Marking your answer…'**
  String get checkMarkingAnswer;

  /// Check marking waiting subtitle
  ///
  /// In en, this message translates to:
  /// **'Using the board’s marking scheme.'**
  String get checkMarkingScheme;

  /// Check result verdict when full marks
  ///
  /// In en, this message translates to:
  /// **'Full marks!'**
  String get checkFullMarks;

  /// Check result verdict when at least half marks
  ///
  /// In en, this message translates to:
  /// **'Nearly there'**
  String get checkNearlyThere;

  /// Check result verdict when under half marks
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get checkKeepGoing;

  /// Check result report sheet title
  ///
  /// In en, this message translates to:
  /// **'Report these marks'**
  String get checkReportTitle;

  /// Check result report thanks message
  ///
  /// In en, this message translates to:
  /// **'Thanks. We’ll review these marks.'**
  String get checkReportThanks;

  /// Check result marking points section title
  ///
  /// In en, this message translates to:
  /// **'What got marks'**
  String get checkWhatGotMarks;

  /// Check result remember box label on full marks
  ///
  /// In en, this message translates to:
  /// **'Well done'**
  String get checkWellDone;

  /// Check result remember box label when not full
  ///
  /// In en, this message translates to:
  /// **'For full marks'**
  String get checkForFullMarks;

  /// Check result primary retake action
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// Check result expand model answer
  ///
  /// In en, this message translates to:
  /// **'Show model answer'**
  String get checkShowModelAnswer;

  /// Check result collapse model answer
  ///
  /// In en, this message translates to:
  /// **'Hide model answer'**
  String get checkHideModelAnswer;

  /// ASKMe prompt line with the marked question
  ///
  /// In en, this message translates to:
  /// **'Question: {question}'**
  String checkAskQuestion(String question);

  /// ASKMe prompt block with the student’s answer
  ///
  /// In en, this message translates to:
  /// **'My answer:\n{answer}'**
  String checkAskMyAnswer(String answer);

  /// ASKMe prompt asking how to reach full marks
  ///
  /// In en, this message translates to:
  /// **'I got {awarded}/{marks}. How do I get full marks?'**
  String checkAskHowFullMarks(int awarded, int marks);

  /// Me settings Learning group title
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get meLearningSection;

  /// Me row opening Progress
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get meMyProgress;

  /// Me and ClassBoard screen title
  ///
  /// In en, this message translates to:
  /// **'Class and board'**
  String get meClassAndBoard;

  /// Me appearance row and screen title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get meAppearance;

  /// Me notifications group title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get meNotificationsSection;

  /// Me notifications row label
  ///
  /// In en, this message translates to:
  /// **'Reminders and daily goal'**
  String get meRemindersAndDailyGoal;

  /// Me account settings group title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get meAccountSection;

  /// Me account row and Account screen title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get meAccount;

  /// Me help row and Help screen title
  ///
  /// In en, this message translates to:
  /// **'Help and feedback'**
  String get meHelpAndFeedback;

  /// Me privacy row and Privacy screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy and terms'**
  String get mePrivacyAndTerms;

  /// Me log out button and confirm primary
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get meLogOut;

  /// Me log out button while running
  ///
  /// In en, this message translates to:
  /// **'Logging out…'**
  String get meLoggingOut;

  /// Me profile name when empty
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get meStudentFallback;

  /// Me stats streak caption
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get meDayStreak;

  /// Me stats level value
  ///
  /// In en, this message translates to:
  /// **'Lv {number}'**
  String meLevelValue(int number);

  /// Me stats XP to next level
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to Lv {level}'**
  String meXpToNextLevel(int xp, int level);

  /// Me stats XP caption
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get meXpLabel;

  /// Generic sheet confirm
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get meOk;

  /// Language sheet confirm when switching
  ///
  /// In en, this message translates to:
  /// **'OK · Switch to {name}'**
  String meOkSwitchTo(String name);

  /// Snack after language switch
  ///
  /// In en, this message translates to:
  /// **'{greeting} Pebby will now answer in {name}.'**
  String meLanguageSwitched(String greeting, String name);

  /// Snack when language switch fails
  ///
  /// In en, this message translates to:
  /// **'Couldn’t switch the language. Try again.'**
  String get meLanguageSwitchFailed;

  /// Fallback when url_launcher fails
  ///
  /// In en, this message translates to:
  /// **'Open {url} in your browser'**
  String meOpenInBrowser(String url);

  /// Unset class/board/stream value
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get meNotSet;

  /// Notifications row when study reminder is off
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get meOff;

  /// Syllabus chip without board
  ///
  /// In en, this message translates to:
  /// **'Class {level}'**
  String meClassOnly(int level);

  /// Syllabus chip with board code
  ///
  /// In en, this message translates to:
  /// **'Class {level} · {board}'**
  String meClassBoard(int level, String board);

  /// Log out confirmation sheet title
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get meLogOutTitle;

  /// Log out confirmation body
  ///
  /// In en, this message translates to:
  /// **'Your progress is saved to your account. Log in again any time.'**
  String get meLogOutBody;

  /// Log out sheet dismiss
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get meLogOutStay;

  /// Account screen save name button
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get accountSaveName;

  /// Account name save success snack
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get accountNameSaved;

  /// Account delete section title
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get accountDangerZone;

  /// Account delete row and delete button
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get accountDeleteMyAccount;

  /// Account delete grace period note
  ///
  /// In en, this message translates to:
  /// **'Your account is deleted 30 days after you ask. Log in before then to keep it.'**
  String get accountDeleteGraceNote;

  /// Account sign-in group title
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get accountSignIn;

  /// Password change row and screen title
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get accountChangePassword;

  /// Password set row and screen title
  ///
  /// In en, this message translates to:
  /// **'Set a password'**
  String get accountSetPassword;

  /// Link Google row label
  ///
  /// In en, this message translates to:
  /// **'Link Google'**
  String get accountLinkGoogle;

  /// Linked Google row label
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get accountGoogle;

  /// Google link in progress
  ///
  /// In en, this message translates to:
  /// **'Linking…'**
  String get accountLinking;

  /// Google unlink in progress
  ///
  /// In en, this message translates to:
  /// **'Unlinking…'**
  String get accountUnlinking;

  /// Google not linked value
  ///
  /// In en, this message translates to:
  /// **'Not linked'**
  String get accountNotLinked;

  /// Google link success snack
  ///
  /// In en, this message translates to:
  /// **'Google linked. You can log in with it now.'**
  String get accountGoogleLinked;

  /// Google unlink success snack
  ///
  /// In en, this message translates to:
  /// **'Google unlinked. Log in with your email and password.'**
  String get accountGoogleUnlinked;

  /// Unlink Google sheet title
  ///
  /// In en, this message translates to:
  /// **'Unlink Google?'**
  String get accountUnlinkGoogleTitle;

  /// Unlink Google sheet body
  ///
  /// In en, this message translates to:
  /// **'You won’t be able to log in with {email} any more. Use your email and password instead.'**
  String accountUnlinkGoogleBody(String email);

  /// Unlink sheet keep action
  ///
  /// In en, this message translates to:
  /// **'Keep Google'**
  String get accountKeepGoogle;

  /// Unlink sheet confirm
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get accountUnlink;

  /// Password screen save button
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get passwordSave;

  /// Change password explainer
  ///
  /// In en, this message translates to:
  /// **'Use the same rules as when you signed up. Other devices are logged out when you save.'**
  String get passwordChangeBody;

  /// Set password explainer
  ///
  /// In en, this message translates to:
  /// **'Add a password so you can also log in with your email, not just Google.'**
  String get passwordSetBody;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get passwordCurrent;

  /// Password change success snack
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices have been logged out.'**
  String get passwordChangedSnack;

  /// Password set success snack
  ///
  /// In en, this message translates to:
  /// **'Password set. You can now log in with your email too.'**
  String get passwordSetSnack;

  /// Delete account screen title
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// Delete account button while running
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleteDeleting;

  /// Delete account headline
  ///
  /// In en, this message translates to:
  /// **'We’re sorry to see you go'**
  String get deleteSorryTitle;

  /// Delete account body
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted in 30 days. Log in again before then to keep it. After 30 days your profile, chats, progress and XP are erased for good and can’t be brought back.'**
  String get deleteBody;

  /// Delete account subscription group
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get deleteSubscription;

  /// Pro subscription notice on delete
  ///
  /// In en, this message translates to:
  /// **'Deleting your account doesn’t cancel an ACADEMe Pro subscription bought on Google Play. Cancel it in Google Play so you aren’t charged again.'**
  String get deleteSubscriptionNotice;

  /// Open Play subscriptions row
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get deleteManageSubscription;

  /// Delete reason group title
  ///
  /// In en, this message translates to:
  /// **'Why are you leaving? (optional)'**
  String get deleteWhyLeaving;

  /// Delete confirm field label
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String deleteConfirmLabel(String word);

  /// Delete reason
  ///
  /// In en, this message translates to:
  /// **'I don’t use it enough'**
  String get deleteReasonNotEnough;

  /// Delete reason
  ///
  /// In en, this message translates to:
  /// **'It didn’t help with my studies'**
  String get deleteReasonDidntHelp;

  /// Delete reason
  ///
  /// In en, this message translates to:
  /// **'Too many notifications'**
  String get deleteReasonTooManyNotifs;

  /// Delete reason
  ///
  /// In en, this message translates to:
  /// **'I’m worried about my data'**
  String get deleteReasonDataWorry;

  /// Delete reason
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get deleteReasonOther;

  /// Snack after scheduling deletion
  ///
  /// In en, this message translates to:
  /// **'Your account will be deleted on {date}. Log in before then to keep it.'**
  String deleteScheduledSnack(String date);

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Reminders and goal'**
  String get notifRemindersAndGoalTitle;

  /// Study reminder group title
  ///
  /// In en, this message translates to:
  /// **'Study reminder'**
  String get notifStudyReminder;

  /// Study reminder switch
  ///
  /// In en, this message translates to:
  /// **'Remind me to study'**
  String get notifRemindMeToStudy;

  /// Reminder time group title
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get notifTime;

  /// Reminder time row
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get notifRemindMeAt;

  /// Extra notification toggles group
  ///
  /// In en, this message translates to:
  /// **'Also tell me'**
  String get notifAlsoTellMe;

  /// Streak save switch
  ///
  /// In en, this message translates to:
  /// **'When my streak is about to end'**
  String get notifStreakAboutToEnd;

  /// Test warning switch
  ///
  /// In en, this message translates to:
  /// **'The evening before a test'**
  String get notifEveningBeforeTest;

  /// Level-up celebration switch
  ///
  /// In en, this message translates to:
  /// **'When I level up'**
  String get notifWhenLevelUp;

  /// Notification access group and row
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifNotifications;

  /// Notifications allowed value
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get notifAllowed;

  /// Notifications not allowed value
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notifNotAllowed;

  /// Request notification permission
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notifTurnOn;

  /// Open system notification settings
  ///
  /// In en, this message translates to:
  /// **'Turn on in Settings'**
  String get notifTurnOnInSettings;

  /// Reminder time sheet title
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTimeTitle;

  /// Hour wheel semantics
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get reminderHour;

  /// Minute wheel semantics
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get reminderMinute;

  /// AM/PM wheel semantics
  ///
  /// In en, this message translates to:
  /// **'Morning or evening'**
  String get reminderAmPm;

  /// AM label
  ///
  /// In en, this message translates to:
  /// **'am'**
  String get reminderAm;

  /// PM label
  ///
  /// In en, this message translates to:
  /// **'pm'**
  String get reminderPm;

  /// Daily goal sheet and group title
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoalTitle;

  /// Daily goal sheet note
  ///
  /// In en, this message translates to:
  /// **'Today’s steps on Home will add up to about {minutes, plural, =1{1 minute} other{{minutes} minutes}}.'**
  String dailyGoalNote(int minutes);

  /// Daily goal wheel semantics
  ///
  /// In en, this message translates to:
  /// **'Daily goal in minutes'**
  String get dailyGoalSemantics;

  /// Daily goal wheel and row value
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String dailyGoalMinutesLabel(int minutes);

  /// Daily goal settings row
  ///
  /// In en, this message translates to:
  /// **'Study each day'**
  String get dailyGoalStudyEachDay;

  /// Appearance theme section caption
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get appearanceTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// Appearance dark mode hint
  ///
  /// In en, this message translates to:
  /// **'Dark mode is easier on your eyes at night.'**
  String get appearanceDarkHint;

  /// Appearance switch to dark headline
  ///
  /// In en, this message translates to:
  /// **'Lights off…'**
  String get appearanceLightsOff;

  /// Appearance switch to light headline
  ///
  /// In en, this message translates to:
  /// **'Good morning!'**
  String get appearanceGoodMorning;

  /// Appearance switch to dark subtitle
  ///
  /// In en, this message translates to:
  /// **'Pebby is dimming the room'**
  String get appearanceDimming;

  /// Appearance switch to light subtitle
  ///
  /// In en, this message translates to:
  /// **'Pebby is opening the curtains'**
  String get appearanceOpeningCurtains;

  /// Help categories group title
  ///
  /// In en, this message translates to:
  /// **'Tell us'**
  String get helpTellUs;

  /// Help email row
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get helpEmailUs;

  /// Feedback sent snack
  ///
  /// In en, this message translates to:
  /// **'Thanks, we got your message.'**
  String get helpThanks;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Report a wrong answer'**
  String get feedbackWrongAnswer;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Something isn’t working'**
  String get feedbackBug;

  /// Feedback category
  ///
  /// In en, this message translates to:
  /// **'Suggest a feature'**
  String get feedbackFeature;

  /// Feedback form hint
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened (at least 10 characters).'**
  String get feedbackHint;

  /// Feedback send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get feedbackSend;

  /// Feedback rate limit note
  ///
  /// In en, this message translates to:
  /// **'You can send up to 2 messages a day and 5 a week.'**
  String get feedbackLimitNote;

  /// Feedback generic failure
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send that. Try again.'**
  String get feedbackFailGeneric;

  /// Feedback day rate limit
  ///
  /// In en, this message translates to:
  /// **'You’ve sent the most feedback we can take today. Try again tomorrow.'**
  String get feedbackFailDay;

  /// Feedback week rate limit
  ///
  /// In en, this message translates to:
  /// **'You’ve sent the most feedback we can take this week. Try again next week.'**
  String get feedbackFailWeek;

  /// Feedback too short
  ///
  /// In en, this message translates to:
  /// **'Write at least 10 characters so we can help.'**
  String get feedbackFailTooShort;

  /// Feedback offline
  ///
  /// In en, this message translates to:
  /// **'You’re offline. Check your connection and try again.'**
  String get feedbackFailOffline;

  /// Privacy summary bullet 1
  ///
  /// In en, this message translates to:
  /// **'We keep your account, class, board and subjects, study progress and streak, folders, notes and chats with Pebby to run ACADEMe for you.'**
  String get privacySummary1;

  /// Privacy summary bullet 2
  ///
  /// In en, this message translates to:
  /// **'Your questions and scanned photos go to Sarvam AI in India so Pebby can answer. We don’t store your photos, only the text read from them.'**
  String get privacySummary2;

  /// Privacy summary bullet 3
  ///
  /// In en, this message translates to:
  /// **'No ads, no advertising ID, no location, and we never sell your data.'**
  String get privacySummary3;

  /// Privacy summary bullet 4
  ///
  /// In en, this message translates to:
  /// **'Delete your account any time in Account. Everything is erased after 30 days.'**
  String get privacySummary4;

  /// Privacy documents group
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get privacyDocuments;

  /// Privacy policy row
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Terms of use row
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get privacyTermsOfUse;

  /// Privacy your data group
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get privacyYourData;

  /// Data export row
  ///
  /// In en, this message translates to:
  /// **'Get a copy of my data'**
  String get privacyGetCopy;

  /// Grievance officer row
  ///
  /// In en, this message translates to:
  /// **'Grievance Officer'**
  String get privacyGrievanceOfficer;

  /// Class board save button
  ///
  /// In en, this message translates to:
  /// **'Save · Class {level} · {board}'**
  String classBoardSave(int level, String board);

  /// Class dial caption
  ///
  /// In en, this message translates to:
  /// **'Your class'**
  String get classBoardYourClass;

  /// Board picker caption
  ///
  /// In en, this message translates to:
  /// **'Your board'**
  String get classBoardYourBoard;

  /// Class board change notice
  ///
  /// In en, this message translates to:
  /// **'Your subjects and plan will switch to Class {level} · {board}. Everything you’ve done so far stays saved.'**
  String classBoardSwitchNote(int level, String board);

  /// Subjects settings group and row
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get classBoardSubjects;

  /// Stream settings row
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get classBoardStream;

  /// Subjects value when none filtered
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get classBoardAllSubjects;

  /// Subjects value with names
  ///
  /// In en, this message translates to:
  /// **'{count} · {names}'**
  String classBoardSubjectCount(int count, String names);

  /// Class board save success snack
  ///
  /// In en, this message translates to:
  /// **'Now showing Class {level} · {board} subjects'**
  String classBoardSavedSnack(int level, String board);

  /// Notification primer sheet title
  ///
  /// In en, this message translates to:
  /// **'Get a nudge before your test'**
  String get reminderPrimerTitle;

  /// Notification primer promise 1
  ///
  /// In en, this message translates to:
  /// **'A heads-up 3 days before, the evening before and the morning of each test'**
  String get reminderPrimerPromise1;

  /// Notification primer promise 2
  ///
  /// In en, this message translates to:
  /// **'Your study reminder, only on the days and time you pick'**
  String get reminderPrimerPromise2;

  /// Notification primer promise 3
  ///
  /// In en, this message translates to:
  /// **'Nothing else. Change it any time in Me'**
  String get reminderPrimerPromise3;

  /// Notification primer allow button
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get reminderPrimerAllow;

  /// Snack after successful Pro purchase
  ///
  /// In en, this message translates to:
  /// **'Welcome to ACADEMe Pro'**
  String get paywallWelcomeSnack;

  /// Paywall hero subtitle
  ///
  /// In en, this message translates to:
  /// **'3× daily & weekly limits. Same refill clock — more room to study.'**
  String get paywallTagline;

  /// Paywall purchase button while opening store
  ///
  /// In en, this message translates to:
  /// **'Opening Google Play…'**
  String get paywallOpeningPlay;

  /// Restore purchases in progress
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get paywallRestoring;

  /// Restore purchases action
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestore;

  /// Paywall when billing unavailable
  ///
  /// In en, this message translates to:
  /// **'Purchases aren’t available on this device'**
  String get paywallUnavailableTitle;

  /// Paywall unavailable hint
  ///
  /// In en, this message translates to:
  /// **'Install ACADEMe from Google Play and sign in to Play to go Pro.'**
  String get paywallUnavailableBody;

  /// Pro benefit ASKMe
  ///
  /// In en, this message translates to:
  /// **'3× ASKMe questions every day'**
  String get paywallBenefitAskme;

  /// Pro benefit Scan
  ///
  /// In en, this message translates to:
  /// **'3× scans every day'**
  String get paywallBenefitScan;

  /// Pro benefit Check
  ///
  /// In en, this message translates to:
  /// **'3× answer checks every day'**
  String get paywallBenefitCheck;

  /// Pro benefit lessons from notes
  ///
  /// In en, this message translates to:
  /// **'Swipe lessons made from your notes'**
  String get paywallBenefitLessons;

  /// Pro benefit progress
  ///
  /// In en, this message translates to:
  /// **'My Progress weekly study summary'**
  String get paywallBenefitProgress;

  /// Monthly plan title
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get paywallMonthly;

  /// Annual plan title
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get paywallAnnual;

  /// Plan tile semantics label
  ///
  /// In en, this message translates to:
  /// **'{title} plan'**
  String paywallPlanSemantics(String title);

  /// Monthly intro price line
  ///
  /// In en, this message translates to:
  /// **'{introPrice} for the first month, then {price}/month'**
  String paywallPriceIntroMonth(String introPrice, String price);

  /// Monthly price line
  ///
  /// In en, this message translates to:
  /// **'{price}/month'**
  String paywallPriceMonth(String price);

  /// Annual price line
  ///
  /// In en, this message translates to:
  /// **'{price}/year'**
  String paywallPriceYear(String price);

  /// Annual plan detail with monthly equivalent
  ///
  /// In en, this message translates to:
  /// **'About {monthlyPrice}/month · save 17% · renews automatically'**
  String paywallDetailAnnualMonthly(String monthlyPrice);

  /// Annual plan detail without monthly equivalent
  ///
  /// In en, this message translates to:
  /// **'Save 17% · renews automatically'**
  String get paywallDetailAnnual;

  /// Monthly plan renews detail
  ///
  /// In en, this message translates to:
  /// **'Renews automatically'**
  String get paywallDetailRenews;

  /// Annual best-value badge
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get paywallBestValue;

  /// Paywall legal small print
  ///
  /// In en, this message translates to:
  /// **'Renews automatically. Cancel anytime in Google Play.'**
  String get paywallSmallPrint;

  /// Terms link
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get paywallTerms;

  /// Privacy link
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get paywallPrivacy;

  /// Upgrade sheet and manage footer CTA
  ///
  /// In en, this message translates to:
  /// **'Go Pro · 3× limits'**
  String get upgradeTitle;

  /// ASKMe daily limit sheet title
  ///
  /// In en, this message translates to:
  /// **'That’s today’s free questions'**
  String get limitAskmeTitle;

  /// ASKMe daily limit sheet body
  ///
  /// In en, this message translates to:
  /// **'Free includes {count, plural, =1{1 ASKMe question} other{{count} ASKMe questions}} a day. Pro gives 3× every day.'**
  String limitAskmeBody(int count);

  /// Scan daily limit sheet title
  ///
  /// In en, this message translates to:
  /// **'That’s today’s free scans'**
  String get limitScanTitle;

  /// Scan daily limit sheet body
  ///
  /// In en, this message translates to:
  /// **'Free includes {count, plural, =1{1 scan} other{{count} scans}} a day. Pro gives 3× every day.'**
  String limitScanBody(int count);

  /// Check daily limit sheet title
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{That’s today’s free check} other{That’s today’s free checks}}'**
  String limitCheckTitle(int count);

  /// Check daily limit sheet body
  ///
  /// In en, this message translates to:
  /// **'Free includes {count, plural, =1{one answer check} other{{count} answer checks}} a day. Pro gives 3× every day.'**
  String limitCheckBody(int count);

  /// Lessons-from-notes Pro gate title
  ///
  /// In en, this message translates to:
  /// **'Lessons from notes are Pro'**
  String get limitLessonsTitle;

  /// Lessons-from-notes Pro gate body
  ///
  /// In en, this message translates to:
  /// **'Keeping your notes is free. With Pro, Pebby turns them into swipe lessons with quizzes.'**
  String get limitLessonsBody;

  /// Limit sheet dismiss
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get limitMaybeLater;

  /// Pro brand title
  ///
  /// In en, this message translates to:
  /// **'ACADEMe Pro'**
  String get proTitle;

  /// Manage screen title when free
  ///
  /// In en, this message translates to:
  /// **'Plan & limits'**
  String get proPlanLimitsTitle;

  /// Pro card subtitle for free users
  ///
  /// In en, this message translates to:
  /// **'Plan & limits · 3× with Pro'**
  String get proCardSubtitleFree;

  /// Pro card subtitle monthly
  ///
  /// In en, this message translates to:
  /// **'Pro · monthly'**
  String get proCardSubtitleMonthly;

  /// Pro card subtitle annual
  ///
  /// In en, this message translates to:
  /// **'Pro · annual'**
  String get proCardSubtitleAnnual;

  /// Pro card subtitle without period
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proCardSubtitlePro;

  /// Pro card manage action
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get proManage;

  /// Manage hero when Pro
  ///
  /// In en, this message translates to:
  /// **'You’re on Pro'**
  String get proOnPro;

  /// Manage hero when free
  ///
  /// In en, this message translates to:
  /// **'You’re on Free'**
  String get proOnFree;

  /// Manage hero meta free
  ///
  /// In en, this message translates to:
  /// **'Daily & weekly limits · 12:00 AM IST'**
  String get proMetaFree;

  /// Manage hero billing issue
  ///
  /// In en, this message translates to:
  /// **'Fix payment in Google Play to keep Pro'**
  String get proMetaBillingIssue;

  /// Manage hero Pro without expiry
  ///
  /// In en, this message translates to:
  /// **'3× daily limits · weekly safety cap'**
  String get proMetaActiveNoExpiry;

  /// Manage hero annual renewing
  ///
  /// In en, this message translates to:
  /// **'Annual · Renews {date} · 3× limits'**
  String proMetaAnnualRenews(String date);

  /// Manage hero monthly renewing
  ///
  /// In en, this message translates to:
  /// **'Monthly · Renews {date} · 3× limits'**
  String proMetaMonthlyRenews(String date);

  /// Manage hero Pro ending
  ///
  /// In en, this message translates to:
  /// **'Pro ends on {date}'**
  String proMetaEnds(String date);

  /// Pro status pill
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get proStatusActive;

  /// Free status pill
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get proStatusFree;

  /// Daily limits card heading
  ///
  /// In en, this message translates to:
  /// **'Daily limits'**
  String get proDailyLimits;

  /// Daily limits reset schedule
  ///
  /// In en, this message translates to:
  /// **'Resets every day at 12:00 AM IST'**
  String get proResetsDaily;

  /// ASKMe feature meter label
  ///
  /// In en, this message translates to:
  /// **'ASKMe'**
  String get proFeatureAskme;

  /// Scan feature meter label
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get proFeatureScan;

  /// Check feature meter label
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get proFeatureCheck;

  /// Lessons feature meter label
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get proFeatureLessons;

  /// Weekly limit card heading
  ///
  /// In en, this message translates to:
  /// **'Weekly limit'**
  String get proWeeklyLimit;

  /// Weekly reset when no date
  ///
  /// In en, this message translates to:
  /// **'Resets Mondays · 12:00 AM IST'**
  String get proResetsMondays;

  /// Weekly reset with day
  ///
  /// In en, this message translates to:
  /// **'Resets {day} · 12:00 AM IST'**
  String proResetsOnDay(String day);

  /// Weekly combined meter label
  ///
  /// In en, this message translates to:
  /// **'All features'**
  String get proAllFeatures;

  /// Manage subscription in Play
  ///
  /// In en, this message translates to:
  /// **'Manage in Google Play'**
  String get proManageInPlay;

  /// Reset chip when past due
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get proResetsSoon;

  /// Reset chip hours remaining
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 hour} other{in {count} hours}}'**
  String proResetsInHours(int count);

  /// Billing pending notice
  ///
  /// In en, this message translates to:
  /// **'Your payment is pending. Pro turns on as soon as Google Play confirms it.'**
  String get proNoticePending;

  /// Restore found nothing
  ///
  /// In en, this message translates to:
  /// **'No ACADEMe Pro purchase was found on this Google account.'**
  String get proNoticeNoPurchase;

  /// Billing not allowed
  ///
  /// In en, this message translates to:
  /// **'Purchases are turned off for this Google account.'**
  String get proNoticeNotAllowed;

  /// Billing already owned
  ///
  /// In en, this message translates to:
  /// **'This Google account already has Pro. Tap Restore purchases.'**
  String get proNoticeAlreadyOwned;

  /// Billing unavailable
  ///
  /// In en, this message translates to:
  /// **'Purchases aren’t available on this device.'**
  String get proNoticeUnavailable;

  /// Billing store error
  ///
  /// In en, this message translates to:
  /// **'Google Play couldn’t finish that. Try again.'**
  String get proNoticeStoreError;

  /// ASKMe header new-chat tooltip
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get askmeNewChat;

  /// ASKMe empty-state headline
  ///
  /// In en, this message translates to:
  /// **'What are we studying, {name}?'**
  String askmeStudying(String name);

  /// ASKMe empty explain mode line
  ///
  /// In en, this message translates to:
  /// **'Pebby explains it simply, step by step.'**
  String get askmeModeExplainLine;

  /// ASKMe empty solve mode line
  ///
  /// In en, this message translates to:
  /// **'Pebby gives hints. You solve it.'**
  String get askmeModeSolveLine;

  /// ASKMe empty quiz mode line
  ///
  /// In en, this message translates to:
  /// **'Pebby asks, you answer, you earn XP.'**
  String get askmeModeQuizLine;

  /// ASKMe explain suggestion 1
  ///
  /// In en, this message translates to:
  /// **'Explain reflection of light simply'**
  String get askmeSuggestExplain1;

  /// ASKMe explain suggestion 2
  ///
  /// In en, this message translates to:
  /// **'Why is the sky blue?'**
  String get askmeSuggestExplain2;

  /// ASKMe explain suggestion 3
  ///
  /// In en, this message translates to:
  /// **'What is photosynthesis?'**
  String get askmeSuggestExplain3;

  /// ASKMe solve suggestion 1
  ///
  /// In en, this message translates to:
  /// **'Help me solve 2x + 3y = 11 and x − 2y = −12'**
  String get askmeSuggestSolve1;

  /// ASKMe solve suggestion 2
  ///
  /// In en, this message translates to:
  /// **'Find the area of a circle with r = 7 cm'**
  String get askmeSuggestSolve2;

  /// ASKMe solve suggestion 3
  ///
  /// In en, this message translates to:
  /// **'Balance H₂ + O₂ → H₂O'**
  String get askmeSuggestSolve3;

  /// ASKMe quiz suggestion 1
  ///
  /// In en, this message translates to:
  /// **'Quiz me on Light'**
  String get askmeSuggestQuiz1;

  /// ASKMe quiz suggestion 2
  ///
  /// In en, this message translates to:
  /// **'Give me 5 questions on linear equations'**
  String get askmeSuggestQuiz2;

  /// ASKMe quiz suggestion 3
  ///
  /// In en, this message translates to:
  /// **'Quiz me on the French Revolution'**
  String get askmeSuggestQuiz3;

  /// ASKMe mode bar Explain
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get askmeModeExplain;

  /// ASKMe mode bar Solve
  ///
  /// In en, this message translates to:
  /// **'Solve'**
  String get askmeModeSolve;

  /// ASKMe mode bar Quiz me
  ///
  /// In en, this message translates to:
  /// **'Quiz me'**
  String get askmeModeQuiz;

  /// ASKMe solve follow-up chip
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get askmeFollowNextStep;

  /// ASKMe solve follow-up chip
  ///
  /// In en, this message translates to:
  /// **'Full solution'**
  String get askmeFollowFullSolution;

  /// ASKMe quiz follow-up chip
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get askmeFollowNextQuestion;

  /// ASKMe explain follow-up chip
  ///
  /// In en, this message translates to:
  /// **'Quiz me'**
  String get askmeFollowQuizMe;

  /// ASKMe explain follow-up chip
  ///
  /// In en, this message translates to:
  /// **'Go deeper'**
  String get askmeFollowGoDeeper;

  /// ASKMe solve follow-up send text
  ///
  /// In en, this message translates to:
  /// **'Next step, please.'**
  String get askmeSendNextStep;

  /// ASKMe solve follow-up send text
  ///
  /// In en, this message translates to:
  /// **'Show me the full solution.'**
  String get askmeSendFullSolution;

  /// ASKMe quiz follow-up send text
  ///
  /// In en, this message translates to:
  /// **'Next question.'**
  String get askmeSendNextQuestion;

  /// ASKMe explain follow-up send text
  ///
  /// In en, this message translates to:
  /// **'Go deeper.'**
  String get askmeSendGoDeeper;

  /// ASKMe explain quiz-me send text
  ///
  /// In en, this message translates to:
  /// **'Quiz me on this.'**
  String get askmeSendQuizMe;

  /// ASKMe send failure unavailable
  ///
  /// In en, this message translates to:
  /// **'ASKMe isn’t ready yet. Pebby will be here soon.'**
  String get askmeFailureUnavailable;

  /// ASKMe send failure signed out
  ///
  /// In en, this message translates to:
  /// **'You’ve been logged out. Log in again.'**
  String get askmeFailureSignedOut;

  /// ASKMe send failure limit
  ///
  /// In en, this message translates to:
  /// **'That’s all your free questions for today. They come back at midnight.'**
  String get askmeFailureLimitReached;

  /// ASKMe thinking bubble semantics
  ///
  /// In en, this message translates to:
  /// **'Pebby is thinking'**
  String get askmeThinking;

  /// ASKMe history screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// ASKMe history search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search your questions'**
  String get historySearchHint;

  /// ASKMe history load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your chats. Retry'**
  String get historyLoadError;

  /// ASKMe history empty
  ///
  /// In en, this message translates to:
  /// **'Your questions to Pebby will show up here.'**
  String get historyEmpty;

  /// ASKMe history section this week
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get historyThisWeek;

  /// ASKMe history section earlier
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get historyEarlier;

  /// ASKMe history relative now
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get historyNow;

  /// ASKMe history relative hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String historyHoursAgo(int hours);

  /// ASKMe history weekday Mon
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get historyWeekdayMon;

  /// ASKMe history weekday Tue
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get historyWeekdayTue;

  /// ASKMe history weekday Wed
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get historyWeekdayWed;

  /// ASKMe history weekday Thu
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get historyWeekdayThu;

  /// ASKMe history weekday Fri
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get historyWeekdayFri;

  /// ASKMe history weekday Sat
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get historyWeekdaySat;

  /// ASKMe history weekday Sun
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get historyWeekdaySun;

  /// ASKMe history month Jan
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get historyMonthJan;

  /// ASKMe history month Feb
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get historyMonthFeb;

  /// ASKMe history month Mar
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get historyMonthMar;

  /// ASKMe history month Apr
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get historyMonthApr;

  /// ASKMe history month May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get historyMonthMay;

  /// ASKMe history month Jun
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get historyMonthJun;

  /// ASKMe history month Jul
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get historyMonthJul;

  /// ASKMe history month Aug
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get historyMonthAug;

  /// ASKMe history month Sep
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get historyMonthSep;

  /// ASKMe history month Oct
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get historyMonthOct;

  /// ASKMe history month Nov
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get historyMonthNov;

  /// ASKMe history month Dec
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get historyMonthDec;

  /// ASKMe history day+month
  ///
  /// In en, this message translates to:
  /// **'{day} {month}'**
  String historyDayMonth(int day, String month);

  /// Attach sheet title
  ///
  /// In en, this message translates to:
  /// **'Add to your question'**
  String get attachTitle;

  /// Attach sheet camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// Attach sheet photos option
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get attachPhotos;

  /// Reply action helpful tooltip
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get replyHelpful;

  /// Reply action not helpful tooltip
  ///
  /// In en, this message translates to:
  /// **'Not helpful'**
  String get replyNotHelpful;

  /// Reply action copy tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get replyCopy;

  /// Reply copied snackbar
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get replyCopied;

  /// Reply report sheet title
  ///
  /// In en, this message translates to:
  /// **'Report this answer'**
  String get replyReportTitle;

  /// Reply report thanks snackbar
  ///
  /// In en, this message translates to:
  /// **'Thanks. We’ll review this answer.'**
  String get replyReportThanks;

  /// Report button tooltip
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTooltip;

  /// Report send failure snackbar
  ///
  /// In en, this message translates to:
  /// **'Couldn’t send the report. Try again.'**
  String get reportSendFailed;

  /// Report sheet body
  ///
  /// In en, this message translates to:
  /// **'We read every report and use it to make Pebby safer.'**
  String get reportBody;

  /// Report reason wrong
  ///
  /// In en, this message translates to:
  /// **'It’s wrong'**
  String get reportReasonWrong;

  /// Report reason harmful
  ///
  /// In en, this message translates to:
  /// **'It’s harmful or unsafe'**
  String get reportReasonHarmful;

  /// Report reason offensive
  ///
  /// In en, this message translates to:
  /// **'It’s rude or offensive'**
  String get reportReasonOffensive;

  /// Report reason other
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// Progress screen app bar
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get progressTitle;

  /// Progress loading line
  ///
  /// In en, this message translates to:
  /// **'Loading this week…'**
  String get progressLoading;

  /// Progress load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this week’s summary.'**
  String get progressLoadError;

  /// Progress Pro hold title
  ///
  /// In en, this message translates to:
  /// **'My Progress is part of Pro'**
  String get progressHoldTitle;

  /// Progress Pro hold body
  ///
  /// In en, this message translates to:
  /// **'See streak, level and study insights with ACADEMe Pro.'**
  String get progressHoldBody;

  /// Progress Pro hold CTA
  ///
  /// In en, this message translates to:
  /// **'Go Pro · 3× limits'**
  String get progressGoProLimits;

  /// Progress study days card title
  ///
  /// In en, this message translates to:
  /// **'Study days'**
  String get progressStudyDays;

  /// Progress this week chip
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get progressThisWeek;

  /// Progress today studied
  ///
  /// In en, this message translates to:
  /// **'Today · studied'**
  String get progressTodayStudied;

  /// Progress today not yet
  ///
  /// In en, this message translates to:
  /// **'Today · not yet'**
  String get progressTodayNotYet;

  /// Progress board tab summary
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get progressTabSummary;

  /// Progress board tab progress
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTabProgress;

  /// Progress board tab activity
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get progressTabActivity;

  /// Progress summary subjects stat
  ///
  /// In en, this message translates to:
  /// **'Subjects this week'**
  String get progressSubjectsThisWeek;

  /// Progress summary completed stat
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get progressCompleted;

  /// Progress overall grade label
  ///
  /// In en, this message translates to:
  /// **'Overall grade'**
  String get progressOverallGrade;

  /// Progress grade ring with grade
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get progressKeepItUp;

  /// Progress grade ring without grade
  ///
  /// In en, this message translates to:
  /// **'Start your journey'**
  String get progressStartJourney;

  /// Progress pane empty title
  ///
  /// In en, this message translates to:
  /// **'Course progress'**
  String get progressCourseProgress;

  /// Progress pane empty body
  ///
  /// In en, this message translates to:
  /// **'Lessons you finish will show up here.'**
  String get progressLessonsEmpty;

  /// Progress subject lesson row
  ///
  /// In en, this message translates to:
  /// **'{name}: {count, plural, =1{1 lesson} other{{count} lessons}}'**
  String progressSubjectLessons(String name, int count);

  /// Progress activity pane title
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get progressActivity;

  /// Progress activity empty
  ///
  /// In en, this message translates to:
  /// **'Your study days will show up here.'**
  String get progressStudyDaysEmpty;

  /// Progress activity count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day this week.} other{{count} active days this week.}}'**
  String progressActiveDays(int count);

  /// Progress gold CTA empty
  ///
  /// In en, this message translates to:
  /// **'It’s time to start your journey!'**
  String get progressCtaStart;

  /// Progress gold CTA with grade
  ///
  /// In en, this message translates to:
  /// **'Keep your momentum going'**
  String get progressCtaMomentum;

  /// Progress gold CTA building
  ///
  /// In en, this message translates to:
  /// **'You’re building a habit'**
  String get progressCtaHabit;

  /// Progress gold CTA subtitle
  ///
  /// In en, this message translates to:
  /// **'See what to do next'**
  String get progressCtaNext;

  /// Progress next steps sheet title
  ///
  /// In en, this message translates to:
  /// **'Next steps'**
  String get progressNextSteps;

  /// Progress next steps setup section
  ///
  /// In en, this message translates to:
  /// **'Your setup'**
  String get progressYourSetup;

  /// Progress next steps advice section
  ///
  /// In en, this message translates to:
  /// **'What to do next'**
  String get progressWhatNext;

  /// Progress next steps with study
  ///
  /// In en, this message translates to:
  /// **'Keep finishing lessons this week. Your grade updates when you complete them.'**
  String get progressNextWithStudy;

  /// Progress next steps without study
  ///
  /// In en, this message translates to:
  /// **'On Me, confirm class and board. Then open Study and finish your first lesson.'**
  String get progressNextNoStudy;

  /// Progress week line empty
  ///
  /// In en, this message translates to:
  /// **'No study logged this week yet.'**
  String get progressWeekEmpty;

  /// Progress week line active days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active day} other{{count} active days}}'**
  String progressWeekActiveDays(int count);

  /// Progress week line lessons
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String progressWeekLessons(int count);

  /// Progress week line chapter tests
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter test} other{{count} chapter tests}}'**
  String progressWeekChapterTests(int count);

  /// Progress week line XP
  ///
  /// In en, this message translates to:
  /// **'{count} XP'**
  String progressWeekXp(int count);

  /// Progress week line summary
  ///
  /// In en, this message translates to:
  /// **'This week: {parts}.'**
  String progressWeekSummary(String parts);

  /// Progress weekday initial Mon
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get progressWeekdayMon;

  /// Progress weekday initial Tue
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressWeekdayTue;

  /// Progress weekday initial Wed
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get progressWeekdayWed;

  /// Progress weekday initial Thu
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get progressWeekdayThu;

  /// Progress weekday initial Fri
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get progressWeekdayFri;

  /// Progress weekday initial Sat
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressWeekdaySat;

  /// Progress weekday initial Sun
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get progressWeekdaySun;

  /// Subjects sheet stream title
  ///
  /// In en, this message translates to:
  /// **'Your stream'**
  String get subjectsStreamTitle;

  /// Subjects sheet save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get subjectsSave;

  /// Subjects picker load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your subjects. Retry'**
  String get subjectsLoadError;

  /// Subjects picker main label
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get subjectsMain;

  /// Subjects picker optional label
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get subjectsOptional;

  /// Stream cards swipe hint
  ///
  /// In en, this message translates to:
  /// **'Swipe for {name}. Change it any time in Me.'**
  String streamSwipeFor(String name);

  /// Stream cards last-card hint
  ///
  /// In en, this message translates to:
  /// **'Change it any time in Me.'**
  String get streamChangeInMe;

  /// Subjects sheet choose stream button
  ///
  /// In en, this message translates to:
  /// **'Choose {name}'**
  String streamChoose(String name);

  /// Class dial center label
  ///
  /// In en, this message translates to:
  /// **'CLASS'**
  String get classDialLabel;

  /// Class dial semantics
  ///
  /// In en, this message translates to:
  /// **'Class {level}'**
  String classDialSemantics(int level);

  /// Study tab screen title
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get studyTitle;

  /// Study Courses tab
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get studyCourses;

  /// Study Folders tab
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get studyFolders;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get studyDone;

  /// Keep dialog action / card tool
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get studyKeep;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get studyDelete;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get studySave;

  /// Create folder action
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get studyCreate;

  /// Add tooltip
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get studyAdd;

  /// Optional field hint
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get studyOptional;

  /// Folder name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get studyName;

  /// Today section / due today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get studyToday;

  /// Coming soon label
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get studyComingSoon;

  /// XP stat label
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get studyXp;

  /// Chapter abbreviation row title
  ///
  /// In en, this message translates to:
  /// **'Ch {number} · {title}'**
  String studyChTitle(int number, String title);

  /// Lessons completed of total
  ///
  /// In en, this message translates to:
  /// **'{done} of {count, plural, =1{1 lesson} other{{count} lessons}} done'**
  String studyLessonsDoneOf(int done, int count);

  /// Count of coming-soon lessons
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 coming soon} other{{count} coming soon}}'**
  String studyComingSoonCount(int count);

  /// Formative-only chapter note
  ///
  /// In en, this message translates to:
  /// **'Not in board exam'**
  String get studyNotInBoardExam;

  /// Card count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String studyCardsCount(int count);

  /// Quick check count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 quick check} other{{count} quick checks}}'**
  String studyQuickChecksCount(int count);

  /// Question count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String studyQuestionsCount(int count);

  /// Chapter count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chapter} other{{count} chapters}}'**
  String studyChaptersCount(int count);

  /// Lesson count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String studyLessonsCount(int count);

  /// Short minutes label
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String studyMinutesShort(int minutes);

  /// Approx lesson duration
  ///
  /// In en, this message translates to:
  /// **'about {minutes} min'**
  String studyAboutMinutes(int minutes);

  /// Courses empty without syllabus
  ///
  /// In en, this message translates to:
  /// **'Set your class and board on Home to see your courses.'**
  String get coursesNeedSyllabus;

  /// Courses load failure
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your courses. Retry'**
  String get coursesLoadError;

  /// Courses empty for syllabus
  ///
  /// In en, this message translates to:
  /// **'Lessons for {syllabus} are on their way. Ask Pebby anything in ASKMe meanwhile.'**
  String coursesComingSoon(String syllabus);

  /// Filtered courses empty
  ///
  /// In en, this message translates to:
  /// **'No chapters match these filters.'**
  String get coursesNoFilterMatch;

  /// Done filter empty
  ///
  /// In en, this message translates to:
  /// **'Finished chapters show up here.'**
  String get coursesFinishedEmpty;

  /// In-progress filter empty
  ///
  /// In en, this message translates to:
  /// **'Chapters you’ve started show up here.'**
  String get coursesStartedEmpty;

  /// Continue key when lesson done
  ///
  /// In en, this message translates to:
  /// **'Go again'**
  String get coursesGoAgain;

  /// Continue key resume
  ///
  /// In en, this message translates to:
  /// **'Continue · card {current} of {total}'**
  String coursesContinueCard(int current, int total);

  /// Continue key start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get coursesStart;

  /// Chapter status filter All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Chapter status filter In progress
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get filterInProgress;

  /// Chapter status filter Done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get filterDone;

  /// Filters button and sheet title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterFilters;

  /// Filters semantics when active
  ///
  /// In en, this message translates to:
  /// **'Filters, {count} on'**
  String filterFiltersOn(int count);

  /// Clear filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filterClear;

  /// Sort section header
  ///
  /// In en, this message translates to:
  /// **'SORT'**
  String get filterSort;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Show {count, plural, =1{1 chapter} other{{count} chapters}}'**
  String filterShowChapters(int count);

  /// Board exam filter title
  ///
  /// In en, this message translates to:
  /// **'Board exam only'**
  String get filterBoardExamOnly;

  /// Board exam filter subtitle
  ///
  /// In en, this message translates to:
  /// **'Hide school-assessed chapters'**
  String get filterBoardExamOnlyDesc;

  /// Ready filter title
  ///
  /// In en, this message translates to:
  /// **'Ready to study'**
  String get filterReadyToStudy;

  /// Ready filter subtitle
  ///
  /// In en, this message translates to:
  /// **'Hide chapters still coming soon'**
  String get filterReadyToStudyDesc;

  /// Revision due filter title
  ///
  /// In en, this message translates to:
  /// **'Revision due'**
  String get filterRevisionDue;

  /// Revision due filter subtitle
  ///
  /// In en, this message translates to:
  /// **'Chapters with kept cards to revise'**
  String get filterRevisionDueDesc;

  /// Sort by textbook order
  ///
  /// In en, this message translates to:
  /// **'Textbook'**
  String get filterSortTextbook;

  /// Sort by marks
  ///
  /// In en, this message translates to:
  /// **'Most marks'**
  String get filterSortMostMarks;

  /// Sort by recent
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get filterSortRecent;

  /// Active chip board exam
  ///
  /// In en, this message translates to:
  /// **'Board exam'**
  String get filterFlagBoardExam;

  /// Active chip ready
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get filterFlagReady;

  /// Active chip revision due
  ///
  /// In en, this message translates to:
  /// **'Revision due'**
  String get filterFlagRevisionDue;

  /// Remove filter chip semantics
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String filterRemove(String label);

  /// New folder button
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get folderNew;

  /// Edit folder sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit folder'**
  String get folderEdit;

  /// Folders empty state
  ///
  /// In en, this message translates to:
  /// **'Make a folder for a test, your homework, or anything you’re preparing. Add a date and it plans your days.'**
  String get folderEmptyHint;

  /// Empty folder tile subtitle
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get folderEmpty;

  /// Folder tile when caught up
  ///
  /// In en, this message translates to:
  /// **'Nothing left today'**
  String get folderNothingLeftToday;

  /// Folder tile todos left
  ///
  /// In en, this message translates to:
  /// **'{count} to do today'**
  String folderTodoToday(int count);

  /// Folder header without due date
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get folderNoDate;

  /// Folder progress
  ///
  /// In en, this message translates to:
  /// **'{percent}% ready'**
  String folderPercentReady(int percent);

  /// Empty folder title
  ///
  /// In en, this message translates to:
  /// **'What’s this folder for?'**
  String get folderWhatsFor;

  /// Empty folder subtitle
  ///
  /// In en, this message translates to:
  /// **'Add chapters and Pebby plans your days.'**
  String get folderAddChaptersPlan;

  /// Add chapters action
  ///
  /// In en, this message translates to:
  /// **'Add chapters'**
  String get folderAddChapters;

  /// Add chapters subtitle
  ///
  /// In en, this message translates to:
  /// **'From your syllabus'**
  String get folderFromSyllabus;

  /// Write note action
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get folderWriteNote;

  /// Write note subtitle
  ///
  /// In en, this message translates to:
  /// **'Anything you want to remember'**
  String get folderNoteSubtitle;

  /// Scan notes action
  ///
  /// In en, this message translates to:
  /// **'Scan notes'**
  String get folderScanNotes;

  /// Scan notes subtitle
  ///
  /// In en, this message translates to:
  /// **'Photos of pages, made into a lesson'**
  String get folderScanNotesSubtitle;

  /// Todo field hint
  ///
  /// In en, this message translates to:
  /// **'Add a to-do'**
  String get folderAddTodo;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a date'**
  String get folderAddDate;

  /// Remove due date tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove date'**
  String get folderRemoveDate;

  /// Folder reminders switch
  ///
  /// In en, this message translates to:
  /// **'Reminders for this folder'**
  String get folderReminders;

  /// Delete folder dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete this folder?'**
  String get folderDeleteTitle;

  /// Delete folder dialog body
  ///
  /// In en, this message translates to:
  /// **'Its notes and to-dos go too. Your lessons and progress stay.'**
  String get folderDeleteBody;

  /// Folder screen title
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folderTitle;

  /// Folder edit tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit and reminders'**
  String get folderEditRemindersTooltip;

  /// Folder delete tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get folderDeleteTooltip;

  /// Folder load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this folder. Retry'**
  String get folderLoadError;

  /// Folder today with minutes
  ///
  /// In en, this message translates to:
  /// **'Today · {minutes} min'**
  String folderTodayMinutes(int minutes);

  /// Open plan button
  ///
  /// In en, this message translates to:
  /// **'See plan'**
  String get folderSeePlan;

  /// Empty today no due
  ///
  /// In en, this message translates to:
  /// **'Add chapters or to-dos.'**
  String get folderAddChaptersOrTodos;

  /// Empty today with content
  ///
  /// In en, this message translates to:
  /// **'Nothing left for today.'**
  String get folderNothingLeftForToday;

  /// Folder contents section
  ///
  /// In en, this message translates to:
  /// **'In this folder'**
  String get folderInThisFolder;

  /// Notes lesson done
  ///
  /// In en, this message translates to:
  /// **'From your notes · done'**
  String get folderFromNotesDone;

  /// Notes lesson duration
  ///
  /// In en, this message translates to:
  /// **'From your notes · {minutes} min'**
  String folderFromNotesMinutes(int minutes);

  /// Note item subtitle
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get folderNote;

  /// Note sheet action
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get folderSaveNote;

  /// Note sheet hint
  ///
  /// In en, this message translates to:
  /// **'Type here…'**
  String get folderTypeHere;

  /// Folder picker title / chapter action
  ///
  /// In en, this message translates to:
  /// **'Add to a folder'**
  String get folderAddTo;

  /// Create folder error snackbar
  ///
  /// In en, this message translates to:
  /// **'Couldn’t make the folder. Try again.'**
  String get folderCouldntMake;

  /// Added chapters snackbar
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String folderAddedTo(String name);

  /// Fallback folder name
  ///
  /// In en, this message translates to:
  /// **'your folder'**
  String get folderYourFolder;

  /// Plan screen without due
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get folderPlan;

  /// Plan screen with due
  ///
  /// In en, this message translates to:
  /// **'Plan to {date}'**
  String folderPlanTo(String date);

  /// Plan screen explainer
  ///
  /// In en, this message translates to:
  /// **'Made from the chapters in this folder. Missed something? It moves to the next day on its own.'**
  String get folderPlanBody;

  /// Plan due day line
  ///
  /// In en, this message translates to:
  /// **'Test day · you’re ready'**
  String get folderTestDay;

  /// Plan rest day
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get folderRestDay;

  /// Due tomorrow
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get folderDueTomorrow;

  /// Due yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get folderDueYesterday;

  /// Due days ago
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}} ago'**
  String folderDueDaysAgo(int count);

  /// Due in days
  ///
  /// In en, this message translates to:
  /// **'in {count, plural, =1{1 day} other{{count} days}}'**
  String folderDueInDays(int count);

  /// Chapter screen title
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapterTitle(int number);

  /// Lessons section title
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get chapterLessons;

  /// Chapter test row
  ///
  /// In en, this message translates to:
  /// **'Chapter test'**
  String get chapterTest;

  /// Chapter test with prior score
  ///
  /// In en, this message translates to:
  /// **'Last time {correct}/{total} · try again'**
  String chapterTestLast(int correct, int total);

  /// Chapter test empty result
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}} from every lesson'**
  String chapterTestSubtitle(int count);

  /// Kept cards row
  ///
  /// In en, this message translates to:
  /// **'Kept cards'**
  String get chapterKeptCards;

  /// Kept cards empty
  ///
  /// In en, this message translates to:
  /// **'Tap Keep on any card to save it here'**
  String get chapterKeptEmpty;

  /// Kept cards count
  ///
  /// In en, this message translates to:
  /// **'{count} to revise'**
  String chapterKeptCount(int count);

  /// Chapter resume when done
  ///
  /// In en, this message translates to:
  /// **'All lessons done · go again'**
  String get chapterAllDoneGoAgain;

  /// Chapter resume mid-lesson
  ///
  /// In en, this message translates to:
  /// **'Resume · card {current} of {total}'**
  String chapterResumeCard(int current, int total);

  /// Chapter resume next
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get chapterNextLesson;

  /// Resume key subtitle
  ///
  /// In en, this message translates to:
  /// **'Lesson {position} · {cards}'**
  String chapterLessonMeta(int position, String cards);

  /// Done lesson row subtitle
  ///
  /// In en, this message translates to:
  /// **'{cards} · {correct}/{quizzes} right'**
  String chapterCardsRight(String cards, int correct, int quizzes);

  /// Lesson row subtitle
  ///
  /// In en, this message translates to:
  /// **'{cards} · {checks}'**
  String chapterCardsChecks(String cards, String checks);

  /// Coming soon with planned lessons
  ///
  /// In en, this message translates to:
  /// **'Coming soon · {lessons}'**
  String chapterComingSoonLessons(String lessons);

  /// Chapter done awaiting test
  ///
  /// In en, this message translates to:
  /// **'Lessons done · test next'**
  String get chapterLessonsDoneTestNext;

  /// Chapter done with test score
  ///
  /// In en, this message translates to:
  /// **'Done · test {percent}%'**
  String chapterDoneTestPercent(int percent);

  /// Suffix for partial coming soon
  ///
  /// In en, this message translates to:
  /// **' · {count} coming soon'**
  String chapterComingSoonSuffix(int count);

  /// Formative suffix
  ///
  /// In en, this message translates to:
  /// **' · Not in board exam'**
  String get chapterNotInBoardExamSuffix;

  /// Chapter report high score
  ///
  /// In en, this message translates to:
  /// **'Great work'**
  String get chapterReportGreat;

  /// Chapter report mid score
  ///
  /// In en, this message translates to:
  /// **'Good going'**
  String get chapterReportGood;

  /// Chapter report low score
  ///
  /// In en, this message translates to:
  /// **'Worth another go'**
  String get chapterReportRetry;

  /// Chapter report section
  ///
  /// In en, this message translates to:
  /// **'By lesson'**
  String get chapterReportByLesson;

  /// Chapter report subtitle
  ///
  /// In en, this message translates to:
  /// **'{title} · +{xp} XP'**
  String chapterReportXp(String title, int xp);

  /// Chapter report revise
  ///
  /// In en, this message translates to:
  /// **'Revise what you missed'**
  String get chapterReviseMissed;

  /// Chapter report add folder
  ///
  /// In en, this message translates to:
  /// **'Add chapter to a folder'**
  String get chapterAddToFolderAction;

  /// Back to chapter button
  ///
  /// In en, this message translates to:
  /// **'Back to chapter'**
  String get chapterBackToChapter;

  /// Add chapters empty
  ///
  /// In en, this message translates to:
  /// **'No chapters for your class yet.'**
  String get chapterNoChaptersYet;

  /// Chapter already added
  ///
  /// In en, this message translates to:
  /// **'Already in this folder'**
  String get chapterAlreadyInFolder;

  /// Add chapters subtitle
  ///
  /// In en, this message translates to:
  /// **'{lessons} · {done} done'**
  String chapterLessonsDoneShort(String lessons, int done);

  /// Add chapters empty pick
  ///
  /// In en, this message translates to:
  /// **'Pick chapters'**
  String get chapterPickChapters;

  /// Add chapters confirm
  ///
  /// In en, this message translates to:
  /// **'Add {count, plural, =1{1 chapter} other{{count} chapters}}'**
  String chapterAddCount(int count);

  /// Add chapters screen title
  ///
  /// In en, this message translates to:
  /// **'Add chapters'**
  String get chapterAddChaptersTitle;

  /// Report lesson sheet title
  ///
  /// In en, this message translates to:
  /// **'Report this lesson'**
  String get deckReportTitle;

  /// Report lesson thanks
  ///
  /// In en, this message translates to:
  /// **'Thanks. We’ll review this lesson.'**
  String get deckReportThanks;

  /// Deck load error
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load this lesson. Retry'**
  String get deckLoadError;

  /// Perfect lesson done
  ///
  /// In en, this message translates to:
  /// **'Perfect lesson!'**
  String get deckPerfect;

  /// Lesson done title
  ///
  /// In en, this message translates to:
  /// **'Lesson done!'**
  String get deckLessonDone;

  /// Correct answers stat
  ///
  /// In en, this message translates to:
  /// **'right'**
  String get deckStatRight;

  /// Kept cards stat
  ///
  /// In en, this message translates to:
  /// **'kept'**
  String get deckStatKept;

  /// Next lesson button
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String deckNextTitle(String title);

  /// Deck start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get deckStart;

  /// Reveal example step
  ///
  /// In en, this message translates to:
  /// **'Show step {step}'**
  String deckShowStep(int step);

  /// Check answer button
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get deckCheck;

  /// Next card button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get deckNext;

  /// Finish deck button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get deckFinish;

  /// Previous card semantics
  ///
  /// In en, this message translates to:
  /// **'Previous card'**
  String get deckPreviousCard;

  /// Start card kicker
  ///
  /// In en, this message translates to:
  /// **'New lesson'**
  String get deckNewLesson;

  /// Start card goals intro
  ///
  /// In en, this message translates to:
  /// **'By the end you can:'**
  String get deckByTheEnd;

  /// Start card meta
  ///
  /// In en, this message translates to:
  /// **'{cards} · {checks} · about {minutes} min'**
  String deckMetaLine(String cards, String checks, int minutes);

  /// Concept card kicker
  ///
  /// In en, this message translates to:
  /// **'Concept'**
  String get deckConcept;

  /// Table card kicker
  ///
  /// In en, this message translates to:
  /// **'In one look'**
  String get deckInOneLook;

  /// Summary card kicker
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get deckSummary;

  /// Summary card title
  ///
  /// In en, this message translates to:
  /// **'The lesson in three lines'**
  String get deckThreeLines;

  /// Summary kept box label
  ///
  /// In en, this message translates to:
  /// **'Kept for revision'**
  String get deckKeptForRevision;

  /// Summary kept one card
  ///
  /// In en, this message translates to:
  /// **'1 card from this lesson comes back in your revision.'**
  String get deckKeptRevisionOne;

  /// Summary kept many cards
  ///
  /// In en, this message translates to:
  /// **'{count} cards from this lesson come back in your revision.'**
  String deckKeptRevisionMany(int count);

  /// Example card kicker
  ///
  /// In en, this message translates to:
  /// **'Worked example'**
  String get deckWorkedExample;

  /// Hidden example step
  ///
  /// In en, this message translates to:
  /// **'Step {step} · try it first'**
  String deckStepTryFirst(int step);

  /// Remember box default label
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get deckRemember;

  /// Card kept tool on
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get deckKept;

  /// Ask Pebby tool
  ///
  /// In en, this message translates to:
  /// **'Ask Pebby'**
  String get deckAskPebby;

  /// Ask prompt concept
  ///
  /// In en, this message translates to:
  /// **'Can you explain this more simply? {title}: {body}'**
  String deckAskExplainSimply(String title, String body);

  /// Ask prompt table
  ///
  /// In en, this message translates to:
  /// **'Can you explain \"{title}\" with an example?'**
  String deckAskExplainExample(String title);

  /// Ask prompt example
  ///
  /// In en, this message translates to:
  /// **'Can you explain how to solve: {question}'**
  String deckAskExplainSolve(String question);

  /// Ask prompt quiz
  ///
  /// In en, this message translates to:
  /// **'I got this wrong: {question} Why is it: {why}'**
  String deckAskWrongWhy(String question, String why);

  /// Ask prompt fallback
  ///
  /// In en, this message translates to:
  /// **'Can you explain this lesson?'**
  String get deckAskExplainLesson;

  /// Review start-card front
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get deckGoals;

  /// Quiz card kicker
  ///
  /// In en, this message translates to:
  /// **'Quick check'**
  String get quizQuickCheck;

  /// Chapter test question kicker
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionOf(int current, int total);

  /// Quiz praise 1
  ///
  /// In en, this message translates to:
  /// **'Nice! That’s right.'**
  String get quizPraise1;

  /// Quiz praise 2
  ///
  /// In en, this message translates to:
  /// **'Spot on!'**
  String get quizPraise2;

  /// Quiz praise 3
  ///
  /// In en, this message translates to:
  /// **'You got it!'**
  String get quizPraise3;

  /// Quiz praise 4
  ///
  /// In en, this message translates to:
  /// **'Correct, well done!'**
  String get quizPraise4;

  /// Quiz praise 5
  ///
  /// In en, this message translates to:
  /// **'Exactly right!'**
  String get quizPraise5;

  /// Why card kicker
  ///
  /// In en, this message translates to:
  /// **'Here’s why'**
  String get quizHeresWhy;

  /// Wrong option note
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get quizYourAnswer;

  /// Correct option note
  ///
  /// In en, this message translates to:
  /// **'Right answer'**
  String get quizRightAnswer;

  /// Why card remember label
  ///
  /// In en, this message translates to:
  /// **'Kept for you'**
  String get quizKeptForYou;

  /// Why card remember body
  ///
  /// In en, this message translates to:
  /// **'This question comes back in your revision tomorrow.'**
  String get quizComesBack;

  /// Wrong answer feedback
  ///
  /// In en, this message translates to:
  /// **'Not quite. Next: why.'**
  String get quizNotQuite;

  /// Streak chip
  ///
  /// In en, this message translates to:
  /// **'{count} in a row'**
  String quizStreak(int count);

  /// XP chip
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String quizXpTag(int xp);

  /// Revision screen title
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get studyRevision;

  /// Revision empty title
  ///
  /// In en, this message translates to:
  /// **'Nothing to revise'**
  String get studyRevisionEmptyTitle;

  /// Revision empty body
  ///
  /// In en, this message translates to:
  /// **'Keep cards in a lesson, or miss a question, and they come back here.'**
  String get studyRevisionEmptyBody;

  /// Revision finished title
  ///
  /// In en, this message translates to:
  /// **'Revision done'**
  String get studyRevisionDone;

  /// Revision finished summary
  ///
  /// In en, this message translates to:
  /// **'{knew} knew it · {almost} almost · {again} to see again tomorrow'**
  String studyRevisionSummary(int knew, int almost, int again);

  /// Revision flip hint
  ///
  /// In en, this message translates to:
  /// **'Think of the answer, then tap to check.'**
  String get studyRevisionHint;

  /// Reveal answer button
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get studyRevisionShowAnswer;

  /// Review rating again
  ///
  /// In en, this message translates to:
  /// **'Didn’t know'**
  String get studyRevisionAgain;

  /// Review rating almost
  ///
  /// In en, this message translates to:
  /// **'Almost'**
  String get studyRevisionAlmost;

  /// Review rating knew
  ///
  /// In en, this message translates to:
  /// **'Knew it'**
  String get studyRevisionKnew;

  /// Chapter test deck top-bar title
  ///
  /// In en, this message translates to:
  /// **'Ch {number} test'**
  String chapterTestDeckTitle(int number);

  /// Lesson progress without done suffix
  ///
  /// In en, this message translates to:
  /// **'{done} of {count, plural, =1{1 lesson} other{{count} lessons}}'**
  String studyLessonsOf(int done, int count);

  /// Shared try-again action
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// Shared Go Pro action
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get actionGoPro;

  /// Shared back action
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// Shared close action
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Shared network failure
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get failureNetwork;

  /// Shared unknown failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get failureUnknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
