import '../core/ui/shell_edge.dart';

abstract final class ShellTabs {
  static const home = 0;
  static const askMe = 1;
  static const scan = 2;
  static const study = 3;
  static const me = 4;

  static const pillOrder = [home, askMe, study, me];
  static const pageOrder = [home, askMe, study, me, scan];
  static const edgeWidth = ShellEdge.width;

  static int pageIndex(int tab) => pageOrder.indexOf(tab);

  static int? step(int current, int delta) {
    assert(delta == -1 || delta == 1);
    final i = pageOrder.indexOf(current);
    if (i < 0) return null;
    final j = i + delta;
    if (j < 0 || j >= pageOrder.length) return null;
    return pageOrder[j];
  }
}
