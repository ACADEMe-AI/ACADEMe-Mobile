import 'package:flutter/material.dart';

import '../../../domain/models/progress_summary.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap_surface.dart';
import '../../core/ui/screen_scale.dart';
import '../../me/view_models/me_view_model.dart';
import '../view_models/progress_view_model.dart';
import 'progress_analysis_sheet.dart';
import 'progress_board.dart';
import 'progress_hold.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.me,
    required this.progress,
    required this.onGoPro,
  });

  final MeViewModel me;
  final ProgressViewModel progress;
  final VoidCallback onGoPro;

  void _openAnalysis(BuildContext context) {
    final summary = progress.summary;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.palette.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => ProgressAnalysisSheet(
        syllabusLabel: me.syllabusLabel,
        languageName: me.language.nativeName,
        gradeLabel: summary?.gradeLabel ?? '0.00',
        hasGrade: summary?.overallGrade != null,
        lessonsFinished: summary?.lessonsFinishedThisWeek ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    return ListenableBuilder(
      listenable: Listenable.merge([me, progress]),
      builder: (context, _) {
        final summary =
            progress.summary ??
            const ProgressSummary(
              weekStartsOn: '',
              daysActiveThisWeek: 0,
              lessonsFinishedThisWeek: 0,
              chapterTestsThisWeek: 0,
              xpThisWeek: 0,
              bySubject: [],
            );
        final body = ListView(
          padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
          children: [
            if (progress.load.isRunning)
              KeycapSurface(
                face: context.palette.surfaceRaised,
                child: Text(
                  'Loading this week…',
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.textMuted,
                  ),
                ),
              )
            else if (progress.load.result case Error())
              TextButton(
                onPressed: progress.load.isRunning
                    ? null
                    : progress.load.execute,
                child: const Text('Couldn’t load this week’s summary. Retry'),
              )
            else
              ProgressBoard(
                summary: summary,
                onAskWeakPoints: () => _openAnalysis(context),
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
                    ProgressHold(onGoPro: onGoPro),
                  ],
                ),
        );
      },
    );
  }
}
