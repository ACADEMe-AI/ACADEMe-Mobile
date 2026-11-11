import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../l10n/app_l10n.dart';
import '../themes/app_theme.dart';

class ReportSheet extends StatelessWidget {
  const ReportSheet({super.key, required this.title});

  final String title;

  static Future<ReportReason?> show(BuildContext context, String title) =>
      showModalBottomSheet<ReportReason>(
        context: context,
        backgroundColor: context.palette.surface,
        barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => ReportSheet(title: title),
      );

  String _reasonLabel(AppLocalizations l10n, ReportReason reason) =>
      switch (reason) {
        ReportReason.wrong => l10n.reportReasonWrong,
        ReportReason.harmful => l10n.reportReasonHarmful,
        ReportReason.offensive => l10n.reportReasonOffensive,
        ReportReason.other => l10n.reportReasonOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.subhead.copyWith(
                fontSize: 16,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.reportBody,
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            for (final reason in ReportReason.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _reasonLabel(l10n, reason),
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
