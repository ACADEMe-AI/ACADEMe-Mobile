import 'package:academe/ui/core/ui/pebby.dart';
import 'package:academe/ui/splash/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calls onDone once, when the fade completes', (tester) async {
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => PebbyStandIn(child: child!),
        home: SplashScreen(onDone: () => done++),
      ),
    );

    await tester.pump(const Duration(milliseconds: 2600));
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 200));
    expect(done, 1);
  });
}
