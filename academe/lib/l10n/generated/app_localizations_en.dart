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
}
