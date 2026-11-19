part of 'progress_board.dart';

List<String> _weekdayInitials(AppLocalizations l10n) => [
  l10n.progressWeekdayMon,
  l10n.progressWeekdayTue,
  l10n.progressWeekdayWed,
  l10n.progressWeekdayThu,
  l10n.progressWeekdayFri,
  l10n.progressWeekdaySat,
  l10n.progressWeekdaySun,
];

class _StudyWeekCard extends StatelessWidget {
  const _StudyWeekCard({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final initials = _weekdayInitials(l10n);
    final todayIndex = indiaWeekdayIndex();
    final todayActive =
        todayIndex >= 0 &&
        todayIndex < summary.activeDays.length &&
        summary.activeDays[todayIndex];
    return KeycapSurface(
      face: context.palette.tintLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.progressStudyDays,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 18,
                    color: context.palette.text,
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.palette.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: context.palette.edge,
                    width: AppKeycap.borderWidth,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  child: Text(
                    l10n.progressThisWeek,
                    style: AppTextStyles.caption.copyWith(
                      color: context.palette.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            todayActive ? l10n.progressTodayStudied : l10n.progressTodayNotYet,
            style: AppTextStyles.labelStrong.copyWith(
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final label in ['7', '3', '0'])
                      Text(
                        label,
                        style: AppTextStyles.caption.copyWith(
                          color: context.palette.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: context.palette.edge,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < 7; i++) ...[
                                if (i > 0) const SizedBox(width: 5),
                                Expanded(
                                  child: _DayBar(
                                    isActive:
                                        i < summary.activeDays.length &&
                                        summary.activeDays[i],
                                    isToday: i == todayIndex,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          for (var i = 0; i < 7; i++)
                            Expanded(
                              child: Text(
                                initials[i],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: i == todayIndex
                                      ? context.palette.text
                                      : context.palette.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.isActive, required this.isToday});

  final bool isActive;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final height = isActive ? 92.0 : 7.0;
    final color = isToday
        ? AppColors.selected
        : AppColors.primary.withValues(alpha: isActive ? 1 : 0.4);
    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(3),
            bottom: Radius.circular(1),
          ),
        ),
        child: SizedBox(width: double.infinity, height: height),
      ),
    );
  }
}

class _BoardTabs extends StatelessWidget {
  const _BoardTabs({required this.selected, required this.onSelect});

  final ProgressBoardTab selected;
  final ValueChanged<ProgressBoardTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        for (final tab in ProgressBoardTab.values) ...[
          if (tab != ProgressBoardTab.values.first) const SizedBox(width: 8),
          Expanded(
            child: _TabKey(
              label: switch (tab) {
                ProgressBoardTab.summary => l10n.progressTabSummary,
                ProgressBoardTab.progress => l10n.progressTabProgress,
                ProgressBoardTab.activity => l10n.progressTabActivity,
              },
              isOn: selected == tab,
              onTap: () => onSelect(tab),
            ),
          ),
        ],
      ],
    );
  }
}

class _TabKey extends StatelessWidget {
  const _TabKey({required this.label, required this.isOn, required this.onTap});

  final String label;
  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isOn ? AppColors.primary : context.palette.surface,
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOn ? AppColors.onPrimary : context.palette.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
