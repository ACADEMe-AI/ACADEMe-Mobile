import 'package:academe/ui/shell/shell_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pillOrder is Home, ASKMe, Study, Me', () {
    expect(ShellTabs.pillOrder, [0, 1, 3, 4]);
  });

  test('pageOrder is Home, ASKMe, Study, Me, Scan', () {
    expect(ShellTabs.pageOrder, [0, 1, 3, 4, 2]);
  });

  test('step walks pageOrder and hard-stops at the ends', () {
    expect(ShellTabs.step(0, -1), isNull);
    expect(ShellTabs.step(0, 1), 1);
    expect(ShellTabs.step(1, -1), 0);
    expect(ShellTabs.step(1, 1), 3);
    expect(ShellTabs.step(3, -1), 1);
    expect(ShellTabs.step(3, 1), 4);
    expect(ShellTabs.step(4, -1), 3);
    expect(ShellTabs.step(4, 1), 2);
    expect(ShellTabs.step(2, -1), 4);
    expect(ShellTabs.step(2, 1), isNull);
  });
}
