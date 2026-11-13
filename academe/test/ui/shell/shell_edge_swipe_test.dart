import 'package:academe/ui/core/ui/shell_edge.dart';
import 'package:academe/ui/shell/widgets/shell_edge_swipe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const surface = Key('surface');

  Future<void> pumpSwipe(WidgetTester tester, List<int> steps) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShellEdgeSwipe(
            onStep: steps.add,
            child: const SizedBox.expand(
              child: ColoredBox(key: surface, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('left edge drag right steps previous; right edge drag left next', (
    tester,
  ) async {
    final steps = <int>[];
    await pumpSwipe(tester, steps);

    final center = tester.getCenter(find.byKey(surface));
    await tester.dragFrom(
      Offset(ShellEdge.width / 2, center.dy),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();
    expect(steps, [-1]);

    final size = tester.getSize(find.byKey(surface));
    await tester.dragFrom(
      Offset(size.width - ShellEdge.width / 2, center.dy),
      const Offset(-80, 0),
    );
    await tester.pumpAndSettle();
    expect(steps, [-1, 1]);
  });

  testWidgets('middle drag does not step shell tabs', (tester) async {
    final steps = <int>[];
    await pumpSwipe(tester, steps);
    await tester.drag(find.byKey(surface), const Offset(-100, 0));
    await tester.pumpAndSettle();
    expect(steps, isEmpty);
  });
}
