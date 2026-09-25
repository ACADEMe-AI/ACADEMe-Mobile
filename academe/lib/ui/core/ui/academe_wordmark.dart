import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class AcademeWordmark extends StatelessWidget {
  const AcademeWordmark({super.key, required this.size, this.onDark = false});

  final double size;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'ACADEM',
        children: [
          TextSpan(
            text: 'e',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: size * .92,
              letterSpacing: size * .92 * -.04,
            ),
          ),
        ],
      ),
      semanticsLabel: 'ACADEMe',
      style: TextStyle(
        fontFamily: 'ArchivoWordmark',
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: size * -.02,
        height: 1,
        color: onDark ? AppColors.text : AppColors.background,
      ),
    );
  }
}
