import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_theme.dart';

class Keycap extends StatefulWidget {
  const Keycap({
    super.key,
    required this.face,
    required this.depth,
    required this.height,
    required this.child,
    this.onTap,
    this.isEnabled = true,
    this.isLatched = false,
    this.radius = AppKeycap.radius,
  });

  final Color face;
  final double depth;
  final double height;
  final Widget child;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLatched;
  final double radius;

  static Color faded(Color color, {required Color on}) =>
      Color.lerp(color, on, 1 - AppKeycap.disabledAlpha)!;

  @override
  State<Keycap> createState() => _KeycapState();
}

class _KeycapState extends State<Keycap> {
  bool _isHeld = false;

  void _setHeld(bool isHeld) {
    if (_isHeld != isHeld) setState(() => _isHeld = isHeld);
  }

  void _release() {
    _setHeld(false);
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final sink = widget.isLatched || _isHeld ? widget.depth : 0.0;
    final edge = widget.isEnabled
        ? context.palette.edge
        : Keycap.faded(context.palette.edge, on: context.palette.surface);
    final radius = BorderRadius.circular(widget.radius);

    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      selected: widget.isLatched,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.isEnabled ? (_) => _setHeld(true) : null,
        onTapUp: widget.isEnabled ? (_) => _release() : null,
        onTapCancel: () => _setHeld(false),
        child: SizedBox(
          height: widget.height + widget.depth,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: AppKeycap.pressDuration,
              curve: Curves.easeOut,
              width: double.infinity,
              height: widget.height,
              transform: Matrix4.translationValues(0, sink, 0),
              decoration: BoxDecoration(
                color: widget.face,
                borderRadius: radius,
                border: Border.all(color: edge, width: AppKeycap.borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: edge,
                    offset: Offset(0, widget.depth - sink),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
