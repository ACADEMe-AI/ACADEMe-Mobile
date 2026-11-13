import 'package:flutter/material.dart';

import '../../core/ui/shell_edge.dart';

/// Horizontal drag from the left/right edge reports a pill-tab step delta.
class ShellEdgeSwipe extends StatefulWidget {
  const ShellEdgeSwipe({super.key, required this.onStep, required this.child});

  /// `-1` previous pill tab, `+1` next.
  final ValueChanged<int> onStep;
  final Widget child;

  @override
  State<ShellEdgeSwipe> createState() => _ShellEdgeSwipeState();
}

class _ShellEdgeSwipeState extends State<ShellEdgeSwipe> {
  int? _edge; // -1 left, +1 right
  double _dx = 0;
  double _dy = 0;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) {
        final box = context.findRenderObject() as RenderBox?;
        final width = box?.size.width ?? 0;
        final x = e.localPosition.dx;
        if (width <= 0 || !ShellEdge.contains(x, width)) {
          _edge = null;
          return;
        }
        _edge = x <= ShellEdge.width ? -1 : 1;
        _dx = 0;
        _dy = 0;
      },
      onPointerMove: (e) {
        if (_edge == null) return;
        _dx += e.delta.dx;
        _dy += e.delta.dy;
      },
      onPointerUp: (_) => _finish(),
      onPointerCancel: (_) {
        _edge = null;
        _dx = 0;
        _dy = 0;
      },
      child: widget.child,
    );
  }

  void _finish() {
    final edge = _edge;
    final dx = _dx;
    final dy = _dy;
    _edge = null;
    _dx = 0;
    _dy = 0;
    if (edge == null) return;
    if (dx.abs() < 40 || dx.abs() <= dy.abs()) return;
    // Left edge + drag right → previous; right edge + drag left → next.
    if (edge < 0 && dx > 0) {
      widget.onStep(-1);
    } else if (edge > 0 && dx < 0) {
      widget.onStep(1);
    }
  }
}
