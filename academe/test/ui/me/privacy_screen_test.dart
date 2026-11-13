import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/l10n/generated/app_localizations_en.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/me/widgets/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('privacy summary and links to the published pages', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final l10n = AppLocalizationsEn();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.dark(),
        home: const PrivacyScreen(),
      ),
    );

    for (final line in PrivacyScreen.summary(l10n)) {
      expect(find.text(line), findsOneWidget);
    }
    for (final label in [
      l10n.privacyPolicy,
      l10n.privacyTermsOfUse,
      l10n.privacyGetCopy,
      l10n.privacyGrievanceOfficer,
      'support@academe.cc',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Coming before launch.'), findsNothing);
  });
}
