import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/pro.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../me/widgets/settings_list.dart';
import '../../me/widgets/settings_page.dart';
import '../view_models/pro_view_model.dart';

class ProManageScreen extends StatefulWidget {
  const ProManageScreen({super.key, required this.viewModel});

  final ProViewModel viewModel;

  @override
  State<ProManageScreen> createState() => _ProManageScreenState();
}

class _ProManageScreenState extends State<ProManageScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => SettingsPage(
        title: 'ACADEMe Pro',
        children: [
          const SizedBox(height: 8),
          _PlanCard(plan: viewModel.plan, isPro: viewModel.isPro),
          SettingsGroup(
            title: 'Subscription',
            children: [
              SettingsRow(
                label: 'Manage in Google Play',
                trailing: Icon(
                  Icons.open_in_new_rounded,
                  size: 20,
                  color: context.palette.textMuted,
                ),
                onTap: () => launchUrl(
                  Uri.parse(viewModel.manageUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              SettingsRow(
                label: 'Restore purchases',
                value: viewModel.restore.isRunning ? 'Restoring…' : null,
                onTap: viewModel.isBusy ? null : viewModel.restore.execute,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.isPro});

  final ProPlan plan;
  final bool isPro;

  String get _period => switch (plan.period) {
    ProPeriod.monthly => 'Monthly plan',
    ProPeriod.annual => 'Annual plan',
    null => isPro ? 'Pro' : 'Free',
  };

  String? get _status {
    final expires = plan.expiresAt?.toLocal();
    final day = expires == null ? null : '${shortDay(expires)} ${expires.year}';
    return switch (plan.state) {
      'billing_issue' =>
        'There’s a problem with your payment. Fix it in Google Play to keep '
            'Pro.',
      _ when day == null => null,
      _ when plan.autoRenew => 'Renews on $day',
      _ => 'Pro ends on $day',
    };
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.tintLavender,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.palette.edge,
          width: AppKeycap.borderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPro ? 'You’re on Pro' : 'You’re on Free',
              style: AppTextStyles.display.copyWith(
                fontSize: 22,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _period,
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
            if (_status case final text?) ...[
              const SizedBox(height: 4),
              Text(
                text,
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
