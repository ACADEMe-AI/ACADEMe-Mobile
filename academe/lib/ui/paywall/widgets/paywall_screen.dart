import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/screen_scale.dart';
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Welcome to ACADEMe Pro')));
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
                          tooltip: 'Close',
                          icon: const Icon(Icons.close_rounded),
                          color: context.palette.text,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(horizontal: padding),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox.square(
          dimension: 112,
          child: Pebby(pose: PebbyPose.celebrateSmall),
        ),
        const SizedBox(height: 8),
        Text(
          'ACADEMe Pro',
          textAlign: TextAlign.center,
          style: AppTextStyles.display.copyWith(
            fontSize: 32,
            color: context.palette.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ask, scan and check as much as you like.',
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
        for (final period in ProPeriod.values) ...[
          PlanTile(
            offer: viewModel.offerFor(period),
            isSelected: viewModel.selected == period,
            onTap: () => viewModel.select(period),
          ),
          const SizedBox(height: 12),
        ],
        if (viewModel.notice case final text?)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: viewModel.purchase.isRunning
              ? 'Opening Google Play…'
              : 'Continue',
          isPrimary: true,
          isEnabled: !viewModel.isBusy,
          onTap: viewModel.purchase.execute,
        ),
        TextButton(
          onPressed: viewModel.isBusy ? null : viewModel.restore.execute,
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: Text(
            viewModel.restore.isRunning ? 'Restoring…' : 'Restore purchases',
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
              'Purchases aren’t available on this device',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelStrong.copyWith(
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Install ACADEMe from Google Play and sign in to Play to go Pro.',
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
