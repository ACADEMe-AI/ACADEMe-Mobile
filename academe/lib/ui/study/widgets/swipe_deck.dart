import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.top,
    required this.hasUnder,
    required this.canForward,
    required this.canBack,
    required this.onForward,
    required this.onBack,
  });

  final Widget top;
  final bool hasUnder;
  final bool canForward;
  final bool canBack;
  final VoidCallback onForward;
  final VoidCallback onBack;

  static const fly = Duration(milliseconds: 220);
  static const peek = 12.0;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  late final _drag = AnimationController.unbounded(vsync: this);
  double _width = 1;

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final isBlocked =
        (_drag.value + dx < 0 && !widget.canForward) ||
        (_drag.value + dx > 0 && !widget.canBack);
    _drag.value += isBlocked ? dx * .25 : dx;
  }

  Future<void> _end(DragEndDetails details) async {
    final velocity = details.primaryVelocity ?? 0;
    final dx = _drag.value;
    final threshold = _width * .25;
    if (widget.canForward && (dx < -threshold || velocity < -700)) {
      await _animateTo(-_width * 1.3);
      widget.onForward();
    } else if (widget.canBack && (dx > threshold || velocity > 700)) {
      await _animateTo(_width * 1.3);
      widget.onBack();
    } else {
      await _animateTo(0);
    }
  }

  Future<void> _animateTo(double target) async {
    if (MediaQuery.disableAnimationsOf(context)) {
      _drag.value = target;
      return;
    }
    await _drag.animateTo(
      target,
      duration: SwipeDeck.fly,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _update,
          onHorizontalDragEnd: _end,
          child: AnimatedBuilder(
            animation: _drag,
            child: widget.top,
            builder: (context, top) {
              final dx = _drag.value;
              final lift = (dx.abs() / _width).clamp(0.0, 1.0);
              return Stack(
                children: [
                  if (widget.hasUnder)
                    Positioned.fill(
                      child: Transform.scale(
                        scale: .92 + .08 * lift,
                        alignment: Alignment.bottomCenter,
                        child: const DeckCardFrame(isUnder: true),
                      ),
                    ),
                  Positioned.fill(
                    bottom: SwipeDeck.peek,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: Transform.rotate(
                        angle: dx / _width * .12,
                        child: top,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class DeckCardFrame extends StatelessWidget {
  const DeckCardFrame({super.key, this.child, this.isUnder = false});

  final Widget? child;
  final bool isUnder;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isUnder ? palette.tintLavender : palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: palette.edge, width: AppKeycap.borderWidth),
        boxShadow: [BoxShadow(color: palette.edge, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
