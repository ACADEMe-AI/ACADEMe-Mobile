import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/scan.dart';

void main() {
  setUpJourney();

  testWidgets('Check my answer marks a handwritten answer', (tester) async {
    await newStudent(tester, 'check');
    await startScan(tester, 'Check my answer');
    await pickFromGallery(tester, 'answer.png');
    await tester.waitFor(
      find.text('Pebby read your answer'),
      timeout: const Duration(seconds: 120),
    );
    final read = tester.widget<TextField>(
      find.widgetWithText(TextField, 'From your photo'),
    );
    expect(read.controller!.text.toLowerCase(), contains('photosynthesis'));
    await tester.shot('read');
    await tester.tapText('Mark it');
    await tester.waitFor(
      find.text('What got marks'),
      timeout: const Duration(seconds: 120),
    );
    expect(find.textContaining(RegExp(r'^\d+/\d+$')), findsWidgets);
    await tester.shot('marks');
  });
}
