import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

double _sink(WidgetTester tester) => tester
    .widget<AnimatedContainer>(find.byType(AnimatedContainer))
    .transform!
    .getTranslation()
    .y;

void main() {
  testWidgets('sinks into its edge while held and fires on release', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(
        AppButton(label: 'Get started', isPrimary: true, onTap: () => taps++),
      ),
    );
    expect(_sink(tester), 0);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Get started')),
    );
    await tester.pumpAndSettle();
    expect(_sink(tester), AppKeycap.buttonDepth);
    expect(taps, 0);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(_sink(tester), 0);
    expect(taps, 1);
  });

  testWidgets('a disabled button neither sinks nor fires', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(AppButton(label: 'Log in', isEnabled: false, onTap: () => taps++)),
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(_sink(tester), 0);
    expect(taps, 0);
  });

  testWidgets('fills the width it is given, not its label', (tester) async {
    await tester.pumpWidget(
      _host(const SizedBox(width: 300, child: AppButton(label: 'Go'))),
    );
    expect(tester.getSize(find.byType(AnimatedContainer)).width, 300);
  });
}
