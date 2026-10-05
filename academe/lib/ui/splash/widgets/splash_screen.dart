import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/motion/keyframes.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2700);

  static const _pebbyX = [
    Keyframe(950, 104),
    Keyframe(1350, 44, Curves.easeOutCubic),
    Keyframe(1480, 48, Curves.easeOutBack),
    Keyframe(2050, 48),
    Keyframe(2360, 110, Curves.easeInCubic),
  ];
  static const _pebbyY = [
    Keyframe(950, 14),
    Keyframe(1350, 6, Curves.easeOutCubic),
    Keyframe(1480, 8, Curves.easeOutBack),
    Keyframe(2050, 8),
    Keyframe(2360, 16, Curves.easeInCubic),
  ];
  static const _pebbyTilt = [
    Keyframe(950, -26),
    Keyframe(1350, -15, Curves.easeOutCubic),
    Keyframe(1480, -17, Curves.easeOutBack),
    Keyframe(1780, -13, Curves.easeInOutCubic),
    Keyframe(2050, -16, Curves.easeInOutCubic),
    Keyframe(2360, -28, Curves.easeInCubic),
  ];
  static const _pebbyScale = [
    Keyframe(950, .96),
    Keyframe(1350, 1.03, Curves.easeOutCubic),
    Keyframe(1480, 1, Curves.easeOutBack),
    Keyframe(2050, 1),
    Keyframe(2360, .97, Curves.easeInCubic),
  ];

  late final AnimationController _controller;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _whiteFade;
  final _pose = ValueNotifier<double>(PebbyPose.peekRight);

  double get _elapsedMs => _controller.value * _duration.inMilliseconds;

  Animation<double> _between(double fromMs, double toMs, Curve curve) {
    final total = _duration.inMilliseconds;
    return _controller.drive(
      CurveTween(curve: Interval(fromMs / total, toMs / total, curve: curve)),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addListener(_syncPose)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone?.call();
      });
    final markExit = _between(800, 950, Curves.easeInCubic);
    _markOpacity = markExit.drive(Tween<double>(begin: 1, end: 0));
    _markScale = markExit.drive(Tween<double>(begin: 1, end: .94));
    _whiteFade = _between(2200, 2700, Curves.easeInOutCubic);
    _controller.forward();
  }

  void _syncPose() {
    final ms = _elapsedMs;
    _pose.value = ms >= 1320 && ms < 2070
        ? PebbyPose.wave
        : PebbyPose.peekRight;
  }

  @override
  void dispose() {
    _controller.dispose();
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splash,
      body: LayoutBuilder(
        builder: (context, box) => Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: FadeTransition(
                opacity: _markOpacity,
                child: ScaleTransition(
                  scale: _markScale,
                  child: Image.asset(
                    'assets/academe/raster/logo_mark.png',
                    width: 127,
                  ),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final ms = _elapsedMs;
                return Transform.translate(
                  offset: Offset(
                    box.maxWidth * sampleKeyframes(_pebbyX, ms) / 100,
                    box.maxHeight * sampleKeyframes(_pebbyY, ms) / 100,
                  ),
                  child: Transform.rotate(
                    angle: sampleKeyframes(_pebbyTilt, ms) * math.pi / 180,
                    child: Transform.scale(
                      scale: sampleKeyframes(_pebbyScale, ms),
                      child: child,
                    ),
                  ),
                );
              },
              child: Center(
                child: SizedBox.square(
                  dimension: box.maxWidth * .74,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _pose,
                    builder: (context, pose, _) => Pebby(pose: pose),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: FadeTransition(
                opacity: _whiteFade,
                child: const ColoredBox(color: AppColors.lightSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
