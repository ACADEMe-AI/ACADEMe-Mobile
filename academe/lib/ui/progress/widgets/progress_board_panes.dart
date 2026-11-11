part of 'progress_board.dart';

class _ProgressPane extends StatelessWidget {
  const _ProgressPane({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = summary.bySubject.where((row) => row.lessonsDone > 0).toList();
    if (rows.isEmpty) {
      return KeycapSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressCourseProgress,
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.progressLessonsEmpty,
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final row in rows) ...[
          KeycapSurface(
            child: Text(
              l10n.progressSubjectLessons(row.name, row.lessonsDone),
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ActivityPane extends StatelessWidget {
  const _ActivityPane({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initials = _weekdayInitials(l10n);
    final todayIndex = indiaWeekdayIndex();
    return KeycapSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressActivity,
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.daysActiveThisWeek == 0
                ? l10n.progressStudyDaysEmpty
                : l10n.progressActiveDays(summary.daysActiveThisWeek),
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        initials[i],
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.palette.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        i < summary.activeDays.length && summary.activeDays[i]
                            ? '1'
                            : '0',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 14,
                          color: i == todayIndex
                              ? AppColors.primary
                              : context.palette.text,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoldCta extends StatelessWidget {
  const _GoldCta({required this.summary, required this.onTap});

  final ProgressSummary summary;
  final VoidCallback onTap;

  (String, String) _copy(AppLocalizations l10n) {
    if (summary.lessonsFinishedThisWeek == 0 &&
        summary.daysActiveThisWeek == 0) {
      return (l10n.progressCtaStart, l10n.progressCtaNext);
    }
    if (summary.overallGrade != null) {
      return (l10n.progressCtaMomentum, l10n.progressCtaNext);
    }
    return (l10n.progressCtaHabit, l10n.progressCtaNext);
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _copy(context.l10n);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: KeycapSurface(
          face: AppColors.selected,
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.display.copyWith(
                        fontSize: 18,
                        height: 1.05,
                        color: AppColors.keycapEdge,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelStrong.copyWith(
                        fontSize: 13,
                        color: AppColors.keycapEdge,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.keycapEdge,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
