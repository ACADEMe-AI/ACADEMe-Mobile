import 'package:flutter/material.dart';

import '../../../domain/models/scan.dart';
import '../../../utils/dates.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/screen_scale.dart';
import '../../study/widgets/page_scaffold.dart';
import '../view_models/scan_view_model.dart';
import 'scan_parts.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    required this.viewModel,
    required this.onStart,
    required this.onOpen,
  });

  final ScanViewModel viewModel;
  final ValueChanged<ScanMode> onStart;
  final ValueChanged<Scan> onOpen;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ScreenScale.of(context).pagePadding;
    final palette = context.palette;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        padding,
        16,
        padding,
        96 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          'Scan',
          style: AppTextStyles.display.copyWith(
            fontSize: 28,
            color: palette.text,
          ),
        ),
        Text(
          'What’s on the paper?',
          style: AppTextStyles.label.copyWith(color: palette.textMuted),
        ),
        const SizedBox(height: 16),
        for (final row in [
          [ScanMode.solve, ScanMode.check],
          [ScanMode.notes, ScanMode.ask],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (final mode in row) ...[
                  Expanded(
                    child: _ModeTile(
                      mode: mode,
                      onTap: () => widget.onStart(mode),
                    ),
                  ),
                  if (mode != row.last) const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) =>
              _Recent(scans: widget.viewModel.recent, onOpen: widget.onOpen),
        ),
      ],
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({required this.mode, required this.onTap});

  final ScanMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: mode.label,
      excludeSemantics: true,
      child: Keycap(
        face: mode.tint(palette),
        depth: 4,
        height: 120,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(mode.icon, size: 28, color: palette.text),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: palette.text,
                    ),
                  ),
                  Text(
                    mode.hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Recent extends StatelessWidget {
  const _Recent({required this.scans, required this.onOpen});

  final List<Scan> scans;
  final ValueChanged<Scan> onOpen;

  static String _subtitle(Scan scan) {
    final what = switch (scan.mode) {
      ScanMode.solve => scan.threadId == null ? 'Read' : 'Solved in ASKMe',
      ScanMode.ask => scan.threadId == null ? 'Read' : 'Asked in ASKMe',
      ScanMode.check => switch (scan.result) {
        final result? => '${result.awarded}/${result.marks} marks',
        null => 'Not marked yet',
      },
      ScanMode.notes => switch ((scan.folderId, scan.deckId)) {
        (_, _?) => 'Lesson in a folder',
        (_?, null) => 'Notes in a folder',
        _ => 'Not saved yet',
      },
    };
    final when = dueLabel(scan.createdAt.toLocal());
    return [what, if (scan.chapter.isNotEmpty) scan.chapter, when].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Recent scans'),
        for (final scan in scans)
          LinkRow(
            icon: scan.mode.icon,
            title: scan.title,
            subtitle: _subtitle(scan),
            onTap: () => onOpen(scan),
          ),
      ],
    );
  }
}
