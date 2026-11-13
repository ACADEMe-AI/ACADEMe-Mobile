abstract final class ShellEdge {
  static const width = 36.0;

  static bool contains(double localX, double layoutWidth) =>
      localX <= width || localX >= layoutWidth - width;
}
