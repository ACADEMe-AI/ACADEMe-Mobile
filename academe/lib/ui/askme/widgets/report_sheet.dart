import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../core/themes/app_theme.dart';

class ReportSheet extends StatelessWidget {
  const ReportSheet({super.key});

  static Future<ReportReason?> show(BuildContext context) =>
      showModalBottomSheet<ReportReason>(
        context: context,
        backgroundColor: context.palette.surface,
        barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => const ReportSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report this answer',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 16,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'We read every report and use it to make Pebby safer.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            for (final reason in ReportReason.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  reason.label,
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.text,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: context.palette.textMuted,
                ),
                onTap: () => Navigator.of(context).pop(reason),
              ),
          ],
        ),
      ),
    );
  }
}
