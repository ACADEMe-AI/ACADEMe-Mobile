/// Horizontal edge band used by shell tab swipe and ASKMe mode swipe.
///
/// Both callers must pass **layout-local** X and the same layout width so the
/// zones stay aligned (content box, not raw screen width on wide layouts).
abstract final class ShellEdge {
  static const width = 24.0;

  static bool contains(double localX, double layoutWidth) =>
      localX <= width || localX >= layoutWidth - width;
}
