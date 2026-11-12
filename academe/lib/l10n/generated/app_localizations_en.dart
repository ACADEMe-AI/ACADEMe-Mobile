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

  @override
  String get setupLanguageTitle => 'Which language do you learn in?';

  @override
  String setupChooseLanguage(String name) {
    return 'Choose $name';
  }

  @override
  String get setupLanguageFootnote => 'You can change it any time in Settings.';

  @override
  String get setupAgeTitle => 'When were you born?';

  @override
  String get setupAgeSubtitle => 'So we keep things right for your age.';

  @override
  String get setupBirthYear => 'Birth year';

  @override
  String setupYouAreAge(int age) {
    return 'You’re $age.';
  }

  @override
  String get setupClassTitle => 'Spin to your class';

  @override
  String get setupClassSubtitle => 'Turn the dial or tap a number.';

  @override
  String setupImInClass(int level) {
    return 'I’m in Class $level';
  }

  @override
  String get setupBoardTitle => 'Which board?';

  @override
  String get setupBoardSubtitle => 'We follow your board’s syllabus.';

  @override
  String get setupStateBoardsSoon => 'State boards are coming soon.';

  @override
  String get setupFinish => 'Finish setup';

  @override
  String setupProgress(int step, int total) {
    return 'SET UP · $step/$total';
  }

  @override
  String get setupLater => 'Later';

  @override
  String get setupChangeInMe => 'You can change this any time in Me.';

  @override
  String setupStreamTitle(int level) {
    return 'What do you study in Class $level?';
  }

  @override
  String get setupAnythingElse => 'Anything else?';

  @override
  String get setupWhichSubjects => 'Which subjects do you study?';

  @override
  String setupMainSubjectsIn(String syllabus) {
    return '$syllabus. Your main subjects are in.';
  }

  @override
  String setupTapToRemove(String syllabus) {
    return '$syllabus. Tap to remove any you don’t take.';
  }

  @override
  String get homeYourSubjects => 'Your subjects';

  @override
  String get homeEdit => 'Edit';

  @override
  String get homeSubjectsNeedSyllabus =>
      'Set your class and board to see your subjects';

  @override
  String get homeSubjectsLoading => 'Loading your subjects…';

  @override
  String get homeSubjectsSoon => 'Your subjects show up here soon.';

  @override
  String homeNextChapter(int number, String title) {
    return 'Next: Ch $number · $title';
  }

  @override
  String get homeAllLessonsDone => 'All lessons done';

  @override
  String get homeLessonsComingSoon => 'Lessons coming soon';

  @override
  String homeTodayMinutes(int minutes) {
    return 'Today · $minutes min';
  }

  @override
  String get homeTodayDone => 'Today · all done';

  @override
  String homeFromFolders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'from $count folders',
      one: 'from 1 folder',
    );
    return '$_temp0';
  }

  @override
  String homeMoreInFolders(int count) {
    return 'and $count more in your folders';
  }

  @override
  String get homeAskHintTitle => 'Ask Pebby anything';

  @override
  String get homeAskHintBody =>
      'Type a question, or tap Solve homework to snap one.';

  @override
  String get homeAskHintGotIt => 'Got it';

  @override
  String get homeDashboardLoadError => 'You’re currently offline.';

  @override
  String get homeRetry => 'Retry';

  @override
  String get helloFallbackName => 'there';

  @override
  String homeStreakSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String get scanModeNotes => 'Notes to a folder';

  @override
  String get scanModeAsk => 'Ask about a photo';

  @override
  String get scanWhatsOnPaper => 'What’s on the paper?';

  @override
  String get scanHintSolve => 'Hints first';

  @override
  String get scanHintCheck => 'Board-style marks';

  @override
  String get scanHintNotes => 'Pages into a lesson';

  @override
  String get scanHintAsk => 'Anything else';

  @override
  String get scanRecent => 'Recent scans';

  @override
  String get scanStatusRead => 'Read';

  @override
  String get scanStatusSolvedInAskMe => 'Solved in ASKMe';

  @override
  String get scanStatusAskedInAskMe => 'Asked in ASKMe';

  @override
  String scanStatusMarks(int awarded, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks',
      one: '1 mark',
    );
    return '$awarded/$_temp0';
  }

  @override
  String get scanStatusNotMarked => 'Not marked yet';

  @override
  String get scanStatusLessonInFolder => 'Lesson in a folder';

  @override
  String get scanStatusNotesInFolder => 'Notes in a folder';

  @override
  String get scanStatusNotSaved => 'Not saved yet';

  @override
  String get scanSourceNotesBlurb =>
      'Up to 10 pages. Only the text is kept, not the photos.';

  @override
  String get scanSourceBlurb => 'Only the text is kept, not the photo.';

  @override
  String get scanTakePhoto => 'Take a photo';

  @override
  String get scanChooseGallery => 'Choose from gallery';

  @override
  String get scanCamera => 'Camera';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanYourPages => 'Your pages';

  @override
  String scanPagesOf(int current, int max) {
    return '$current of $max';
  }

  @override
  String scanReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count pages',
      one: 'Read 1 page',
    );
    return '$_temp0';
  }

  @override
  String get scanRemovePage => 'Remove page';

  @override
  String get scanYourNotes => 'Your notes';

  @override
  String scanPebbyReadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pebby read $count pages',
      one: 'Pebby read 1 page',
    );
    return '$_temp0';
  }

  @override
  String get scanWhereShouldTheseGo => 'Where should these go?';

  @override
  String get scanChooseFolder => 'Choose a folder';

  @override
  String get scanChange => 'Change';

  @override
  String get scanMakeFromNotes => 'Make from your notes';

  @override
  String get scanSwipeLesson => 'Swipe lesson';

  @override
  String get scanSwipeLessonSubtitle =>
      'Cards and quick checks, added to the plan';

  @override
  String get scanKeepNotes => 'Just keep the notes';

  @override
  String get scanKeepNotesSubtitle => 'The text goes into the folder';

  @override
  String scanReadingPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Reading $count pages…',
      one: 'Reading your page…',
    );
    return '$_temp0';
  }

  @override
  String get scanReadingWait => 'This takes a few seconds.';

  @override
  String get scanMakingLesson => 'Making your lesson…';

  @override
  String get scanSavingNotes => 'Saving your notes…';

  @override
  String get scanSavingWait => 'It’ll be in your folder.';

  @override
  String get scanFailUnavailableTitle => 'Scan isn’t ready yet';

  @override
  String get scanFailUnavailableBody =>
      'Pebby can’t read photos right now. Try again later.';

  @override
  String get scanFailNoTextTitle => 'No words here';

  @override
  String get scanFailNoTextBody =>
      'Point the camera at your homework, a textbook page or your notes.';

  @override
  String get scanFailTooLargeTitle => 'Too many big photos';

  @override
  String get scanFailTooLargeBody => 'Try fewer pages at a time.';

  @override
  String get scanFailNetworkTitle => 'You’re offline';

  @override
  String get scanFailNetworkBody => 'Check your internet and try again.';

  @override
  String get scanFailScanLimitTitle => 'That’s today’s free scans';

  @override
  String get scanFailScanLimitBody =>
      'They come back at midnight. Go Pro to scan as much as you like.';

  @override
  String get scanFailCheckLimitTitle => 'That’s today’s free check';

  @override
  String get scanFailCheckLimitBody =>
      'It comes back at midnight. Go Pro to check every answer.';

  @override
  String get scanFailProOnlyTitle => 'Lessons from notes are Pro';

  @override
  String get scanFailProOnlyBody =>
      'Keep your notes for free, or go Pro and Pebby makes them a lesson.';

  @override
  String get scanFailUnknownTitle => 'Pebby couldn’t read that';

  @override
  String get scanFailUnknownBody =>
      'Try again, or retake the photo in better light.';

  @override
  String get scanBackToAnswer => 'Back to your answer';

  @override
  String get scanRetake => 'Retake';

  @override
  String get scanCameraOpenFailed =>
      'Couldn’t open the camera. Try the gallery.';

  @override
  String get scanPebbyReadThis => 'Pebby read this';

  @override
  String get scanFixAnything => 'Fix anything that’s wrong.';

  @override
  String scanChapterFix(String chapter) {
    return '$chapter · fix anything that’s wrong.';
  }

  @override
  String get scanFromYourPhoto => 'From your photo';

  @override
  String get scanFromMyPhoto => 'From my photo:';

  @override
  String get scanWhatDoYouWant => 'What do you want to know?';

  @override
  String get scanSuggestExplain => 'Explain this simply';

  @override
  String get scanSuggestSummarise => 'Summarise it';

  @override
  String get scanSuggestKeyTerms => 'What are the key terms?';

  @override
  String get scanSolveThis => 'Solve this';

  @override
  String get scanAskPebby => 'Ask Pebby';

  @override
  String get scanHintFirst => 'Pebby gives you a hint first, then the steps.';

  @override
  String get checkPebbyReadAnswer => 'Pebby read your answer';

  @override
  String get checkTheQuestion => 'The question';

  @override
  String get checkQuestionHint => 'Only if it isn’t in the photo';

  @override
  String get checkMarkIt => 'Mark it';

  @override
  String get checkMarkingAnswer => 'Marking your answer…';

  @override
  String get checkMarkingScheme => 'Using the board’s marking scheme.';

  @override
  String get checkFullMarks => 'Full marks!';

  @override
  String get checkNearlyThere => 'Nearly there';

  @override
  String get checkKeepGoing => 'Keep going';

  @override
  String get checkReportTitle => 'Report these marks';

  @override
  String get checkReportThanks => 'Thanks. We’ll review these marks.';

  @override
  String get checkWhatGotMarks => 'What got marks';

  @override
  String get checkWellDone => 'Well done';

  @override
  String get checkForFullMarks => 'For full marks';

  @override
  String get checkAgain => 'Check again';

  @override
  String get checkShowModelAnswer => 'Show model answer';

  @override
  String get checkHideModelAnswer => 'Hide model answer';

  @override
  String checkAskQuestion(String question) {
    return 'Question: $question';
  }

  @override
  String checkAskMyAnswer(String answer) {
    return 'My answer:\n$answer';
  }

  @override
  String checkAskHowFullMarks(int awarded, int marks) {
    return 'I got $awarded/$marks. How do I get full marks?';
  }

  @override
  String get meLearningSection => 'Learning';

  @override
  String get meMyProgress => 'My Progress';

  @override
  String get meClassAndBoard => 'Class and board';

  @override
  String get meAppearance => 'Appearance';

  @override
  String get meNotificationsSection => 'Notifications';

  @override
  String get meRemindersAndDailyGoal => 'Reminders and daily goal';

  @override
  String get meAccountSection => 'Account';

  @override
  String get meAccount => 'Account';

  @override
  String get meHelpAndFeedback => 'Help and feedback';

  @override
  String get mePrivacyAndTerms => 'Privacy and terms';

  @override
  String get meLogOut => 'Log out';

  @override
  String get meLoggingOut => 'Logging out…';

  @override
  String get meStudentFallback => 'Student';

  @override
  String get meDayStreak => 'day streak';

  @override
  String meLevelValue(int number) {
    return 'Lv $number';
  }

  @override
  String meXpToNextLevel(int xp, int level) {
    return '$xp XP to Lv $level';
  }

  @override
  String get meXpLabel => 'XP';

  @override
  String get meOk => 'OK';

  @override
  String meOkSwitchTo(String name) {
    return 'OK · Switch to $name';
  }

  @override
  String meLanguageSwitched(String greeting, String name) {
    return '$greeting Pebby will now answer in $name.';
  }

  @override
  String get meLanguageSwitchFailed =>
      'Couldn’t switch the language. Try again.';

  @override
  String meOpenInBrowser(String url) {
    return 'Open $url in your browser';
  }

  @override
  String get meNotSet => 'Not set';

  @override
  String get meOff => 'Off';

  @override
  String meClassOnly(int level) {
    return 'Class $level';
  }

  @override
  String meClassBoard(int level, String board) {
    return 'Class $level · $board';
  }

  @override
  String get meLogOutTitle => 'Log out?';

  @override
  String get meLogOutBody =>
      'Your progress is saved to your account. Log in again any time.';

  @override
  String get meLogOutStay => 'Stay';

  @override
  String get accountSaveName => 'Save name';

  @override
  String get accountNameSaved => 'Name saved';

  @override
  String get accountDangerZone => 'Danger zone';

  @override
  String get accountDeleteMyAccount => 'Delete my account';

  @override
  String get accountDeleteGraceNote =>
      'Your account is deleted 30 days after you ask. Log in before then to keep it.';

  @override
  String get accountSignIn => 'Sign-in';

  @override
  String get accountChangePassword => 'Change password';

  @override
  String get accountSetPassword => 'Set a password';

  @override
  String get accountLinkGoogle => 'Link Google';

  @override
  String get accountGoogle => 'Google';

  @override
  String get accountLinking => 'Linking…';

  @override
  String get accountUnlinking => 'Unlinking…';

  @override
  String get accountNotLinked => 'Not linked';

  @override
  String get accountGoogleLinked =>
      'Google linked. You can log in with it now.';

  @override
  String get accountGoogleUnlinked =>
      'Google unlinked. Log in with your email and password.';

  @override
  String get accountUnlinkGoogleTitle => 'Unlink Google?';

  @override
  String accountUnlinkGoogleBody(String email) {
    return 'You won’t be able to log in with $email any more. Use your email and password instead.';
  }

  @override
  String get accountKeepGoogle => 'Keep Google';

  @override
  String get accountUnlink => 'Unlink';

  @override
  String get passwordSave => 'Save password';

  @override
  String get passwordChangeBody =>
      'Use the same rules as when you signed up. Other devices are logged out when you save.';

  @override
  String get passwordSetBody =>
      'Add a password so you can also log in with your email, not just Google.';

  @override
  String get passwordCurrent => 'Current password';

  @override
  String get passwordChangedSnack =>
      'Password changed. Other devices have been logged out.';

  @override
  String get passwordSetSnack =>
      'Password set. You can now log in with your email too.';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteDeleting => 'Deleting…';

  @override
  String get deleteSorryTitle => 'We’re sorry to see you go';

  @override
  String get deleteBody =>
      'Your account will be deleted in 30 days. Log in again before then to keep it. After 30 days your profile, chats, progress and XP are erased for good and can’t be brought back.';

  @override
  String get deleteSubscription => 'Subscription';

  @override
  String get deleteSubscriptionNotice =>
      'Deleting your account doesn’t cancel an ACADEMe Pro subscription bought on Google Play. Cancel it in Google Play so you aren’t charged again.';

  @override
  String get deleteManageSubscription => 'Manage subscription';

  @override
  String get deleteWhyLeaving => 'Why are you leaving? (optional)';

  @override
  String deleteConfirmLabel(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get deleteReasonNotEnough => 'I don’t use it enough';

  @override
  String get deleteReasonDidntHelp => 'It didn’t help with my studies';

  @override
  String get deleteReasonTooManyNotifs => 'Too many notifications';

  @override
  String get deleteReasonDataWorry => 'I’m worried about my data';

  @override
  String get deleteReasonOther => 'Something else';

  @override
  String deleteScheduledSnack(String date) {
    return 'Your account will be deleted on $date. Log in before then to keep it.';
  }

  @override
  String get notifRemindersAndGoalTitle => 'Reminders and goal';

  @override
  String get notifStudyReminder => 'Study reminder';

  @override
  String get notifRemindMeToStudy => 'Remind me to study';

  @override
  String get notifTime => 'Time';

  @override
  String get notifRemindMeAt => 'Remind me at';

  @override
  String get notifAlsoTellMe => 'Also tell me';

  @override
  String get notifStreakAboutToEnd => 'When my streak is about to end';

  @override
  String get notifEveningBeforeTest => 'The evening before a test';

  @override
  String get notifWhenLevelUp => 'When I level up';

  @override
  String get notifNotifications => 'Notifications';

  @override
  String get notifAllowed => 'Allowed';

  @override
  String get notifNotAllowed => 'Not allowed';

  @override
  String get notifTurnOn => 'Turn on notifications';

  @override
  String get notifTurnOnInSettings => 'Turn on in Settings';

  @override
  String get reminderTimeTitle => 'Reminder time';

  @override
  String get reminderHour => 'Hour';

  @override
  String get reminderMinute => 'Minute';

  @override
  String get reminderAmPm => 'Morning or evening';

  @override
  String get reminderAm => 'am';

  @override
  String get reminderPm => 'pm';

  @override
  String get dailyGoalTitle => 'Daily goal';

  @override
  String dailyGoalNote(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Today’s steps on Home will add up to about $_temp0.';
  }

  @override
  String get dailyGoalSemantics => 'Daily goal in minutes';

  @override
  String dailyGoalMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String get dailyGoalStudyEachDay => 'Study each day';

  @override
  String get appearanceTheme => 'THEME';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceDarkHint => 'Dark mode is easier on your eyes at night.';

  @override
  String get appearanceLightsOff => 'Lights off…';

  @override
  String get appearanceGoodMorning => 'Good morning!';

  @override
  String get appearanceDimming => 'Pebby is dimming the room';

  @override
  String get appearanceOpeningCurtains => 'Pebby is opening the curtains';

  @override
  String get helpTellUs => 'Tell us';

  @override
  String get helpEmailUs => 'Email us';

  @override
  String get helpThanks => 'Thanks, we got your message.';

  @override
  String get feedbackWrongAnswer => 'Report a wrong answer';

  @override
  String get feedbackBug => 'Something isn’t working';

  @override
  String get feedbackFeature => 'Suggest a feature';

  @override
  String get feedbackHint => 'Tell us what happened (at least 10 characters).';

  @override
  String get feedbackSend => 'Send';

  @override
  String get feedbackLimitNote =>
      'You can send up to 2 messages a day and 5 a week.';

  @override
  String get feedbackFailGeneric => 'Couldn’t send that. Try again.';

  @override
  String get feedbackFailDay =>
      'You’ve sent the most feedback we can take today. Try again tomorrow.';

  @override
  String get feedbackFailWeek =>
      'You’ve sent the most feedback we can take this week. Try again next week.';

  @override
  String get feedbackFailTooShort =>
      'Write at least 10 characters so we can help.';

  @override
  String get feedbackFailOffline =>
      'You’re offline. Check your connection and try again.';

  @override
  String get privacySummary1 =>
      'We keep your account, class, board and subjects, study progress and streak, folders, notes and chats with Pebby to run ACADEMe for you.';

  @override
  String get privacySummary2 =>
      'Your questions and scanned photos go to Sarvam AI in India so Pebby can answer. We don’t store your photos, only the text read from them.';

  @override
  String get privacySummary3 =>
      'No ads, no advertising ID, no location, and we never sell your data.';

  @override
  String get privacySummary4 =>
      'Delete your account any time in Account. Everything is erased after 30 days.';

  @override
  String get privacyDocuments => 'Documents';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get privacyTermsOfUse => 'Terms of use';

  @override
  String get privacyYourData => 'Your data';

  @override
  String get privacyGetCopy => 'Get a copy of my data';

  @override
  String get privacyGrievanceOfficer => 'Grievance Officer';

  @override
  String classBoardSave(int level, String board) {
    return 'Save · Class $level · $board';
  }

  @override
  String get classBoardYourClass => 'Your class';

  @override
  String get classBoardYourBoard => 'Your board';

  @override
  String classBoardSwitchNote(int level, String board) {
    return 'Your subjects and plan will switch to Class $level · $board. Everything you’ve done so far stays saved.';
  }

  @override
  String get classBoardSubjects => 'Subjects';

  @override
  String get classBoardStream => 'Stream';

  @override
  String get classBoardAllSubjects => 'All subjects';

  @override
  String classBoardSubjectCount(int count, String names) {
    return '$count · $names';
  }

  @override
  String classBoardSavedSnack(int level, String board) {
    return 'Now showing Class $level · $board subjects';
  }

  @override
  String get reminderPrimerTitle => 'Get a nudge before your test';

  @override
  String get reminderPrimerPromise1 =>
      'A heads-up 3 days before, the evening before and the morning of each test';

  @override
  String get reminderPrimerPromise2 =>
      'Your study reminder, only on the days and time you pick';

  @override
  String get reminderPrimerPromise3 => 'Nothing else. Change it any time in Me';

  @override
  String get reminderPrimerAllow => 'Allow';

  @override
  String get paywallWelcomeSnack => 'Welcome to ACADEMe Pro';

  @override
  String get paywallTagline =>
      '3× daily & weekly limits. Same refill clock — more room to study.';

  @override
  String get paywallOpeningPlay => 'Opening Google Play…';

  @override
  String get paywallRestoring => 'Restoring…';

  @override
  String get paywallRestore => 'Restore purchases';

  @override
  String get paywallUnavailableTitle =>
      'Purchases aren’t available on this device';

  @override
  String get paywallUnavailableBody =>
      'Install ACADEMe from Google Play and sign in to Play to go Pro.';

  @override
  String get paywallBenefitAskme => '3× ASKMe questions every day';

  @override
  String get paywallBenefitScan => '3× scans every day';

  @override
  String get paywallBenefitCheck => '3× answer checks every day';

  @override
  String get paywallBenefitLessons => 'Swipe lessons made from your notes';

  @override
  String get paywallBenefitProgress => 'My Progress weekly study summary';

  @override
  String get paywallMonthly => 'Monthly';

  @override
  String get paywallAnnual => 'Annual';

  @override
  String paywallPlanSemantics(String title) {
    return '$title plan';
  }

  @override
  String paywallPriceIntroMonth(String introPrice, String price) {
    return '$introPrice for the first month, then $price/month';
  }

  @override
  String paywallPriceMonth(String price) {
    return '$price/month';
  }

  @override
  String paywallPriceYear(String price) {
    return '$price/year';
  }

  @override
  String paywallDetailAnnualMonthly(String monthlyPrice) {
    return 'About $monthlyPrice/month · save 17% · renews automatically';
  }

  @override
  String get paywallDetailAnnual => 'Save 17% · renews automatically';

  @override
  String get paywallDetailRenews => 'Renews automatically';

  @override
  String get paywallBestValue => 'Best value';

  @override
  String get paywallSmallPrint =>
      'Renews automatically. Cancel anytime in Google Play.';

  @override
  String get paywallTerms => 'Terms';

  @override
  String get paywallPrivacy => 'Privacy';

  @override
  String get upgradeTitle => 'Go Pro · 3× limits';

  @override
  String get limitAskmeTitle => 'That’s today’s free questions';

  @override
  String limitAskmeBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ASKMe questions',
      one: '1 ASKMe question',
    );
    return 'Free includes $_temp0 a day. Pro gives 3× every day.';
  }

  @override
  String get limitScanTitle => 'That’s today’s free scans';

  @override
  String limitScanBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scans',
      one: '1 scan',
    );
    return 'Free includes $_temp0 a day. Pro gives 3× every day.';
  }

  @override
  String limitCheckTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'That’s today’s free checks',
      one: 'That’s today’s free check',
    );
    return '$_temp0';
  }

  @override
  String limitCheckBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answer checks',
      one: 'one answer check',
    );
    return 'Free includes $_temp0 a day. Pro gives 3× every day.';
  }

  @override
  String get limitLessonsTitle => 'Lessons from notes are Pro';

  @override
  String get limitLessonsBody =>
      'Keeping your notes is free. With Pro, Pebby turns them into swipe lessons with quizzes.';

  @override
  String get limitMaybeLater => 'Maybe later';

  @override
  String get proTitle => 'ACADEMe Pro';

  @override
  String get proPlanLimitsTitle => 'Plan & limits';

  @override
  String get proCardSubtitleFree => 'Plan & limits · 3× with Pro';

  @override
  String get proCardSubtitleMonthly => 'Pro · monthly';

  @override
  String get proCardSubtitleAnnual => 'Pro · annual';

  @override
  String get proCardSubtitlePro => 'Pro';

  @override
  String get proManage => 'Manage';

  @override
  String get proOnPro => 'You’re on Pro';

  @override
  String get proOnFree => 'You’re on Free';

  @override
  String get proMetaFree => 'Daily & weekly limits · 12:00 AM IST';

  @override
  String get proMetaBillingIssue => 'Fix payment in Google Play to keep Pro';

  @override
  String get proMetaActiveNoExpiry => '3× daily limits · weekly safety cap';

  @override
  String proMetaAnnualRenews(String date) {
    return 'Annual · Renews $date · 3× limits';
  }

  @override
  String proMetaMonthlyRenews(String date) {
    return 'Monthly · Renews $date · 3× limits';
  }

  @override
  String proMetaEnds(String date) {
    return 'Pro ends on $date';
  }

  @override
  String get proStatusActive => 'Active';

  @override
  String get proStatusFree => 'Free';

  @override
  String get proDailyLimits => 'Daily limits';

  @override
  String get proResetsDaily => 'Resets every day at 12:00 AM IST';

  @override
  String get proFeatureAskme => 'ASKMe';

  @override
  String get proFeatureScan => 'Scan';

  @override
  String get proFeatureCheck => 'Check';

  @override
  String get proFeatureLessons => 'Lessons';

  @override
  String get proWeeklyLimit => 'Weekly limit';

  @override
  String get proResetsMondays => 'Resets Mondays · 12:00 AM IST';

  @override
  String proResetsOnDay(String day) {
    return 'Resets $day · 12:00 AM IST';
  }

  @override
  String get proAllFeatures => 'All features';

  @override
  String get proManageInPlay => 'Manage in Google Play';

  @override
  String get proResetsSoon => 'soon';

  @override
  String proResetsInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count hours',
      one: 'in 1 hour',
    );
    return '$_temp0';
  }

  @override
  String get proNoticePending =>
      'Your payment is pending. Pro turns on as soon as Google Play confirms it.';

  @override
  String get proNoticeNoPurchase =>
      'No ACADEMe Pro purchase was found on this Google account.';

  @override
  String get proNoticeNotAllowed =>
      'Purchases are turned off for this Google account.';

  @override
  String get proNoticeAlreadyOwned =>
      'This Google account already has Pro. Tap Restore purchases.';

  @override
  String get proNoticeUnavailable =>
      'Purchases aren’t available on this device.';

  @override
  String get proNoticeStoreError =>
      'Google Play couldn’t finish that. Try again.';

  @override
  String get askmeNewChat => 'New chat';

  @override
  String askmeStudying(String name) {
    return 'What are we studying, $name?';
  }

  @override
  String get askmeModeExplainLine => 'Pebby explains it simply, step by step.';

  @override
  String get askmeModeSolveLine => 'Pebby gives hints. You solve it.';

  @override
  String get askmeModeQuizLine => 'Pebby asks, you answer, you earn XP.';

  @override
  String get askmeSuggestExplain1 => 'Explain reflection of light simply';

  @override
  String get askmeSuggestExplain2 => 'Why is the sky blue?';

  @override
  String get askmeSuggestExplain3 => 'What is photosynthesis?';

  @override
  String get askmeSuggestSolve1 =>
      'Help me solve 2x + 3y = 11 and x − 2y = −12';

  @override
  String get askmeSuggestSolve2 => 'Find the area of a circle with r = 7 cm';

  @override
  String get askmeSuggestSolve3 => 'Balance H₂ + O₂ → H₂O';

  @override
  String get askmeSuggestQuiz1 => 'Quiz me on Light';

  @override
  String get askmeSuggestQuiz2 => 'Give me 5 questions on linear equations';

  @override
  String get askmeSuggestQuiz3 => 'Quiz me on the French Revolution';

  @override
  String get askmeModeExplain => 'Explain';

  @override
  String get askmeModeSolve => 'Solve';

  @override
  String get askmeModeQuiz => 'Quiz me';

  @override
  String get askmeFollowNextStep => 'Next step';

  @override
  String get askmeFollowFullSolution => 'Full solution';

  @override
  String get askmeFollowNextQuestion => 'Next question';

  @override
  String get askmeFollowQuizMe => 'Quiz me';

  @override
  String get askmeFollowGoDeeper => 'Go deeper';

  @override
  String get askmeSendNextStep => 'Next step, please.';

  @override
  String get askmeSendFullSolution => 'Show me the full solution.';

  @override
  String get askmeSendNextQuestion => 'Next question.';

  @override
  String get askmeSendGoDeeper => 'Go deeper.';

  @override
  String get askmeSendQuizMe => 'Quiz me on this.';

  @override
  String get askmeFailureUnavailable =>
      'ASKMe isn’t ready yet. Pebby will be here soon.';

  @override
  String get askmeFailureSignedOut => 'You’ve been logged out. Log in again.';

  @override
  String get askmeFailureLimitReached =>
      'That’s all your free questions for today. They come back at midnight.';

  @override
  String get askmeThinking => 'Pebby is thinking';

  @override
  String get historyTitle => 'History';

  @override
  String get historySearchHint => 'Search your questions';

  @override
  String get historyLoadError => 'Couldn’t load your chats. Retry';

  @override
  String get historyEmpty => 'Your questions to Pebby will show up here.';

  @override
  String get historyThisWeek => 'This week';

  @override
  String get historyEarlier => 'Earlier';

  @override
  String get historyNow => 'Now';

  @override
  String historyHoursAgo(int hours) {
    return '${hours}h';
  }

  @override
  String get historyWeekdayMon => 'Mon';

  @override
  String get historyWeekdayTue => 'Tue';

  @override
  String get historyWeekdayWed => 'Wed';

  @override
  String get historyWeekdayThu => 'Thu';

  @override
  String get historyWeekdayFri => 'Fri';

  @override
  String get historyWeekdaySat => 'Sat';

  @override
  String get historyWeekdaySun => 'Sun';

  @override
  String get historyMonthJan => 'Jan';

  @override
  String get historyMonthFeb => 'Feb';

  @override
  String get historyMonthMar => 'Mar';

  @override
  String get historyMonthApr => 'Apr';

  @override
  String get historyMonthMay => 'May';

  @override
  String get historyMonthJun => 'Jun';

  @override
  String get historyMonthJul => 'Jul';

  @override
  String get historyMonthAug => 'Aug';

  @override
  String get historyMonthSep => 'Sep';

  @override
  String get historyMonthOct => 'Oct';

  @override
  String get historyMonthNov => 'Nov';

  @override
  String get historyMonthDec => 'Dec';

  @override
  String historyDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String get attachTitle => 'Add to your question';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachPhotos => 'Photos';

  @override
  String get replyHelpful => 'Helpful';

  @override
  String get replyNotHelpful => 'Not helpful';

  @override
  String get replyCopy => 'Copy';

  @override
  String get replyCopied => 'Copied';

  @override
  String get replyReportTitle => 'Report this answer';

  @override
  String get replyReportThanks => 'Thanks. We’ll review this answer.';

  @override
  String get reportTooltip => 'Report';

  @override
  String get reportSendFailed => 'Couldn’t send the report. Try again.';

  @override
  String get reportBody =>
      'We read every report and use it to make Pebby safer.';

  @override
  String get reportReasonWrong => 'It’s wrong';

  @override
  String get reportReasonHarmful => 'It’s harmful or unsafe';

  @override
  String get reportReasonOffensive => 'It’s rude or offensive';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get progressTitle => 'My Progress';

  @override
  String get progressLoading => 'Loading this week…';

  @override
  String get progressLoadError => 'Couldn’t load this week’s summary.';

  @override
  String get progressHoldTitle => 'My Progress is part of Pro';

  @override
  String get progressHoldBody =>
      'See streak, level and study insights with ACADEMe Pro.';

  @override
  String get progressGoProLimits => 'Go Pro · 3× limits';

  @override
  String get progressStudyDays => 'Study days';

  @override
  String get progressThisWeek => 'This week';

  @override
  String get progressTodayStudied => 'Today · studied';

  @override
  String get progressTodayNotYet => 'Today · not yet';

  @override
  String get progressTabSummary => 'Summary';

  @override
  String get progressTabProgress => 'Progress';

  @override
  String get progressTabActivity => 'Activity';

  @override
  String get progressSubjectsThisWeek => 'Subjects this week';

  @override
  String get progressCompleted => 'Completed';

  @override
  String get progressOverallGrade => 'Overall grade';

  @override
  String get progressKeepItUp => 'Keep it up';

  @override
  String get progressStartJourney => 'Start your journey';

  @override
  String get progressCourseProgress => 'Course progress';

  @override
  String get progressLessonsEmpty => 'Lessons you finish will show up here.';

  @override
  String progressSubjectLessons(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$name: $_temp0';
  }

  @override
  String get progressActivity => 'Activity';

  @override
  String get progressStudyDaysEmpty => 'Your study days will show up here.';

  @override
  String progressActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active days this week.',
      one: '1 active day this week.',
    );
    return '$_temp0';
  }

  @override
  String get progressCtaStart => 'It’s time to start your journey!';

  @override
  String get progressCtaMomentum => 'Keep your momentum going';

  @override
  String get progressCtaHabit => 'You’re building a habit';

  @override
  String get progressCtaNext => 'See what to do next';

  @override
  String get progressNextSteps => 'Next steps';

  @override
  String get progressYourSetup => 'Your setup';

  @override
  String get progressWhatNext => 'What to do next';

  @override
  String get progressNextWithStudy =>
      'Keep finishing lessons this week. Your grade updates when you complete them.';

  @override
  String get progressNextNoStudy =>
      'On Me, confirm class and board. Then open Study and finish your first lesson.';

  @override
  String get progressWeekEmpty => 'No study logged this week yet.';

  @override
  String progressWeekActiveDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active days',
      one: '1 active day',
    );
    return '$_temp0';
  }

  @override
  String progressWeekLessons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String progressWeekChapterTests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapter tests',
      one: '1 chapter test',
    );
    return '$_temp0';
  }

  @override
  String progressWeekXp(int count) {
    return '$count XP';
  }

  @override
  String progressWeekSummary(String parts) {
    return 'This week: $parts.';
  }

  @override
  String get progressWeekdayMon => 'M';

  @override
  String get progressWeekdayTue => 'T';

  @override
  String get progressWeekdayWed => 'W';

  @override
  String get progressWeekdayThu => 'T';

  @override
  String get progressWeekdayFri => 'F';

  @override
  String get progressWeekdaySat => 'S';

  @override
  String get progressWeekdaySun => 'S';

  @override
  String get subjectsStreamTitle => 'Your stream';

  @override
  String get subjectsSave => 'Save';

  @override
  String get subjectsLoadError => 'Couldn’t load your subjects. Retry';

  @override
  String get subjectsMain => 'Main';

  @override
  String get subjectsOptional => 'Optional';

  @override
  String streamSwipeFor(String name) {
    return 'Swipe for $name. Change it any time in Me.';
  }

  @override
  String get streamChangeInMe => 'Change it any time in Me.';

  @override
  String streamChoose(String name) {
    return 'Choose $name';
  }

  @override
  String get classDialLabel => 'CLASS';

  @override
  String classDialSemantics(int level) {
    return 'Class $level';
  }

  @override
  String get studyTitle => 'Study';

  @override
  String get studyCourses => 'Courses';

  @override
  String get studyFolders => 'Folders';

  @override
  String get studyDone => 'Done';

  @override
  String get studyKeep => 'Keep';

  @override
  String get studyDelete => 'Delete';

  @override
  String get studySave => 'Save';

  @override
  String get studyCreate => 'Create';

  @override
  String get studyAdd => 'Add';

  @override
  String get studyOptional => 'optional';

  @override
  String get studyName => 'Name';

  @override
  String get studyToday => 'Today';

  @override
  String get studyComingSoon => 'Coming soon';

  @override
  String get studyXp => 'XP';

  @override
  String studyChTitle(int number, String title) {
    return 'Ch $number · $title';
  }

  @override
  String studyLessonsDoneOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$done of $_temp0 done';
  }

  @override
  String studyComingSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coming soon',
      one: '1 coming soon',
    );
    return '$_temp0';
  }

  @override
  String get studyNotInBoardExam => 'Not in board exam';

  @override
  String studyCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String studyQuickChecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quick checks',
      one: '1 quick check',
    );
    return '$_temp0';
  }

  @override
  String studyQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String studyChaptersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String studyLessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String studyMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String studyAboutMinutes(int minutes) {
    return 'about $minutes min';
  }

  @override
  String get coursesNeedSyllabus =>
      'Set your class and board on Home to see your courses.';

  @override
  String get coursesLoadError => 'Couldn’t load your courses. Retry';

  @override
  String coursesComingSoon(String syllabus) {
    return 'Lessons for $syllabus are on their way. Ask Pebby anything in ASKMe meanwhile.';
  }

  @override
  String get coursesNoFilterMatch => 'No chapters match these filters.';

  @override
  String get coursesFinishedEmpty => 'Finished chapters show up here.';

  @override
  String get coursesStartedEmpty => 'Chapters you’ve started show up here.';

  @override
  String get coursesGoAgain => 'Go again';

  @override
  String coursesContinueCard(int current, int total) {
    return 'Continue · card $current of $total';
  }

  @override
  String get coursesStart => 'Start';

  @override
  String get filterAll => 'All';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterDone => 'Done';

  @override
  String get filterFilters => 'Filters';

  @override
  String filterFiltersOn(int count) {
    return 'Filters, $count on';
  }

  @override
  String get filterClear => 'Clear';

  @override
  String get filterSort => 'SORT';

  @override
  String filterShowChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return 'Show $_temp0';
  }

  @override
  String get filterBoardExamOnly => 'Board exam only';

  @override
  String get filterBoardExamOnlyDesc => 'Hide school-assessed chapters';

  @override
  String get filterReadyToStudy => 'Ready to study';

  @override
  String get filterReadyToStudyDesc => 'Hide chapters still coming soon';

  @override
  String get filterRevisionDue => 'Revision due';

  @override
  String get filterRevisionDueDesc => 'Chapters with kept cards to revise';

  @override
  String get filterSortTextbook => 'Textbook';

  @override
  String get filterSortMostMarks => 'Most marks';

  @override
  String get filterSortRecent => 'Recent';

  @override
  String get filterFlagBoardExam => 'Board exam';

  @override
  String get filterFlagReady => 'Ready';

  @override
  String get filterFlagRevisionDue => 'Revision due';

  @override
  String filterRemove(String label) {
    return 'Remove $label';
  }

  @override
  String get folderNew => 'New folder';

  @override
  String get folderEdit => 'Edit folder';

  @override
  String get folderEmptyHint =>
      'Make a folder for a test, your homework, or anything you’re preparing. Add a date and it plans your days.';

  @override
  String get folderEmpty => 'Empty';

  @override
  String get folderNothingLeftToday => 'Nothing left today';

  @override
  String folderTodoToday(int count) {
    return '$count to do today';
  }

  @override
  String get folderNoDate => 'No date';

  @override
  String folderPercentReady(int percent) {
    return '$percent% ready';
  }

  @override
  String get folderWhatsFor => 'What’s this folder for?';

  @override
  String get folderAddChaptersPlan => 'Add chapters and Pebby plans your days.';

  @override
  String get folderAddChapters => 'Add chapters';

  @override
  String get folderFromSyllabus => 'From your syllabus';

  @override
  String get folderWriteNote => 'Write a note';

  @override
  String get folderNoteSubtitle => 'Anything you want to remember';

  @override
  String get folderScanNotes => 'Scan notes';

  @override
  String get folderScanNotesSubtitle => 'Photos of pages, made into a lesson';

  @override
  String get folderAddTodo => 'Add a to-do';

  @override
  String get folderAddDate => 'Add a date';

  @override
  String get folderRemoveDate => 'Remove date';

  @override
  String get folderReminders => 'Reminders for this folder';

  @override
  String get folderDeleteTitle => 'Delete this folder?';

  @override
  String get folderDeleteBody =>
      'Its notes and to-dos go too. Your lessons and progress stay.';

  @override
  String get folderTitle => 'Folder';

  @override
  String get folderEditRemindersTooltip => 'Edit and reminders';

  @override
  String get folderDeleteTooltip => 'Delete folder';

  @override
  String get folderLoadError => 'Couldn’t load this folder. Retry';

  @override
  String folderTodayMinutes(int minutes) {
    return 'Today · $minutes min';
  }

  @override
  String get folderSeePlan => 'See plan';

  @override
  String get folderAddChaptersOrTodos => 'Add chapters or to-dos.';

  @override
  String get folderNothingLeftForToday => 'Nothing left for today.';

  @override
  String get folderInThisFolder => 'In this folder';

  @override
  String get folderFromNotesDone => 'From your notes · done';

  @override
  String folderFromNotesMinutes(int minutes) {
    return 'From your notes · $minutes min';
  }

  @override
  String get folderNote => 'Note';

  @override
  String get folderSaveNote => 'Save note';

  @override
  String get folderTypeHere => 'Type here…';

  @override
  String get folderAddTo => 'Add to a folder';

  @override
  String get folderCouldntMake => 'Couldn’t make the folder. Try again.';

  @override
  String folderAddedTo(String name) {
    return 'Added to $name';
  }

  @override
  String get folderYourFolder => 'your folder';

  @override
  String get folderPlan => 'Plan';

  @override
  String folderPlanTo(String date) {
    return 'Plan to $date';
  }

  @override
  String get folderPlanBody =>
      'Made from the chapters in this folder. Missed something? It moves to the next day on its own.';

  @override
  String get folderTestDay => 'Test day · you’re ready';

  @override
  String get folderRestDay => 'Rest day';

  @override
  String get folderDueTomorrow => 'Tomorrow';

  @override
  String get folderDueYesterday => 'Yesterday';

  @override
  String folderDueDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0 ago';
  }

  @override
  String folderDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return 'in $_temp0';
  }

  @override
  String chapterTitle(int number) {
    return 'Chapter $number';
  }

  @override
  String get chapterLessons => 'Lessons';

  @override
  String get chapterTest => 'Chapter test';

  @override
  String chapterTestLast(int correct, int total) {
    return 'Last time $correct/$total · try again';
  }

  @override
  String chapterTestSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0 from every lesson';
  }

  @override
  String get chapterKeptCards => 'Kept cards';

  @override
  String get chapterKeptEmpty => 'Tap Keep on any card to save it here';

  @override
  String chapterKeptCount(int count) {
    return '$count to revise';
  }

  @override
  String get chapterAllDoneGoAgain => 'All lessons done · go again';

  @override
  String chapterResumeCard(int current, int total) {
    return 'Resume · card $current of $total';
  }

  @override
  String get chapterNextLesson => 'Next lesson';

  @override
  String chapterLessonMeta(int position, String cards) {
    return 'Lesson $position · $cards';
  }

  @override
  String chapterCardsRight(String cards, int correct, int quizzes) {
    return '$cards · $correct/$quizzes right';
  }

  @override
  String chapterCardsChecks(String cards, String checks) {
    return '$cards · $checks';
  }

  @override
  String chapterComingSoonLessons(String lessons) {
    return 'Coming soon · $lessons';
  }

  @override
  String get chapterLessonsDoneTestNext => 'Lessons done · test next';

  @override
  String chapterDoneTestPercent(int percent) {
    return 'Done · test $percent%';
  }

  @override
  String chapterComingSoonSuffix(int count) {
    return ' · $count coming soon';
  }

  @override
  String get chapterNotInBoardExamSuffix => ' · Not in board exam';

  @override
  String get chapterReportGreat => 'Great work';

  @override
  String get chapterReportGood => 'Good going';

  @override
  String get chapterReportRetry => 'Worth another go';

  @override
  String get chapterReportByLesson => 'By lesson';

  @override
  String chapterReportXp(String title, int xp) {
    return '$title · +$xp XP';
  }

  @override
  String get chapterReviseMissed => 'Revise what you missed';

  @override
  String get chapterAddToFolderAction => 'Add chapter to a folder';

  @override
  String get chapterBackToChapter => 'Back to chapter';

  @override
  String get chapterNoChaptersYet => 'No chapters for your class yet.';

  @override
  String get chapterAlreadyInFolder => 'Already in this folder';

  @override
  String chapterLessonsDoneShort(String lessons, int done) {
    return '$lessons · $done done';
  }

  @override
  String get chapterPickChapters => 'Pick chapters';

  @override
  String chapterAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return 'Add $_temp0';
  }

  @override
  String get chapterAddChaptersTitle => 'Add chapters';

  @override
  String get deckReportTitle => 'Report this lesson';

  @override
  String get deckReportThanks => 'Thanks. We’ll review this lesson.';

  @override
  String get deckLoadError => 'Couldn’t load this lesson. Retry';

  @override
  String get deckPerfect => 'Perfect lesson!';

  @override
  String get deckLessonDone => 'Lesson done!';

  @override
  String get deckStatRight => 'right';

  @override
  String get deckStatKept => 'kept';

  @override
  String deckNextTitle(String title) {
    return 'Next: $title';
  }

  @override
  String get deckStart => 'Start';

  @override
  String deckShowStep(int step) {
    return 'Show step $step';
  }

  @override
  String get deckCheck => 'Check';

  @override
  String get deckNext => 'Next';

  @override
  String get deckFinish => 'Finish';

  @override
  String get deckPreviousCard => 'Previous card';

  @override
  String get deckNewLesson => 'New lesson';

  @override
  String get deckByTheEnd => 'By the end you can:';

  @override
  String deckMetaLine(String cards, String checks, int minutes) {
    return '$cards · $checks · about $minutes min';
  }

  @override
  String get deckConcept => 'Concept';

  @override
  String get deckInOneLook => 'In one look';

  @override
  String get deckSummary => 'Summary';

  @override
  String get deckThreeLines => 'The lesson in three lines';

  @override
  String get deckKeptForRevision => 'Kept for revision';

  @override
  String get deckKeptRevisionOne =>
      '1 card from this lesson comes back in your revision.';

  @override
  String deckKeptRevisionMany(int count) {
    return '$count cards from this lesson come back in your revision.';
  }

  @override
  String get deckWorkedExample => 'Worked example';

  @override
  String deckStepTryFirst(int step) {
    return 'Step $step · try it first';
  }

  @override
  String get deckRemember => 'Remember';

  @override
  String get deckKept => 'Kept';

  @override
  String get deckAskPebby => 'Ask Pebby';

  @override
  String deckAskExplainSimply(String title, String body) {
    return 'Can you explain this more simply? $title: $body';
  }

  @override
  String deckAskExplainExample(String title) {
    return 'Can you explain \"$title\" with an example?';
  }

  @override
  String deckAskExplainSolve(String question) {
    return 'Can you explain how to solve: $question';
  }

  @override
  String deckAskWrongWhy(String question, String why) {
    return 'I got this wrong: $question Why is it: $why';
  }

  @override
  String get deckAskExplainLesson => 'Can you explain this lesson?';

  @override
  String get deckGoals => 'Goals';

  @override
  String get quizQuickCheck => 'Quick check';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizPraise1 => 'Nice! That’s right.';

  @override
  String get quizPraise2 => 'Spot on!';

  @override
  String get quizPraise3 => 'You got it!';

  @override
  String get quizPraise4 => 'Correct, well done!';

  @override
  String get quizPraise5 => 'Exactly right!';

  @override
  String get quizHeresWhy => 'Here’s why';

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizRightAnswer => 'Right answer';

  @override
  String get quizKeptForYou => 'Kept for you';

  @override
  String get quizComesBack =>
      'This question comes back in your revision tomorrow.';

  @override
  String get quizNotQuite => 'Not quite. Next: why.';

  @override
  String quizStreak(int count) {
    return '$count in a row';
  }

  @override
  String quizXpTag(int xp) {
    return '+$xp XP';
  }

  @override
  String get studyRevision => 'Revision';

  @override
  String get studyRevisionEmptyTitle => 'Nothing to revise';

  @override
  String get studyRevisionEmptyBody =>
      'Keep cards in a lesson, or miss a question, and they come back here.';

  @override
  String get studyRevisionDone => 'Revision done';

  @override
  String studyRevisionSummary(int knew, int almost, int again) {
    return '$knew knew it · $almost almost · $again to see again tomorrow';
  }

  @override
  String get studyRevisionHint => 'Think of the answer, then tap to check.';

  @override
  String get studyRevisionShowAnswer => 'Show answer';

  @override
  String get studyRevisionAgain => 'Didn’t know';

  @override
  String get studyRevisionAlmost => 'Almost';

  @override
  String get studyRevisionKnew => 'Knew it';

  @override
  String chapterTestDeckTitle(int number) {
    return 'Ch $number test';
  }

  @override
  String studyLessonsOf(int done, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$done of $_temp0';
  }

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get actionGoPro => 'Go Pro';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get failureNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get failureUnknown => 'Something went wrong. Try again.';
}
