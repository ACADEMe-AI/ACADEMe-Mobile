import 'package:flutter_test/flutter_test.dart';

import 'driver.dart';

Future<void> pickFromGallery(WidgetTester tester, String image) async {
  bridge('push $image');
  await tester.pause(const Duration(seconds: 5));
  await tester.tapText('Choose from gallery');
  await tester.pause(const Duration(seconds: 2));
  bridge('shot photo-picker');
  bridge('pick-photo');
}

Future<void> startScan(WidgetTester tester, String mode) async {
  await tester.tapText('Home');
  await tester.tapText(mode);
  await tester.waitFor(find.text('Choose from gallery'));
}
