import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/links.dart';
import '../../../domain/models/pro.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';

class ProBenefits extends StatelessWidget {
  const ProBenefits({super.key});

  static const items = [
    (Icons.all_inclusive_rounded, 'Unlimited ASKMe questions'),
    (Icons.document_scanner_rounded, 'Unlimited scans'),
    (Icons.fact_check_rounded, 'Check every answer you write'),
    (Icons.auto_stories_rounded, 'Swipe lessons made from your notes'),
    (Icons.event_note_rounded, 'Mock exams and a weekly parent report, soon'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (icon, label) in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.palette.tintLavender,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(icon, size: 20, color: context.palette.text),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      color: context.palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PlanTile extends StatelessWidget {
  const PlanTile({
    super.key,
    required this.offer,
    required this.isSelected,
    required this.onTap,
  });

  final ProOffer offer;
  final bool isSelected;
  final VoidCallback onTap;

  static const height = 96.0;

  String get _title => offer.period == ProPeriod.monthly ? 'Monthly' : 'Annual';

  String get _price => switch (offer) {
    ProOffer(period: ProPeriod.monthly, :final introPrice?, :final price) =>
      '$introPrice for the first month, then $price/month',
    ProOffer(period: ProPeriod.monthly, :final price) => '$price/month',
    ProOffer(:final price) => '$price/year',
  };

  String get _detail => switch (offer) {
    ProOffer(period: ProPeriod.annual, :final monthlyPrice?) =>
      'About $monthlyPrice/month · save 17% · renews automatically',
    ProOffer(period: ProPeriod.annual) => 'Save 17% · renews automatically',
    _ => 'Renews automatically',
  };

  @override
  Widget build(BuildContext context) {
    final ink = isSelected ? AppColors.keycapEdge : context.palette.text;
    return Semantics(
      selected: isSelected,
      label: '$_title plan',
      child: Keycap(
        face: isSelected ? AppColors.selected : context.palette.surface,
        depth: AppKeycap.optionDepth,
        height: height,
        isLatched: isSelected,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: ink,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: AppTextStyles.caption.copyWith(color: ink),
                    ),
                    Text(
                      _price,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelStrong.copyWith(color: ink),
                    ),
                    Text(
                      _detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
              if (offer.period == ProPeriod.annual) const _BestValue(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BestValue extends StatelessWidget {
  const _BestValue();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'Best value',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class PaywallSmallPrint extends StatelessWidget {
  const PaywallSmallPrint({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppTextStyles.caption.copyWith(
      color: context.palette.textMuted,
    );
    return Column(
      children: [
        Text(
          'Renews automatically. Cancel anytime in Google Play.',
          textAlign: TextAlign.center,
          style: muted,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Link(label: 'Terms', url: Links.terms),
            Text('·', style: muted),
            _Link(label: 'Privacy', url: Links.privacy),
          ],
        ),
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.label, required this.url});

  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
      style: TextButton.styleFrom(foregroundColor: context.palette.textMuted),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
