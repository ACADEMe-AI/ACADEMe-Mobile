import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/sign_up_view_model.dart';

class PasswordLengthCheck extends StatelessWidget {
  const PasswordLengthCheck({super.key, required this.isMet});

  final bool isMet;

  @override
  Widget build(BuildContext context) {
    final color = isMet ? context.palette.success : context.palette.textMuted;
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          context.l10n.authPasswordMinLength(SignUpViewModel.minPasswordLength),
          style: AppTextStyles.label.copyWith(color: color),
        ),
      ],
    );
  }
}
