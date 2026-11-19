import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';

class SetupRewardPill extends StatelessWidget {
  const SetupRewardPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: context.palette.edge, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.keycapEdge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
