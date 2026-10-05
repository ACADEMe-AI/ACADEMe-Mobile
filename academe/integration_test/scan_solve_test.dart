import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/scan.dart';

void main() {
  setUpJourney();

  testWidgets('Solve homework from a gallery photo ends in ASKMe', (
    tester,
  ) async {
    await newStudent(tester, 'solve');
    await startScan(tester, 'Solve homework');
    await pickFromGallery(tester, 'homework.png');
    await tester.waitFor(
      find.text('Pebby read this'),
      timeout: const Duration(seconds: 120),
    );
    final read = tester.widget<TextField>(
      find.widgetWithText(TextField, 'From your photo'),
    );
    expect(read.controller!.text, contains('3x'));
    await tester.shot('read');
    await tester.tapText('Solve this');
    await tester.waitFor(
      find.byTooltip('Helpful'),
      timeout: const Duration(seconds: 120),
    );
    await tester.shot('askme-reply');
  });
}
