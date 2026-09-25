import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class SplitHeadline extends StatelessWidget {
  const SplitHeadline({
    super.key,
    required this.lead,
    required this.accent,
    required this.size,
  });

  final String lead;
  final String accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$lead\n'),
          TextSpan(
            text: accent,
            style: const TextStyle(color: AppColors.primary),
          ),
        ],
      ),
      style: AppTextStyles.display.copyWith(
        fontSize: size,
        height: 1,
        letterSpacing: size * -.023,
        color: context.palette.text,
      ),
    );
  }
}
