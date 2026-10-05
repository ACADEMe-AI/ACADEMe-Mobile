import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'keycap.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.isPrimary = false,
    this.isEnabled = true,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isEnabled;

  static const height = 54.0;

  @override
  Widget build(BuildContext context) {
    var face = isPrimary ? AppColors.primary : context.palette.surface;
    var ink = isPrimary ? AppColors.onPrimary : context.palette.text;
    if (!isEnabled) {
      face = Keycap.faded(face, on: context.palette.surface);
      ink = Keycap.faded(ink, on: context.palette.surface);
    }
    return Keycap(
      face: face,
      depth: AppKeycap.buttonDepth,
      height: height,
      isEnabled: isEnabled,
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (icon != null) Positioned(left: 18, child: icon!),
          Text(label, style: AppTextStyles.button.copyWith(color: ink)),
        ],
      ),
    );
  }
}
