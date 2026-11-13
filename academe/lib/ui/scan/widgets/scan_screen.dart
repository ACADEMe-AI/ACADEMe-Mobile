import 'package:flutter/material.dart';

import '../../../domain/models/scan.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/l10n/relative_day.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/tab_bar_layout.dart';
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
    final l10n = context.l10n;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        padding,
        16,
        padding,
        TabBarLayout.scrollBottomPadding(context) + 16,
      ),
      children: [
        Text(
          l10n.navScan,
          style: AppTextStyles.display.copyWith(
            fontSize: 28,
            color: palette.text,
          ),
        ),
        Text(
          l10n.scanWhatsOnPaper,
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
    final l10n = context.l10n;
    final title = mode.title(l10n);
    return Semantics(
      button: true,
      label: title,
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelStrong.copyWith(
                      color: palette.text,
                    ),
                  ),
                  Text(
                    mode.hint(l10n),
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

  static String _subtitle(Scan scan, AppLocalizations l10n) {
    final what = switch (scan.mode) {
      ScanMode.solve =>
        scan.threadId == null
            ? l10n.scanStatusRead
            : l10n.scanStatusSolvedInAskMe,
      ScanMode.ask =>
        scan.threadId == null
            ? l10n.scanStatusRead
            : l10n.scanStatusAskedInAskMe,
      ScanMode.check => switch (scan.result) {
        final result? => l10n.scanStatusMarks(result.awarded, result.marks),
        null => l10n.scanStatusNotMarked,
      },
      ScanMode.notes => switch ((scan.folderId, scan.deckId)) {
        (_, _?) => l10n.scanStatusLessonInFolder,
        (_?, null) => l10n.scanStatusNotesInFolder,
        _ => l10n.scanStatusNotSaved,
      },
    };
    final when = relativeDayLabel(l10n, scan.createdAt.toLocal());
    return [what, if (scan.chapter.isNotEmpty) scan.chapter, when].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l10n.scanRecent),
        for (final scan in scans)
          LinkRow(
            icon: scan.mode.icon,
            title: scan.title,
            subtitle: _subtitle(scan, l10n),
            onTap: () => onOpen(scan),
          ),
      ],
    );
  }
}
