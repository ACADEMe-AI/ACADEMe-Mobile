import 'package:academe/ui/shell/shell_tabs.dart';
import 'package:academe/ui/shell/widgets/shell_pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpPager(
    WidgetTester tester, {
    required int tab,
    required ValueChanged<int> onTab,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ShellPager(
              tabIndex: tab,
              onTabIndex: onTab,
              children: [
                for (final id in ShellTabs.pageOrder)
                  ColoredBox(
                    key: ValueKey('page-$id'),
                    color: Colors.blue,
                    child: Center(child: Text('tab-$id')),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Me swipe left commits Scan', (tester) async {
    var tab = ShellTabs.me;
    await pumpPager(tester, tab: tab, onTab: (t) => tab = t);

    await tester.drag(find.text('tab-${ShellTabs.me}'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(tab, ShellTabs.scan);
    expect(find.text('tab-${ShellTabs.scan}'), findsOneWidget);
  });

  testWidgets('Scan swipe right commits Me', (tester) async {
    var tab = ShellTabs.scan;
    await pumpPager(tester, tab: tab, onTab: (t) => tab = t);

    await tester.drag(find.text('tab-${ShellTabs.scan}'), const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(tab, ShellTabs.me);
    expect(find.text('tab-${ShellTabs.me}'), findsOneWidget);
  });

  testWidgets('nav tab change animates to target page', (tester) async {
    var tab = ShellTabs.home;
    late StateSetter setPage;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              setPage = setState;
              return Scaffold(
                body: ShellPager(
                  tabIndex: tab,
                  onTabIndex: (t) => setState(() => tab = t),
                  children: [
                    for (final id in ShellTabs.pageOrder)
                      Center(child: Text('tab-$id')),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('tab-${ShellTabs.home}'), findsOneWidget);

    setPage(() => tab = ShellTabs.me);
    await tester.pumpAndSettle();
    expect(find.text('tab-${ShellTabs.me}'), findsOneWidget);
  });

  testWidgets('horizontal child scroller keeps shell on the same tab', (
    tester,
  ) async {
    var tab = ShellTabs.study;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: ShellPager(
              tabIndex: tab,
              onTabIndex: (t) => tab = t,
              children: [
                for (final id in ShellTabs.pageOrder)
                  id == ShellTabs.study
                      ? ListView(
                          key: const ValueKey('h-scroll'),
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (var i = 0; i < 8; i++)
                              SizedBox(
                                width: 200,
                                child: Center(child: Text('chip-$i')),
                              ),
                          ],
                        )
                      : Center(child: Text('tab-$id')),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.text('chip-0'), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(tab, ShellTabs.study);
  });

  testWidgets('short tap during settle does not freeze the page', (tester) async {
    var tab = ShellTabs.home;
    late StateSetter setPage;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setPage = setState;
            return Scaffold(
              body: ShellPager(
                tabIndex: tab,
                onTabIndex: (t) => setState(() => tab = t),
                children: [
                  for (final id in ShellTabs.pageOrder)
                    Center(child: Text('tab-$id')),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    setPage(() => tab = ShellTabs.study);
    await tester.pump(const Duration(milliseconds: 40));
    final center = tester.getCenter(find.byType(ShellPager));
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    expect(find.text('tab-${ShellTabs.study}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
