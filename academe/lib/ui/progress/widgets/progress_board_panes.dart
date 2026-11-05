part of 'progress_board.dart';

class _ProgressPane extends StatelessWidget {
  const _ProgressPane({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final rows = summary.bySubject.where((row) => row.lessonsDone > 0).toList();
    if (rows.isEmpty) {
      return KeycapSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course progress',
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lessons you finish will show up here.',
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
              '${row.name}: ${row.lessonsDone} lesson${row.lessonsDone == 1 ? '' : 's'}',
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
    final todayIndex = indiaWeekdayIndex();
    return KeycapSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            summary.daysActiveThisWeek == 0
                ? 'Your study days will show up here.'
                : '${summary.daysActiveThisWeek} active day${summary.daysActiveThisWeek == 1 ? '' : 's'} this week.',
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
                        weekDayInitials[i],
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

  (String, String) get _copy {
    if (summary.lessonsFinishedThisWeek == 0 && summary.daysActiveThisWeek == 0) {
      return (
        'It’s time to start your journey!',
        'Learn about your weak points',
      );
    }
    if (summary.overallGrade != null) {
      return (
        'Keep your momentum going',
        'See where to focus next',
      );
    }
    return (
      'You’re building a habit',
      'Learn about your weak points',
    );
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _copy;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.selected,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.edge,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
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
      ),
    );
  }
}
