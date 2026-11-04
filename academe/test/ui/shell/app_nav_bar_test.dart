import 'package:academe/ui/core/themes/app_theme.dart';
import 'package:academe/ui/core/ui/ask_me_icon.dart';
import 'package:academe/ui/shell/widgets/app_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<List<int>> pumpBar(WidgetTester tester, {int selected = 0}) async {
    final taps = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppNavBar(
            selected: selected,
            onSelect: taps.add,
          ),
        ),
      ),
    );
    return taps;
  }

  testWidgets('every tab reports its index, and the camera key opens Scan', (
    tester,
  ) async {
    final taps = await pumpBar(tester);

    for (final label in ['Home', 'ASKMe', 'Study', 'Me']) {
      await tester.tap(find.text(label));
    }
    await tester.pump(AppKeycap.pressDuration);

    expect(taps, [0, 1, 3, 4]);
    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pump(AppKeycap.pressDuration);
    expect(taps.last, AppNavBar.scanIndex);
  });

  testWidgets('the selected tab turns purple, the others stay muted', (
    tester,
  ) async {
    await pumpBar(tester, selected: 1);

    Color colorOf(String label) =>
        tester.widget<Text>(find.text(label)).style!.color!;
    expect(colorOf('ASKMe'), AppColors.primary);
    expect(colorOf('Home'), AppColors.lightTextMuted);
    expect(find.byType(AskMeIcon), findsOneWidget);
  });

  testWidgets('asking turns the tabs into the ask bar and the key into send', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var sent = 0;
    var attached = 0;
    Future<void> pumpAsk({required bool canSend}) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppNavBar(
            selected: 1,
            onSelect: (_) {},
            isAsking: true,
            askController: controller,
            canSend: canSend,
            onSend: () => sent++,
            onAttach: () => attached++,
          ),
        ),
      ),
    );

    await pumpAsk(canSend: false);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsNothing);
    expect(find.text('Ask anything…'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump(AppKeycap.pressDuration);
    expect(sent, 0);

    await pumpAsk(canSend: true);
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pump(AppKeycap.pressDuration);
    expect(sent, 1);

    await tester.tap(find.byTooltip('Attach'));
    expect(attached, 1);
  });

  testWidgets('the tabs slide out left while the ask field slides in', (
    tester,
  ) async {
    Widget bar({required bool isAsking}) => MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AppNavBar(
          selected: 0,
          onSelect: (_) {},
          isAsking: isAsking,
        ),
      ),
    );

    await tester.pumpWidget(bar(isAsking: false));
    final homeAtRest = tester.getCenter(find.text('Home')).dx;

    await tester.pumpWidget(bar(isAsking: true));
    await tester.pump(AppNavBar.morph ~/ 2);
    final askField = tester.getCenter(find.text('Ask anything…')).dx;
    final homeMoving = tester.getCenter(find.text('Home')).dx;
    expect(homeMoving, lessThan(homeAtRest));

    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('Ask anything…')).dx, lessThan(askField));
    expect(find.text('Home'), findsNothing);
  });
}
