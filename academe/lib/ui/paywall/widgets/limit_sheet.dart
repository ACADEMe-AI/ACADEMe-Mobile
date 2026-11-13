import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../routing/routes.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';
import '../view_models/pro_view_model.dart';

class LimitSheet extends StatefulWidget {
  const LimitSheet({super.key, required this.viewModel, required this.feature});

  final ProViewModel viewModel;
  final ProFeature feature;

  static Future<void> show(BuildContext context, ProFeature feature) =>
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamed(Routes.proLimit, arguments: feature);

  static const _fallbackLimits = {
    ProFeature.askme: 10,
    ProFeature.scan: 3,
    ProFeature.check: 1,
  };

  @override
  State<LimitSheet> createState() => _LimitSheetState();
}

class _LimitSheetState extends State<LimitSheet> {
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

  (String, String) _words(AppLocalizations l10n, int limit) =>
      switch (widget.feature) {
        ProFeature.askme => (l10n.limitAskmeTitle, l10n.limitAskmeBody(limit)),
        ProFeature.scan => (l10n.limitScanTitle, l10n.limitScanBody(limit)),
        ProFeature.check => (
          l10n.limitCheckTitle(limit),
          l10n.limitCheckBody(limit),
        ),
        ProFeature.lessons => (l10n.limitLessonsTitle, l10n.limitLessonsBody),
      };

  void _goPro() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(Routes.proUpgrade);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final l10n = context.l10n;
        final limit =
            widget.viewModel.plan.limitOf(widget.feature) ??
            LimitSheet._fallbackLimits[widget.feature] ??
            0;
        final (title, text) = _words(l10n, limit);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox.square(
                  dimension: 96,
                  child: Pebby(pose: PebbyPose.encourage),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sheetTitle.copyWith(
                    color: context.palette.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(label: l10n.actionGoPro, isPrimary: true, onTap: _goPro),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: context.palette.textMuted,
                  ),
                  child: Text(
                    l10n.limitMaybeLater,
                    style: AppTextStyles.labelStrong,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OpensLimitSheet extends StatefulWidget {
  const OpensLimitSheet({
    super.key,
    required this.feature,
    required this.child,
  });

  final ProFeature feature;
  final Widget child;

  @override
  State<OpensLimitSheet> createState() => _OpensLimitSheetState();
}

class _OpensLimitSheetState extends State<OpensLimitSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) LimitSheet.show(context, widget.feature);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
