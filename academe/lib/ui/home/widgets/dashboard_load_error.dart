import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class DashboardLoadError extends StatelessWidget {
  const DashboardLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Couldn’t load your dashboard.',
            style: AppTextStyles.label.copyWith(color: AppColors.error),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Retry', style: AppTextStyles.labelStrong),
        ),
      ],
    );
  }
}
