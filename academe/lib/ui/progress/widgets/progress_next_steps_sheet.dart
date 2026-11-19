import 'package:flutter/material.dart';

import '../../../domain/models/progress_summary.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';

class ProgressNextStepsSheet extends StatelessWidget {
  const ProgressNextStepsSheet({
    super.key,
    required this.syllabusLabel,
    required this.languageName,
    required this.summary,
  });

  final String syllabusLabel;
  final String languageName;
  final ProgressSummary summary;

  String _weekLine(AppLocalizations l10n) {
    final parts = <String>[
      if (summary.daysActiveThisWeek > 0)
        l10n.progressWeekActiveDays(summary.daysActiveThisWeek),
      if (summary.lessonsFinishedThisWeek > 0)
        l10n.progressWeekLessons(summary.lessonsFinishedThisWeek),
      if (summary.chapterTestsThisWeek > 0)
        l10n.progressWeekChapterTests(summary.chapterTestsThisWeek),
      if (summary.xpThisWeek > 0) l10n.progressWeekXp(summary.xpThisWeek),
    ];
    if (parts.isEmpty) return l10n.progressWeekEmpty;
    return l10n.progressWeekSummary(parts.join(' · '));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasStudy =
        summary.lessonsFinishedThisWeek > 0 || summary.daysActiveThisWeek > 0;
    final grade = summary.overallGrade;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.progressNextSteps,
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.progressThisWeek,
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _weekLine(l10n),
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            if (grade != null) ...[
              const SizedBox(height: 12),
              Text(
                l10n.progressOverallGrade,
                style: AppTextStyles.subhead.copyWith(
                  fontSize: 15,
                  color: context.palette.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary.gradeLabel,
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.progressYourSetup,
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$syllabusLabel · $languageName',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.progressWhatNext,
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasStudy ? l10n.progressNextWithStudy : l10n.progressNextNoStudy,
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
