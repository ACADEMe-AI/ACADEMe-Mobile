import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';

class UnlinkGoogleSheet extends StatelessWidget {
  const UnlinkGoogleSheet({super.key, required this.googleEmail});

  final String googleEmail;

  static Future<bool?> show(
    BuildContext context, {
    required String googleEmail,
  }) => showModalBottomSheet<bool>(
    context: context,
    backgroundColor: context.palette.surface,
    showDragHandle: true,
    builder: (context) => UnlinkGoogleSheet(googleEmail: googleEmail),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Unlink Google?',
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You won’t be able to log in with $googleEmail any more. '
              'Use your email and password instead.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Keep Google',
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Unlink',
              isPrimary: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
