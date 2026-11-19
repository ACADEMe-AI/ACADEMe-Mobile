import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class PebbyPeek extends StatefulWidget {
  const PebbyPeek({super.key, this.size = 22});

  final double size;

  static const blinkEvery = Duration(seconds: 4);

  @override
  State<PebbyPeek> createState() => _PebbyPeekState();
}

class _PebbyPeekState extends State<PebbyPeek>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: PebbyPeek.blinkEvery,
  )..repeat();

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Pebby',
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(painter: _PeekPainter(_blink, context.palette)),
      ),
    );
  }
}

class _PeekPainter extends CustomPainter {
  _PeekPainter(this.blink, this.palette) : super(repaint: blink);

  final Animation<double> blink;
  final AppPalette palette;

  static const _grid = 22.0;

  double get _openness {
    final t = blink.value;
    if (t < .92 || t > .98) return 1;
    return (1 - (1 - (t - .95).abs() / .03)).clamp(.1, 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid);
    const center = Offset(11, 11);
    final circle = Rect.fromCircle(center: center, radius: 10.25);
    canvas
      ..save()
      ..clipPath(Path()..addOval(circle))
      ..drawRect(circle, Paint()..color = palette.tintLavender)
      ..drawRRect(
        RRect.fromLTRBAndCorners(
          2.5,
          8,
          19.5,
          32,
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
        ),
        Paint()..color = AppColors.pebby,
      )
      ..drawRRect(
        RRect.fromLTRBR(4.5, 11, 17.5, 21, const Radius.circular(4.5)),
        Paint()..color = AppColors.lightSurface,
      );
    final eye = Paint()..color = AppColors.keycapEdge;
    for (final x in const [8.2, 13.8]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, 15),
          width: 2.8,
          height: 4 * _openness,
        ),
        eye,
      );
    }
    canvas
      ..restore()
      ..drawOval(
        circle,
        Paint()
          ..color = palette.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(_PeekPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
