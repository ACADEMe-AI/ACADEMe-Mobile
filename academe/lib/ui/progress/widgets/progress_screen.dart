import 'package:flutter/material.dart';

import '../../../domain/models/progress_summary.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap_surface.dart';
import '../../core/ui/screen_scale.dart';
import '../../me/view_models/me_view_model.dart';
import '../view_models/progress_view_model.dart';
import 'progress_board.dart';
import 'progress_hold.dart';
import 'progress_next_steps_sheet.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({
    super.key,
    required this.me,
    required this.progress,
    required this.onGoPro,
  });

  final MeViewModel me;
  final ProgressViewModel progress;
  final VoidCallback onGoPro;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    widget.me.addListener(_onMeChanged);
    widget.progress.ensureLoaded();
  }

  @override
  void dispose() {
    widget.me.removeListener(_onMeChanged);
    super.dispose();
  }

  void _onMeChanged() {
    widget.progress.ensureLoaded();
  }

  void _openNextSteps(BuildContext context) {
    final summary = widget.progress.summary ?? ProgressSummary.empty;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ProgressNextStepsSheet(
        syllabusLabel: widget.me.syllabusLabel,
        languageName: widget.me.language.nativeName,
        summary: summary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: Listenable.merge([widget.me, widget.progress]),
      builder: (context, _) {
        final progress = widget.progress;
        final me = widget.me;
        final summary = progress.summary ?? ProgressSummary.empty;
        final body = ListView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          children: [
            if (progress.load.isRunning) ...[
              KeycapSurface(
                face: context.palette.surfaceRaised,
                child: Text(
                  'Loading this week…',
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ] else if (progress.load.result case Error()) ...[
              KeycapSurface(
                face: context.palette.surfaceRaised,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Couldn’t load this week’s summary.',
                        style: AppTextStyles.label.copyWith(
                          color: context.palette.textMuted,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: progress.load.isRunning
                          ? null
                          : () => progress.ensureLoaded(force: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            ProgressBoard(
              summary: summary,
              onOpenNextSteps: () => _openNextSteps(context),
            ),
          ],
        );
        return Scaffold(
          backgroundColor: context.palette.surface,
          appBar: AppBar(
            title: const Text('My Progress'),
            backgroundColor: context.palette.surface,
            foregroundColor: context.palette.text,
          ),
          body: me.isPro
              ? body
              : Stack(
                  children: [
                    IgnorePointer(child: body),
                    ProgressHold(onGoPro: widget.onGoPro),
                  ],
                ),
        );
      },
    );
  }
}
