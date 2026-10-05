import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class PebbyIcon extends StatelessWidget {
  const PebbyIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final side = size ?? theme.size ?? 24;
    return SizedBox.square(
      dimension: side,
      child: CustomPaint(
        painter: _PebbyIconPainter(
          color ?? theme.color ?? context.palette.text,
        ),
      ),
    );
  }
}

class _PebbyIconPainter extends CustomPainter {
  const _PebbyIconPainter(this.color);

  final Color color;

  static const _grid = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _grid, size.height / _grid);
    final paint = Paint()..color = color;

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(12, 4.8), width: 3.4, height: 6),
      paint,
    );
    _drawTiltedOval(canvas, paint, const Offset(9.3, 6.2), -28);
    _drawTiltedOval(canvas, paint, const Offset(14.7, 6.2), 28);
    for (final x in const [4.0, 20.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 14.6), width: 2.8, height: 4.8),
        paint,
      );
    }
    for (final x in const [7.4, 12.8]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 18, 3.8, 3.4),
          const Radius.circular(1.4),
        ),
        paint,
      );
    }

    final body = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromLTRBR(4.8, 6.8, 19.2, 19.8, const Radius.circular(5.1)),
      )
      ..addRRect(
        RRect.fromLTRBR(7.2, 9.4, 16.8, 16.2, const Radius.circular(2.6)),
      );
    canvas.drawPath(body, paint);

    for (final x in const [10.4, 13.6]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 12.8), width: 1.9, height: 2.6),
        paint,
      );
    }
  }

  void _drawTiltedOval(
    Canvas canvas,
    Paint paint,
    Offset center,
    double degrees,
  ) {
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(degrees * math.pi / 180)
      ..drawOval(
        Rect.fromCenter(center: Offset.zero, width: 2.4, height: 3.6),
        paint,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_PebbyIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
