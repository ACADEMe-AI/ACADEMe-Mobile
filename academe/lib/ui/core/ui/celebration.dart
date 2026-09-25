import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_theme.dart';

class OneShot extends StatefulWidget {
  const OneShot({
    super.key,
    required this.duration,
    required this.builder,
    this.curve = Curves.linear,
    this.delay = Duration.zero,
    this.haptic,
    this.child,
  });

  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Future<void> Function()? haptic;
  final Widget Function(BuildContext context, double t, Widget? child) builder;
  final Widget? child;

  @override
  State<OneShot> createState() => _OneShotState();
}

class _OneShotState extends State<OneShot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _start;

  @override
  void initState() {
    super.initState();
    widget.haptic?.call();
    _start = Timer(widget.delay, _play);
  }

  void _play() {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) => widget.builder(
        context,
        widget.curve.transform(_controller.value),
        child,
      ),
    );
  }
}

class Burst extends StatelessWidget {
  const Burst({
    super.key,
    this.size = 72,
    this.dots = 10,
    this.duration = const Duration(milliseconds: 650),
    this.delay = Duration.zero,
  });

  final double size;
  final int dots;
  final Duration duration;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: OneShot(
          duration: duration,
          delay: delay,
          curve: Curves.easeOutCubic,
          builder: (context, t, _) =>
              CustomPaint(painter: _BurstPainter(t, dots)),
        ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t, this.dots);

  final double t;
  final int dots;

  static const _colors = [
    AppColors.selected,
    AppColors.primary,
    AppColors.success,
    AppColors.streak,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 0 || t == 1) return;
    final center = size.center(Offset.zero);
    final reach = size.shortestSide / 2;
    for (var i = 0; i < dots; i++) {
      final angle = i * 2 * math.pi / dots + (i.isEven ? 0 : .2);
      final distance = reach * (.25 + .75 * t) * (i.isEven ? 1 : .8);
      final spot = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        spot,
        (i.isEven ? 4.5 : 3.2) * (1 - t * .6),
        Paint()..color = _colors[i % _colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.haptic = false});

  final Widget child;
  final bool haptic;

  @override
  Widget build(BuildContext context) {
    return OneShot(
      duration: const Duration(milliseconds: 360),
      haptic: haptic ? HapticFeedback.mediumImpact : null,
      child: child,
      builder: (context, t, child) {
        final scale = t < .5
            ? 1 + .12 * (t / .5)
            : 1.12 - .12 * ((t - .5) / .5);
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

class Shake extends StatelessWidget {
  const Shake({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OneShot(
      duration: const Duration(milliseconds: 380),
      haptic: HapticFeedback.lightImpact,
      child: child,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(math.sin(t * math.pi * 5) * 6 * (1 - t), 0),
        child: child,
      ),
    );
  }
}

class FloatUp extends StatefulWidget {
  const FloatUp({super.key, required this.child});

  final Widget child;

  @override
  State<FloatUp> createState() => _FloatUpState();
}

class _FloatUpState extends State<FloatUp> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final _fade = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 20),
    TweenSequenceItem(tween: ConstantTween(1), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 30),
  ]).animate(_controller);
  late final _rise = Tween(
    begin: Offset.zero,
    end: const Offset(0, -1.6),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.value = 1;
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _rise, child: widget.child),
      ),
    );
  }
}

class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.prefix = '',
  });

  final int value;
  final TextStyle style;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return OneShot(
      duration: const Duration(milliseconds: 700),
      delay: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) =>
          Text('$prefix${(value * t).round()}', style: style),
    );
  }
}
