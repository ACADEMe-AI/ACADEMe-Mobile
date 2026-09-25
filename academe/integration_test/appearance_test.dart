import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('Appearance switches to dark and back to light', (tester) async {
    await newStudent(tester, 'appearance');
    bool isDark() => tester
        .widget<MaterialApp>(find.byType(MaterialApp))
        .theme!
        .extension<AppPalette>()!
        .isDark;
    expect(isDark(), isFalse);
    await tester.tapText('Me');
    await tester.tapText('Appearance');
    await tester.waitFor(
      find.text('Dark mode is easier on your eyes at night.'),
    );
    await tester.tapText('Dark');
    await tester.waitFor(find.text('Lights off…'));
    await tester.shot('switching-dark');
    await tester.waitGone(find.text('Lights off…'));
    expect(isDark(), isTrue);
    await tester.shot('dark');
    await tester.tapText('Light');
    await tester.waitFor(find.text('Good morning!'));
    await tester.waitGone(find.text('Good morning!'));
    expect(isDark(), isFalse);
    await tester.shot('light');
  });
}
