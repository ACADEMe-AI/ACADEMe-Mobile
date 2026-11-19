import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'keycap.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.isCentered = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  final bool isCentered;

  static const height = 48.0;

  @override
  Widget build(BuildContext context) {
    return Keycap(
      face: isSelected ? AppColors.selected : context.palette.surface,
      depth: AppKeycap.optionDepth,
      height: height,
      isLatched: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: isCentered ? Alignment.center : Alignment.centerLeft,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (isSelected ? AppTextStyles.labelStrong : AppTextStyles.label)
                    .copyWith(color: context.palette.text),
          ),
        ),
      ),
    );
  }
}
