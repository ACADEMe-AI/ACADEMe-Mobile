import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
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
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountUnlinkGoogleTitle,
              style: AppTextStyles.display.copyWith(
                fontSize: 24,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.accountUnlinkGoogleBody(googleEmail),
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: l10n.accountKeepGoogle,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: l10n.accountUnlink,
              isPrimary: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}
