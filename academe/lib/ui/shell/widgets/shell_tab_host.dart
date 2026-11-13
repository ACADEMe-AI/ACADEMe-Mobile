import 'package:flutter/material.dart';

/// Keeps all tab children alive (like [IndexedStack]) and optionally slides
/// between two tabs for a card-style edge swipe.
class ShellTabHost extends StatelessWidget {
  const ShellTabHost({
    super.key,
    required this.index,
    required this.children,
    this.transition,
  });

  final int index;
  final List<Widget> children;

  /// When non-null, slides [ShellTabTransition.from] out and
  /// [ShellTabTransition.to] in.
  final ShellTabTransition? transition;

  static const _idle = AlwaysStoppedAnimation<double>(0);

  @override
  Widget build(BuildContext context) {
    final t = transition;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < children.length; i++)
              _slot(i, t, width, children[i]),
          ],
        );
      },
    );
  }

  Widget _slot(int i, ShellTabTransition? t, double width, Widget child) {
    final animating = t != null && (i == t.from || i == t.to);
    final showing = t == null ? i == index : animating;
    return Positioned.fill(
      child: Offstage(
        offstage: !showing,
        child: TickerMode(
          enabled: showing,
          child: AnimatedBuilder(
            animation: animating ? t.animation : _idle,
            builder: (context, child) {
              if (!animating) return child!;
              final progress = t.animation.value;
              final dir = t.delta > 0 ? 1.0 : -1.0;
              final double dx;
              if (i == t.from) {
                dx = -dir * progress * width;
              } else {
                dx = dir * (1 - progress) * width;
              }
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}

class ShellTabTransition {
  const ShellTabTransition({
    required this.from,
    required this.to,
    required this.delta,
    required this.animation,
  });

  final int from;
  final int to;

  /// `+1` next (to from the right), `-1` previous (to from the left).
  final int delta;
  final Animation<double> animation;
}
