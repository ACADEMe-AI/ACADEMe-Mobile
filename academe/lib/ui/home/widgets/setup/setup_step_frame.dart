import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/ui/app_button.dart';

class SetupStepFrame extends StatelessWidget {
  const SetupStepFrame({
    super.key,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onSubmit,
    required this.isSaving,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String buttonLabel;
  final VoidCallback onSubmit;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.display.copyWith(
            fontSize: 24,
            color: context.palette.text,
          ),
        ),
        if (subtitle case final text?) ...[
          const SizedBox(height: 4),
          Text(
            text,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(child: body),
        ),
        AppButton(
          label: isSaving ? 'Saving…' : buttonLabel,
          isPrimary: true,
          isEnabled: !isSaving,
          onTap: onSubmit,
        ),
      ],
    );
  }
}
