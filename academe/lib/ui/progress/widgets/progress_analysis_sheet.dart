import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class ProgressAnalysisSheet extends StatelessWidget {
  const ProgressAnalysisSheet({
    super.key,
    required this.syllabusLabel,
    required this.languageName,
    required this.gradeLabel,
    required this.hasGrade,
    required this.lessonsFinished,
  });

  final String syllabusLabel;
  final String languageName;
  final String gradeLabel;
  final bool hasGrade;
  final int lessonsFinished;

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
              'Your progress analysis',
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Where you’re doing well',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasGrade
                  ? 'Overall grade $gradeLabel. Your language is $languageName.'
                  : 'Nothing is on your record yet. Your language is $languageName.',
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Where to focus',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 15,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$syllabusLabel. Chapters stay unmatched until you pick them.',
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
              lessonsFinished == 0
                  ? 'On Me, set your class and board. Then start the first lesson.'
                  : 'Keep finishing lessons this week to raise your grade.',
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
