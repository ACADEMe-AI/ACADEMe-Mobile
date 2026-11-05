part of 'pro_manage_screen.dart';

class _PlanHero extends StatelessWidget {
  const _PlanHero({required this.isPro, required this.plan});

  final bool isPro;
  final ProPlan plan;

  @override
  Widget build(BuildContext context) {
    return KeycapSurface(
      padding: const EdgeInsets.all(14),
      shadowDepth: 4,
      face: isPro ? context.palette.tintLavender : context.palette.tintCream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusPill(isPro: isPro),
          const SizedBox(height: 8),
          Text(
            isPro ? 'You’re on Pro' : 'You’re on Free',
            style: AppTextStyles.display.copyWith(
              fontSize: 24,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _metaLine(plan, isPro),
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: context.palette.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _metaLine(ProPlan plan, bool isPro) {
    if (!isPro) return 'Daily & weekly limits · 12:00 AM IST';
    final expires = plan.expiresAt?.toLocal();
    final day = expires == null ? null : longDate(expires);
    return switch (plan.state) {
      'billing_issue' => 'Fix payment in Google Play to keep Pro',
      _ when day == null => '3× daily limits · weekly safety cap',
      _ when plan.autoRenew => switch (plan.period) {
        ProPeriod.annual => 'Annual · Renews $day · 3× limits',
        _ => 'Monthly · Renews $day · 3× limits',
      },
      _ => 'Pro ends on $day',
    };
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.isPro});

  final bool isPro;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: context.palette.edge,
          width: AppKeycap.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isPro
                    ? context.palette.success
                    : context.palette.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPro ? context.palette.success : context.palette.edge,
                  width: 1.5,
                ),
              ),
              child: const SizedBox.square(dimension: 8),
            ),
            const SizedBox(width: 7),
            Text(
              isPro ? 'Active' : 'Free',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.palette.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
