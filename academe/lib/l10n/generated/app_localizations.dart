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

  /// AuthFailure.unknown
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authFailureUnknown;

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

  /// Sign-up primary button after OAuth error
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get signUpTryAgain;

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
