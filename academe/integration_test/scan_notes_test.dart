import 'package:flutter_test/flutter_test.dart';

import 'support/driver.dart';
import 'support/flows.dart';
import 'support/folders.dart';
import 'support/scan.dart';

void main() {
  setUpJourney();

  testWidgets('Notes photo becomes a swipe lesson in a folder', (tester) async {
    await newStudent(tester, 'notes');
    await createFolder(tester, 'Light notes');
    await tester.tapText('Scan notes');
    await pickFromGallery(tester, 'notes.png');
    await tester.waitFor(
      find.text('Read 1 page'),
      timeout: const Duration(seconds: 60),
    );
    await tester.shot('pages');
    await tester.tapText('Read 1 page');
    await tester.waitFor(
      find.text('Swipe lesson'),
      timeout: const Duration(seconds: 120),
    );
    await tester.shot('notes-read');
    await tester.tapText('Swipe lesson');
    await tester.waitFor(
      find.text('Light notes'),
      timeout: const Duration(seconds: 180),
    );
    await tester.shot('lesson-in-folder');
  });
}
