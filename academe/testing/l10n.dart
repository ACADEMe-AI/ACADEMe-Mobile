import 'package:academe/domain/models/app_language.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension L10nTester on WidgetTester {
  Future<void> pumpL10n(
    Widget child, {
    AppLanguage language = AppLanguage.english,
  }) {
    return pumpWidget(
      MaterialApp(
        locale: language.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }
}
