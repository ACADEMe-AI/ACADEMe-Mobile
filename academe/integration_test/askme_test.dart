import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';

void main() {
  setUpJourney();

  testWidgets('ASKMe answers a real question through Sarvam', (tester) async {
    await newStudent(tester, 'askme');
    await tester.tapText('ASKMe');
    await tester.waitFor(find.textContaining('What are we studying'));
    await tester.shot('askme-empty');
    await tester.fill(
      'Ask anything…',
      'What is photosynthesis? Answer in two lines.',
    );
    await tester.tapIcon(Icons.arrow_upward_rounded);
    await tester.waitFor(
      find.text('What is photosynthesis? Answer in two lines.'),
    );
    await tester.shot('asked');
    await tester.waitFor(
      find.byTooltip('Helpful'),
      timeout: const Duration(seconds: 120),
    );
    expect(
      find.textContaining(
        RegExp('sunlight|chlorophyll|glucose|food', caseSensitive: false),
      ),
      findsWidgets,
    );
    await tester.shot('reply');
  });
}
