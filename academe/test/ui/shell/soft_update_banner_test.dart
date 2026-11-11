import 'package:academe/domain/models/app_config.dart';
import 'package:academe/l10n/generated/app_localizations.dart';
import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/shell/widgets/soft_update_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('soft update banner shows message and actions', (tester) async {
    var dismissed = false;
    final config = AppConfig(
      minBuild: 0,
      recommendedBuild: 99,
      updateMessage: 'Bug fixes on Play.',
      updateUrl: Uri.parse(
        'https://play.google.com/store/apps/details?id=com.academe.flutter',
      ),
    );
    await tester.pumpWidget(
      PebbyStandIn(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.dark(),
          home: Scaffold(
            body: SoftUpdateBanner(
              config: config,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bug fixes on Play.'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    await tester.tap(find.byTooltip('Not now'));
    expect(dismissed, isTrue);
  });
}
