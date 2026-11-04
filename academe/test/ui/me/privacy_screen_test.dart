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
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const PrivacyScreen()),
    );

    for (final line in PrivacyScreen.summary) {
      expect(find.text(line), findsOneWidget);
    }
    for (final label in [
      'Privacy policy',
      'Terms of use',
      'Get a copy of my data',
      'Grievance Officer',
      'support@academe.cc',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Coming before launch.'), findsNothing);
  });
}
