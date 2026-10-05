import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);
  static const _degree = math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .2;
    final ring = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    Paint pen(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas
      ..drawArc(ring, -8 * _degree, 53 * _degree, false, pen(_blue))
      ..drawArc(ring, 45 * _degree, 90 * _degree, false, pen(_green))
      ..drawArc(ring, 135 * _degree, 80 * _degree, false, pen(_yellow))
      ..drawArc(ring, 215 * _degree, 100 * _degree, false, pen(_red))
      ..drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(size.width - stroke / 2, size.height / 2),
        pen(_blue)..strokeCap = StrokeCap.butt,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
