import 'package:flutter/material.dart';

import '../../../utils/plural.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/study_view_model.dart';

class ChapterRow extends StatelessWidget {
  const ChapterRow({super.key, required this.chapter, required this.onTap});

  final StudyChapter chapter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final result = chapter.result;
    final soon = chapter.isComingSoon;
    final coming = chapter.lessonsComing > 0 && !soon
        ? ' · ${chapter.lessonsComing} coming soon'
        : '';
    final subtitle = soon
        ? chapter.lessonsPlanned == 0
              ? 'Coming soon'
              : 'Coming soon · ${pluralize(chapter.lessonsPlanned, 'lesson')}'
        : chapter.isDone
        ? result == null
              ? 'Lessons done · test next$coming'
              : 'Done · test ${result.percent}%$coming'
        : '${chapter.lessonsDone} of ${pluralize(chapter.lessons.length, 'lesson')}$coming';
    final ink = soon ? palette.textMuted : palette.text;
    final exam = chapter.isFormativeOnly ? ' · Not in board exam' : '';
    return Semantics(
      button: !soon,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.number}',
                      style: AppTextStyles.display.copyWith(
                        fontSize: 17,
                        color: ink,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(color: ink),
                    ),
                    Text(
                      '$subtitle$exam',
                      style: AppTextStyles.caption.copyWith(
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (soon)
                Icon(Icons.schedule_rounded, color: palette.textMuted)
              else
                SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(
                    value: chapter.progress,
                    strokeWidth: 4,
                    color: palette.success,
                    backgroundColor: palette.surfaceRaised,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
