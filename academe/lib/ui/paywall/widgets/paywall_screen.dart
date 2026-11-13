import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../utils/result.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/top_notice.dart';
import '../view_models/pro_view_model.dart';
import 'paywall_parts.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key, required this.viewModel});

  final ProViewModel viewModel;

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  ProViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.purchase.addListener(_onDone);
    _viewModel.restore.addListener(_onDone);
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.purchase.removeListener(_onDone);
    _viewModel.restore.removeListener(_onDone);
    _viewModel.dispose();
    super.dispose();
  }

  void _onDone() {
    final done = switch ((
      _viewModel.purchase.result,
      _viewModel.restore.result,
    )) {
      (Ok(value: PurchaseOutcome.purchased), _) || (_, Ok(value: true)) => true,
      _ => false,
    };
    if (!done || !mounted) return;
    context.showTopNotice(
      context.l10n.paywallWelcomeSnack,
      pose: PebbyPose.noticeWelcome,
    );
    Navigator.of(context).maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return AnnotatedRegion(
      value: context.palette.systemBars,
      child: Scaffold(
        backgroundColor: context.palette.surface,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: padding - 12, top: 4),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: context.l10n.actionClose,
                          icon: const Icon(Icons.close_rounded),
                          color: context.palette.text,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
                        children: [
                          const _Hero(),
                          const SizedBox(height: 16),
                          const ProBenefits(),
                          const SizedBox(height: 20),
                          if (_viewModel.isAvailable)
                            _Plans(viewModel: _viewModel)
                          else
                            const _Unavailable(),
                        ],
                      ),
                    ),
                    if (_viewModel.isAvailable)
                      Padding(
                        padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
                        child: _Actions(viewModel: _viewModel),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  static const _pebbySize = 112.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox.square(
          dimension: _pebbySize,
          child: Pebby(pose: PebbyPose.celebrateSmall),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.proTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 32,
            color: context.palette.text,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.paywallTagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(color: context.palette.textMuted),
        ),
      ],
    );
  }
}

class _Plans extends StatelessWidget {
  const _Plans({required this.viewModel});

  final ProViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final period in [ProPeriod.annual, ProPeriod.monthly]) ...[
          PlanTile(
            offer: viewModel.offerFor(period),
            isSelected: viewModel.selected == period,
            onTap: () => viewModel.select(period),
          ),
          const SizedBox(height: 12),
        ],
        if (viewModel.notice(context.l10n) case final text?)
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(
              color: context.palette.errorInk,
            ),
          ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.viewModel});

  final ProViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: viewModel.purchase.isRunning
              ? l10n.paywallOpeningPlay
              : l10n.authContinue,
          isPrimary: true,
          isEnabled: !viewModel.isBusy,
          onTap: viewModel.purchase.execute,
        ),
        TextButton(
          onPressed: viewModel.isBusy ? null : viewModel.restore.execute,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(
            viewModel.restore.isRunning
                ? l10n.paywallRestoring
                : l10n.paywallRestore,
            style: AppTextStyles.labelStrong,
          ),
        ),
        const PaywallSmallPrint(),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.tintCream,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.storefront_rounded, color: context.palette.text),
            const SizedBox(height: 8),
            Text(
              l10n.paywallUnavailableTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.paywallUnavailableBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
