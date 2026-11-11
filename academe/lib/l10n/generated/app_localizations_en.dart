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
}
