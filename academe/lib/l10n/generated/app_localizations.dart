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
