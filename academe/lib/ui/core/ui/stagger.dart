import 'package:flutter/material.dart';

import 'rise_in.dart';

class Stagger extends StatefulWidget {
  const Stagger({
    super.key,
    required this.children,
    this.gap = 12,
    this.delay = Duration.zero,
    this.step = const Duration(milliseconds: 70),
  });

  final List<Widget> children;
  final double gap;
  final Duration delay;
  final Duration step;

  @override
  State<Stagger> createState() => _StaggerState();
}

class _StaggerState extends State<Stagger> with SingleTickerProviderStateMixin {
  static const _rise = Duration(milliseconds: 420);

  late final Duration _total =
      widget.delay + widget.step * widget.children.length + _rise;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _entryFor(int index) {
    final start = widget.delay + widget.step * index;
    final total = _total.inMicroseconds;
    return _controller.drive(
      CurveTween(
        curve: Interval(
          start.inMicroseconds / total,
          ((start + _rise).inMicroseconds / total).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(height: widget.gap),
          RiseIn(animation: _entryFor(i), child: widget.children[i]),
        ],
      ],
    );
  }
}
