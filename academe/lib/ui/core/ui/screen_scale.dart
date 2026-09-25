import 'package:flutter/widgets.dart';

class ScreenScale {
  const ScreenScale._({
    required this.pagePadding,
    required this.headlineSize,
    required this.bodySize,
    required this.markSize,
    required this.markGap,
  });

  factory ScreenScale.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final headlineSize = (size.width * .13)
        .clamp(38.0, 64.0)
        .clamp(0.0, size.height * .062)
        .toDouble();
    return ScreenScale._(
      pagePadding: (size.width * .064).clamp(20.0, 32.0).toDouble(),
      headlineSize: headlineSize,
      bodySize: (size.width * .04).clamp(14.0, 17.0).toDouble(),
      markSize: (headlineSize * .78).clamp(30.0, 48.0).toDouble(),
      markGap: (size.height * .07).clamp(32.0, 72.0).toDouble(),
    );
  }

  final double pagePadding;
  final double headlineSize;
  final double bodySize;
  final double markSize;

  final double markGap;
}
