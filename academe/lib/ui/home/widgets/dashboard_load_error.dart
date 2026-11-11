import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';

class DashboardLoadError extends StatelessWidget {
  const DashboardLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.homeDashboardLoadError,
            style: AppTextStyles.label.copyWith(color: AppColors.error),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(l10n.homeRetry, style: AppTextStyles.labelStrong),
        ),
      ],
    );
  }
}
