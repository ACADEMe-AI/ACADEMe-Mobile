import '../core/ui/shell_edge.dart';

/// Shared bottom-pill tab order for nav and edge swipe.
///
/// Scan (index 2) is the center action and is not a pill peer.
abstract final class ShellTabs {
  static const pillOrder = [0, 1, 3, 4]; // Home, ASKMe, Study, Me
  static const home = 0;
  static const askMe = 1;
  static const scan = 2;
  static const study = 3;
  static const me = 4;
  static const edgeWidth = ShellEdge.width;

  /// Next pill tab for [delta] (-1 previous, +1 next), or null at a hard stop.
  /// From Scan, previous is ASKMe and next is Study.
  static int? step(int current, int delta) {
    assert(delta == -1 || delta == 1);
    if (current == scan) return delta < 0 ? askMe : study;
    final i = pillOrder.indexOf(current);
    if (i < 0) return null;
    final j = i + delta;
    if (j < 0 || j >= pillOrder.length) return null;
    return pillOrder[j];
  }

  /// Edge-swipe card motion only for ASKMe ↔ Home and ASKMe ↔ Study.
  static bool useCardSwipe(int from, int to) {
    bool pair(int a, int b) =>
        (from == a && to == b) || (from == b && to == a);
    return pair(askMe, home) || pair(askMe, study);
  }
}
