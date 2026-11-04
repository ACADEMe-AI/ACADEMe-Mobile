import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/pro.dart';
import '../../../utils/dates.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/face_card.dart';
import '../view_models/pro_view_model.dart';
import 'upgrade_sheet.dart';

class ProManageScreen extends StatefulWidget {
  const ProManageScreen({super.key, required this.viewModel});

  final ProViewModel viewModel;

  @override
  State<ProManageScreen> createState() => _ProManageScreenState();
}

class _ProManageScreenState extends State<ProManageScreen> {
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
    widget.viewModel.load.addListener(_onLoad);
  }

  @override
  void dispose() {
    widget.viewModel.load.removeListener(_onLoad);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onLoad() {
    if (widget.viewModel.load.result case Ok()) {
      _lastRefresh = DateTime.now();
    }
  }

  Future<void> _refresh() async {
    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!) < const Duration(seconds: 3)) {
      return;
    }
    await widget.viewModel.load.execute();
  }

  Future<void> _goPro() async {
    final bought = await UpgradeSheet.show(context, widget.viewModel);
    if (bought == true && mounted) {
      await widget.viewModel.load.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final plan = viewModel.plan;
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            title: const Text('Plan & limits'),
            backgroundColor: context.palette.surface,
            foregroundColor: context.palette.text,
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                FaceCard(
                  tint: viewModel.isPro
                      ? context.palette.tintLavender
                      : context.palette.surfaceRaised,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.isPro ? 'Pro' : 'free',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 22,
                          color: context.palette.text,
                        ),
                      ),
                      if (_billingLine(plan, viewModel.isPro)
                          case final line?) ...[
                        const SizedBox(height: 6),
                        Text(
                          line,
                          style: AppTextStyles.label.copyWith(
                            color: context.palette.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final entry in _limitRows(plan, viewModel.isPro))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LimitMeter(
                      title: entry.$1,
                      used: entry.$2,
                      limit: entry.$3,
                      tint: entry.$4,
                    ),
                  ),
                if (plan.weekLimit > 0) ...[
                  _LimitMeter(
                    title: 'Weekly combined',
                    used: plan.usedWeek,
                    limit: plan.weekLimit,
                    tint: context.palette.tintSky,
                    resetLabel: plan.weekResetsAt == null
                        ? null
                        : 'Resets ${shortDay(plan.weekResetsAt!.toLocal())}',
                  ),
                  const SizedBox(height: 16),
                ],
                if (!viewModel.isPro)
                  AppButton(
                    label: 'Go Pro · 3× limits',
                    isPrimary: true,
                    onTap: _goPro,
                  )
                else ...[
                  AppButton(
                    label: 'Manage in Google Play',
                    onTap: () => launchUrl(
                      Uri.parse(viewModel.manageUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  if (viewModel.notice case final notice?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        notice,
                        style: AppTextStyles.caption.copyWith(
                          color: context.palette.textMuted,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String? _billingLine(ProPlan plan, bool isPro) {
    if (!isPro) return 'Daily limits reset at midnight IST';
    final expires = plan.expiresAt?.toLocal();
    final day = expires == null ? null : '${shortDay(expires)} ${expires.year}';
    return switch (plan.state) {
      'billing_issue' => 'Fix payment in Google Play to keep Pro',
      _ when day == null => '3× daily limits · weekly safety cap',
      _ when plan.autoRenew => 'Monthly · Renews $day · 3× limits',
      _ => 'Pro ends on $day',
    };
  }

  List<(String, int, int, Color)> _limitRows(ProPlan plan, bool isPro) {
    Color tintFor(ProFeature feature) => switch (feature) {
      ProFeature.askme => context.palette.tintLavender,
      ProFeature.scan => context.palette.tintMint,
      ProFeature.check => context.palette.tintRose,
      ProFeature.lessons => context.palette.tintSky,
    };
    const labels = {
      ProFeature.askme: 'ASKMe',
      ProFeature.scan: 'Scan',
      ProFeature.check: 'Check my answer',
      ProFeature.lessons: 'Lessons from notes',
    };
    final rows = <(String, int, int, Color)>[];
    for (final feature in ProFeature.values) {
      final limit = plan.limitOf(feature);
      if (limit == null || limit < 0) continue;
      if (limit == 0 && !isPro) continue;
      final used = plan.usedToday[feature] ?? 0;
      rows.add((
        labels[feature]!,
        used,
        limit == 0 ? 1 : limit,
        tintFor(feature),
      ));
    }
    return rows;
  }
}

class _LimitMeter extends StatelessWidget {
  const _LimitMeter({
    required this.title,
    required this.used,
    required this.limit,
    required this.tint,
    this.resetLabel,
  });

  final String title;
  final int used;
  final int limit;
  final Color tint;
  final String? resetLabel;

  @override
  Widget build(BuildContext context) {
    final safeLimit = limit < 1 ? 1 : limit;
    final fill = (used / safeLimit).clamp(0.0, 1.0);
    return FaceCard(
      tint: tint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelStrong.copyWith(
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: context.palette.border),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fill == 0 ? 0.001 : fill,
                    child: const ColoredBox(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(fill * 100).round()}% used today',
            style: AppTextStyles.caption.copyWith(
              color: context.palette.textMuted,
            ),
          ),
          if (resetLabel case final label?)
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
