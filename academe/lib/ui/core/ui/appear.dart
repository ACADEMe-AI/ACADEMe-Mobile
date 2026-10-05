import 'package:flutter/material.dart';

class Appear extends StatefulWidget {
  const Appear({super.key, required this.child, this.rise = 12});

  final Widget child;
  final double rise;

  static const duration = Duration(milliseconds: 380);

  @override
  State<Appear> createState() => _AppearState();
}

class _AppearState extends State<Appear> with SingleTickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: Appear.duration,
  )..forward();
  late final Animation<double> _curve = CurvedAnimation(
    parent: _in,
    curve: Curves.easeOutBack,
  );

  @override
  void dispose() {
    _in.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, (1 - _curve.value) * widget.rise),
        child: child,
      ),
      child: FadeTransition(opacity: _in, child: widget.child),
    );
  }
}
