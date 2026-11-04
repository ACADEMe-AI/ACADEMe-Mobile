import 'package:flutter/material.dart';

import '../../../domain/models/auth_failure.dart';
import '../../core/themes/app_theme.dart';
import 'auth_failure_text.dart';

class FailureLine extends StatelessWidget {
  const FailureLine({super.key, required this.failure});

  final AuthFailure? failure;

  @override
  Widget build(BuildContext context) {
    final message = failure?.message;
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        message,
        style: AppTextStyles.label.copyWith(color: AppColors.error),
      ),
    );
  }
}
