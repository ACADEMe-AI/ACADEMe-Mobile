import 'package:academe/ui/core/ui/shell_edge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contains is layout-local left and right bands', () {
    expect(ShellEdge.contains(0, 400), isTrue);
    expect(ShellEdge.contains(ShellEdge.width, 400), isTrue);
    expect(ShellEdge.contains(ShellEdge.width + 1, 400), isFalse);
    expect(ShellEdge.contains(400 - ShellEdge.width, 400), isTrue);
    expect(ShellEdge.contains(200, 400), isFalse);
  });
}
