import 'package:academe/ui/shell/shell_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pillOrder is Home, ASKMe, Study, Me', () {
    expect(ShellTabs.pillOrder, [0, 1, 3, 4]);
  });

  test('step walks the pill order and hard-stops at the ends', () {
    expect(ShellTabs.step(0, -1), isNull);
    expect(ShellTabs.step(0, 1), 1);
    expect(ShellTabs.step(1, -1), 0);
    expect(ShellTabs.step(1, 1), 3);
    expect(ShellTabs.step(3, -1), 1);
    expect(ShellTabs.step(3, 1), 4);
    expect(ShellTabs.step(4, -1), 3);
    expect(ShellTabs.step(4, 1), isNull);
  });

  test('step from Scan goes to ASKMe or Study and never returns Scan', () {
    expect(ShellTabs.step(2, -1), 1);
    expect(ShellTabs.step(2, 1), 3);
    for (final tab in [...ShellTabs.pillOrder, 2]) {
      for (final delta in [-1, 1]) {
        final next = ShellTabs.step(tab, delta);
        expect(next, isNot(2), reason: 'step($tab, $delta)');
      }
    }
  });

  test('useCardSwipe only for ASKMe paired with Home or Study', () {
    expect(ShellTabs.useCardSwipe(1, 0), isTrue);
    expect(ShellTabs.useCardSwipe(0, 1), isTrue);
    expect(ShellTabs.useCardSwipe(1, 3), isTrue);
    expect(ShellTabs.useCardSwipe(3, 1), isTrue);
    expect(ShellTabs.useCardSwipe(3, 4), isFalse);
    expect(ShellTabs.useCardSwipe(4, 3), isFalse);
    expect(ShellTabs.useCardSwipe(0, 3), isFalse);
    expect(ShellTabs.useCardSwipe(2, 1), isFalse);
  });
}
