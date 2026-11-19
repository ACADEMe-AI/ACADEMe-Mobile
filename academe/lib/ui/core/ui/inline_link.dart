import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class InlineLink extends StatelessWidget {
  const InlineLink({
    super.key,
    required this.lead,
    required this.action,
    this.onTap,
  });

  final String lead;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          lead,
          style: AppTextStyles.label.copyWith(color: context.palette.textMuted),
        ),
        Semantics(
          button: true,
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                action,
                style: AppTextStyles.labelStrong.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
