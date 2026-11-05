import 'package:flutter/material.dart';

import '../../../domain/models/progress_summary.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap_surface.dart';

part 'progress_board_study.dart';
part 'progress_board_summary.dart';
part 'progress_board_panes.dart';

enum ProgressBoardTab { summary, progress, activity }

class ProgressBoard extends StatefulWidget {
  const ProgressBoard({
    super.key,
    required this.summary,
    required this.onAskWeakPoints,
  });

  final ProgressSummary summary;
  final VoidCallback onAskWeakPoints;

  @override
  State<ProgressBoard> createState() => _ProgressBoardState();
}

class _ProgressBoardState extends State<ProgressBoard> {
  ProgressBoardTab _tab = ProgressBoardTab.summary;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StudyWeekCard(summary: summary),
        const SizedBox(height: 10),
        _BoardTabs(
          selected: _tab,
          onSelect: (tab) => setState(() => _tab = tab),
        ),
        const SizedBox(height: 10),
        switch (_tab) {
          ProgressBoardTab.summary => _SummaryPane(summary: summary),
          ProgressBoardTab.progress => _ProgressPane(summary: summary),
          ProgressBoardTab.activity => _ActivityPane(summary: summary),
        },
        const SizedBox(height: 10),
        _GoldCta(summary: summary, onTap: widget.onAskWeakPoints),
      ],
    );
  }
}
