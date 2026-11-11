// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ACADEMe';

  @override
  String get meAppLanguage => 'App language';

  @override
  String get meLanguageSheetBody =>
      'Pebby and Scan teaching replies use this language. App chrome follows it as we finish translating.';

  @override
  String get meMoreLanguagesComing => 'More languages coming soon';

  @override
  String languageSwitchingTo(String name) {
    return 'Switching to $name…';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navAskMe => 'ASKMe';

  @override
  String get navStudy => 'Study';

  @override
  String get navMe => 'Me';

  @override
  String get navScan => 'Scan';

  @override
  String get navSend => 'Send';

  @override
  String get askAnythingHint => 'Ask anything…';

  @override
  String get askAttach => 'Attach';

  @override
  String get softUpdateDefaultMessage =>
      'New version just dropped, you don\'t wanna miss this!';

  @override
  String get softUpdateAction => 'Update';

  @override
  String get softUpdateDismiss => 'Not now';

  @override
  String get updateRequiredTitle => 'Hold up';

  @override
  String get updateRequiredBody =>
      'This build can’t talk to our servers anymore. Update on Play to keep studying.';

  @override
  String updateRequiredBuild(String build) {
    return 'Installed build $build.';
  }

  @override
  String get updateRequiredAction => 'Update on Google Play';

  @override
  String get pebbySemantics => 'Pebby';

  @override
  String get welcomeHeadlineLead => 'Study\nsmarter.';

  @override
  String get welcomeHeadlineAccent => 'Not longer.';

  @override
  String get welcomeBody =>
      'Notes, quizzes and flashcards made from what you are actually studying.';

  @override
  String get welcomeGetStarted => 'Get started';

  @override
  String get welcomeAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get welcomeNewUser => 'New user? ';

  @override
  String get welcomeLegal =>
      'By continuing you agree to our Terms and Privacy Policy.';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueEmail => 'Continue with email';

  @override
  String get loginHeadlineLead => 'Welcome';

  @override
  String get loginHeadlineAccent => 'back.';

  @override
  String get loginSubtitle => 'Log in to pick up where you left off.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLoggingIn => 'Logging in…';

  @override
  String get authNewHere => 'New here? ';

  @override
  String get forgotPasswordLead => 'Forgot your';

  @override
  String get forgotPasswordAccent => 'password?';

  @override
  String get forgotPasswordSubtitle =>
      'Type your email and I\'ll send you a 6-digit code.';

  @override
  String get authSending => 'Sending…';

  @override
  String get authSendCode => 'Send code';

  @override
  String get resetCodeLead => 'Check your';

  @override
  String get resetCodeAccent => 'email.';

  @override
  String resetCodeSubtitle(String email) {
    return 'If $email has an ACADEMe account, a 6-digit code is on its way. It expires in 15 minutes.';
  }

  @override
  String get authPasteCode => 'Paste code';

  @override
  String get authChecking => 'Checking…';

  @override
  String get authVerify => 'Verify';

  @override
  String get resetDidntGetIt => 'Didn\'t get it? ';

  @override
  String get resetSendNewCode => 'Send a new code';

  @override
  String get resetSendingNewCode => 'Sending a new code…';

  @override
  String resetNewCodeSent(String seconds) {
    return 'New code sent. You can ask again in 0:$seconds';
  }

  @override
  String resetAskAgainIn(String seconds) {
    return 'You can ask for a new code in 0:$seconds';
  }

  @override
  String get newPasswordLead => 'Choose a new';

  @override
  String get newPasswordAccent => 'password.';

  @override
  String get newPasswordSubtitle =>
      'At least 8 characters. Don\'t worry, I won\'t look.';

  @override
  String get authNewPassword => 'New password';

  @override
  String authPasswordMinLength(int count) {
    return '$count+ characters';
  }

  @override
  String get authStartAgain => 'Start again';

  @override
  String get authSaving => 'Saving…';

  @override
  String get authSaveAndLogIn => 'Save and log in';

  @override
  String get authFailureEmailTaken =>
      'An account already uses this email. Log in instead.';

  @override
  String get authFailureWrongCredentials =>
      'That email and password don\'t match.';

  @override
  String get authFailureInvalidInput => 'Check your details and try again.';

  @override
  String get authFailureSignedOut => 'Your session ended. Log in again.';

  @override
  String get authFailureNetwork =>
      'Can\'t reach ACADEMe. Check your connection and try again.';

  @override
  String get authFailureCanceled => 'Sign-in was canceled.';

  @override
  String get authFailureProviderUnavailable =>
      'This sign-in option isn\'t ready yet. Use email for now.';

  @override
  String get authFailureWrongCode =>
      'That code isn\'t right. Check the email and try again.';

  @override
  String get authFailureTooManyAttempts =>
      'Too many wrong tries. Send yourself a new code.';

  @override
  String get authFailureCodeExpired =>
      'That code has expired. Send yourself a new one.';

  @override
  String get authFailureResetExpired =>
      'This reset link timed out. Start again from Forgot password.';

  @override
  String get authFailureTooManyRequests =>
      'That\'s a lot of tries. Wait a little and try again.';

  @override
  String get authFailureWrongPassword => 'That isn\'t your current password.';

  @override
  String get authFailureGoogleTaken =>
      'That Google account is linked to another ACADEMe account.';

  @override
  String get authFailurePasswordRequired =>
      'Set a password first, so you can still log in without Google.';

  @override
  String get authFailureUnknown => 'Something went wrong. Try again.';

  @override
  String get signUpHiPebby => 'Hi, I\'m Pebby!';

  @override
  String signUpHiNamed(String name) {
    return 'Hi $name, I\'m Pebby!';
  }

  @override
  String get signUpAskFirstName => 'Before we start, what should I call you?';

  @override
  String get signUpFirstName => 'First name';

  @override
  String signUpAskLastName(String name) {
    return 'Nice to meet you, $name! And your last name?';
  }

  @override
  String get signUpLastName => 'Last name';

  @override
  String signUpAskEmail(String name) {
    return 'What\'s your email, $name?';
  }

  @override
  String get signUpEmailHint => 'You\'ll use it to log in.';

  @override
  String get signUpEmailInvalid => 'That doesn\'t look like an email yet.';

  @override
  String get signUpCreatePassword => 'Create a password';

  @override
  String signUpPasswordHint(int count) {
    return 'At least $count characters. Don\'t worry, I won\'t look.';
  }

  @override
  String signUpWelcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get signUpAlreadyLoggedIn =>
      'You already have an account, so you\'re logged in.';

  @override
  String signUpYoureIn(String name) {
    return 'You\'re in, $name!';
  }

  @override
  String get signUpAccountReady =>
      'Your account is ready. Next, tell me what you study.';

  @override
  String get signUpHelloEmail =>
      'I\'ll help you study smarter. Let\'s set up your account, it takes a minute.';

  @override
  String get signUpConnectingAccount => 'Connecting your account…';

  @override
  String get signUpCheckName => 'Let\'s check your name, then you\'re in.';

  @override
  String get signUpConnecting => 'Connecting…';

  @override
  String get signUpTryAgain => 'Try again';

  @override
  String get signUpHiPebbyAction => 'Hi Pebby!';

  @override
  String get signUpCreatingAccount => 'Creating your account…';

  @override
  String get signUpCreateAccount => 'Create account';

  @override
  String get signUpLetsGo => 'Let\'s go';

  @override
  String get authContinue => 'Continue';

  @override
  String get homeSetupTitle => 'Set up your dashboard';

  @override
  String homeSetupXpProgress(int done, int total) {
    return '$done / $total XP';
  }

  @override
  String get homeSetupTaskLanguage => 'Language';

  @override
  String get homeSetupTaskAge => 'Your age';

  @override
  String get homeSetupTaskClass => 'Your class';

  @override
  String get homeSetupTaskBoard => 'Your board';

  @override
  String get homeSetupTaskSubjects => 'Your subjects';

  @override
  String homeSetupXpDone(int xp) {
    return '✓ $xp XP';
  }

  @override
  String homeSetupXpEarn(int xp) {
    return '+$xp XP';
  }

  @override
  String get homeSolveHomework => 'Solve homework';

  @override
  String get homeCheckAnswer => 'Check my answer';

  @override
  String get homeFlashcards => 'Flashcards';

  @override
  String get homePickSubjects => 'Pick your subjects';

  @override
  String homePickSubjectsBody(int xp) {
    return 'Home and Study show only the ones you take. +$xp XP';
  }
}
