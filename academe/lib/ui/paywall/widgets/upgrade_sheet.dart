import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/pro_view_model.dart';
import 'paywall_parts.dart';

class UpgradeSheet extends StatefulWidget {
  const UpgradeSheet({super.key, required this.viewModel});

  final ProViewModel viewModel;

  static Future<bool?> show(BuildContext context, ProViewModel viewModel) =>
      showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        builder: (_) => UpgradeSheet(viewModel: viewModel),
      );

  @override
  State<UpgradeSheet> createState() => _UpgradeSheetState();
}

class _UpgradeSheetState extends State<UpgradeSheet> {
  ProViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.purchase.addListener(_onDone);
    _viewModel.restore.addListener(_onDone);
  }

  @override
  void dispose() {
    _viewModel.purchase.removeListener(_onDone);
    _viewModel.restore.removeListener(_onDone);
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
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => Padding(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox.square(
              dimension: 88,
              child: Pebby(pose: PebbyPose.celebrateSmall),
            ),
            Text(
              'Go Pro · 3× limits',
              textAlign: TextAlign.center,
              style: AppTextStyles.sheetTitle.copyWith(
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 12),
            const ProBenefits(),
            const SizedBox(height: 16),
            if (_viewModel.isAvailable) ...[
              for (final period in [ProPeriod.annual, ProPeriod.monthly])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlanTile(
                    offer: _viewModel.offerFor(period),
                    isSelected: _viewModel.selected == period,
                    onTap: () => _viewModel.select(period),
                  ),
                ),
              AppButton(
                label: 'Continue',
                isPrimary: true,
                isEnabled: !_viewModel.isBusy,
                onTap: _viewModel.isBusy ? null : _viewModel.purchase.execute,
              ),
              TextButton(
                onPressed: _viewModel.isBusy
                    ? null
                    : _viewModel.restore.execute,
                child: const Text('Restore purchases'),
              ),
              const PaywallSmallPrint(),
            ] else
              Text(
                'Purchases aren’t available on this device',
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            if (_viewModel.notice case final notice?)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  notice,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
