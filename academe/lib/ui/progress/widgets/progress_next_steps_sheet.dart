import 'package:flutter/material.dart';

import '../../../domain/models/progress_summary.dart';
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

  @override
  Widget build(BuildContext context) {
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
              'Next steps',
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This week',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              summary.weekLine,
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            if (grade != null) ...[
              const SizedBox(height: 12),
              Text(
                'Overall grade',
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
              'Your setup',
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
              'What to do next',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasStudy
                  ? 'Keep finishing lessons this week. Your grade updates when you complete them.'
                  : 'On Me, confirm class and board. Then open Study and finish your first lesson.',
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
