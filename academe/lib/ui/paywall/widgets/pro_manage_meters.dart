part of 'pro_manage_screen.dart';

class _DailyLimitsCard extends StatelessWidget {
  const _DailyLimitsCard({required this.plan, required this.isPro});

  final ProPlan plan;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final meters = _dailyMeters(plan, isPro);
    if (meters.isEmpty) return const SizedBox.shrink();
    final resetChip = plan.resetsAt == null
        ? null
        : resetsIn(plan.resetsAt!.toLocal());
    return KeycapSurface(
      padding: const EdgeInsets.all(14),
      shadowDepth: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHead(
            label: 'Daily limits',
            when: 'Resets every day at 12:00 AM IST',
            chip: resetChip,
            chipCool: false,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < meters.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _MeterRow(
              name: meters[i].$1,
              used: meters[i].$2,
              limit: meters[i].$3,
              isWeek: false,
            ),
          ],
        ],
      ),
    );
  }

  List<(String, int, int)> _dailyMeters(ProPlan plan, bool isPro) {
    const labels = {
      ProFeature.askme: 'ASKMe',
      ProFeature.scan: 'Scan',
      ProFeature.check: 'Check',
      ProFeature.lessons: 'Lessons',
    };
    final rows = <(String, int, int)>[];
    for (final feature in [
      ProFeature.askme,
      ProFeature.scan,
      ProFeature.check,
    ]) {
      final limit = plan.limitOf(feature);
      if (limit == null || limit < 0) continue;
      if (limit == 0 && !isPro) continue;
      final used = plan.usedToday[feature] ?? 0;
      rows.add((labels[feature]!, used, limit == 0 ? 1 : limit));
    }
    return rows;
  }
}

class _WeeklyLimitCard extends StatelessWidget {
  const _WeeklyLimitCard({required this.plan});

  final ProPlan plan;

  @override
  Widget build(BuildContext context) {
    final when = plan.weekResetsAt == null
        ? 'Resets Mondays · 12:00 AM IST'
        : 'Resets ${shortDay(plan.weekResetsAt!.toLocal())} · 12:00 AM IST';
    final chip = plan.weekResetsAt == null
        ? null
        : resetsIn(plan.weekResetsAt!.toLocal());
    return KeycapSurface(
      padding: const EdgeInsets.all(14),
      shadowDepth: 4,
      face: context.palette.tintSky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardHead(
            label: 'Weekly limit',
            when: when,
            chip: chip,
            chipCool: true,
          ),
          const SizedBox(height: 14),
          _MeterRow(
            name: 'All features',
            used: plan.usedWeek,
            limit: plan.weekLimit,
            isWeek: true,
          ),
        ],
      ),
    );
  }
}

class _CardHead extends StatelessWidget {
  const _CardHead({
    required this.label,
    required this.when,
    required this.chip,
    required this.chipCool,
  });

  final String label;
  final String when;
  final String? chip;
  final bool chipCool;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: context.palette.textMuted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                when,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.palette.text,
                ),
              ),
            ],
          ),
        ),
        if (chip case final label?)
          DecoratedBox(
            decoration: BoxDecoration(
              color: chipCool
                  ? context.palette.tintMint
                  : context.palette.tintAmber,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: context.palette.edge,
                width: AppKeycap.borderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.palette.text,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MeterRow extends StatelessWidget {
  const _MeterRow({
    required this.name,
    required this.used,
    required this.limit,
    required this.isWeek,
  });

  final String name;
  final int used;
  final int limit;
  final bool isWeek;

  @override
  Widget build(BuildContext context) {
    final safeLimit = limit < 1 ? 1 : limit;
    final fill = (used / safeLimit).clamp(0.0, 1.0);
    final pct = (fill * 100).round();
    final color = isWeek
        ? AppColors.primary
        : pct >= 100
        ? AppColors.error
        : pct >= 70
        ? AppColors.selected
        : context.palette.success;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.labelStrong.copyWith(
                  color: context.palette.text,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: AppTextStyles.display.copyWith(
                fontSize: 16,
                color: context.palette.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.palette.surfaceRaised,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fill == 0 ? 0.001 : fill,
                  child: ColoredBox(color: color),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
