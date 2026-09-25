import 'package:flutter/material.dart';

import '../../../domain/models/pro.dart';
import '../../../routing/routes.dart';
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

  (String, String) _words(int limit) => switch (widget.feature) {
    ProFeature.askme => (
      'That’s today’s free questions',
      'Free includes $limit ASKMe questions a day. They come back at '
          'midnight. With Pro, ask as much as you like.',
    ),
    ProFeature.scan => (
      'That’s today’s free scans',
      'Free includes $limit scans a day. They come back at midnight. '
          'With Pro, scan as much as you like.',
    ),
    ProFeature.check => (
      limit == 1 ? 'That’s today’s free check' : 'That’s today’s free checks',
      'Free includes ${limit == 1 ? 'one answer check' : '$limit answer checks'} '
          'a day. It comes back at midnight. With Pro, check every answer.',
    ),
    ProFeature.lessons => (
      'Lessons from notes are Pro',
      'Keeping your notes is free. With Pro, Pebby turns them into swipe '
          'lessons with quizzes.',
    ),
  };

  void _goPro() {
    final navigator = Navigator.of(context);
    navigator
      ..pop()
      ..pushNamed(Routes.paywall);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final limit =
            widget.viewModel.plan.limitOf(widget.feature) ??
            LimitSheet._fallbackLimits[widget.feature] ??
            0;
        final (title, text) = _words(limit);
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
                AppButton(label: 'Go Pro', isPrimary: true, onTap: _goPro),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: context.palette.textMuted,
                  ),
                  child: const Text(
                    'Maybe later',
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
