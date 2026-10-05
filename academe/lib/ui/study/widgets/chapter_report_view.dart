import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/celebration.dart';
import '../view_models/deck_view_model.dart';

class ChapterReportView extends StatelessWidget {
  const ChapterReportView({
    super.key,
    required this.title,
    required this.correct,
    required this.total,
    required this.xp,
    required this.scores,
    required this.onRevise,
    required this.onAddToFolder,
    required this.onClose,
  });

  final String title;
  final int correct;
  final int total;
  final int xp;
  final List<LessonScore> scores;
  final VoidCallback? onRevise;
  final VoidCallback? onAddToFolder;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ratio = total == 0 ? 0.0 : correct / total;
    final onRevise = this.onRevise;
    final onAddToFolder = this.onAddToFolder;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onClose,
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            color: palette.text,
          ),
        ),
        Row(
          children: [
            SizedBox.square(
              dimension: 96,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  if (ratio >= .8)
                    const OverflowBox(
                      maxWidth: 200,
                      maxHeight: 200,
                      child: Burst(size: 180, dots: 14),
                    ),
                  OneShot(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => CircularProgressIndicator(
                      value: ratio * t,
                      strokeWidth: 10,
                      color: ratio >= .8
                          ? palette.success
                          : ratio >= .5
                          ? AppColors.selected
                          : palette.errorInk,
                      backgroundColor: palette.surfaceRaised,
                    ),
                  ),
                  Center(
                    child: Text(
                      '$correct/$total',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 22,
                        color: palette.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ratio >= .8
                        ? 'Great work'
                        : ratio >= .5
                        ? 'Good going'
                        : 'Worth another go',
                    style: AppTextStyles.display.copyWith(
                      fontSize: 24,
                      color: palette.text,
                    ),
                  ),
                  Text(
                    '$title · +$xp XP',
                    style: AppTextStyles.label.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'By lesson',
          style: AppTextStyles.subhead.copyWith(
            fontSize: 15,
            color: palette.text,
          ),
        ),
        for (final s in scores)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.title,
                        style: AppTextStyles.labelStrong.copyWith(
                          color: palette.text,
                        ),
                      ),
                    ),
                    Text(
                      '${s.correct}/${s.total}',
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: s.total == 0 ? 0 : s.correct / s.total,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  color: s.correct == s.total
                      ? palette.success
                      : AppColors.selected,
                  backgroundColor: palette.surfaceRaised,
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        if (onRevise != null && correct < total) ...[
          AppButton(
            label: 'Revise what you missed',
            isPrimary: true,
            onTap: onRevise,
          ),
          const SizedBox(height: 12),
        ],
        if (onAddToFolder != null) ...[
          AppButton(
            label: 'Add chapter to a folder',
            icon: Icon(Icons.create_new_folder_outlined, color: palette.text),
            onTap: onAddToFolder,
          ),
          const SizedBox(height: 12),
        ],
        AppButton(
          label: 'Back to chapter',
          isPrimary: onRevise == null || correct == total,
          onTap: onClose,
        ),
      ],
    );
  }
}
