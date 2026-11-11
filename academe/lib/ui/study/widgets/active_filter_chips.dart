import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../view_models/chapter_filters.dart';

class ActiveFilterChips extends StatelessWidget {
  const ActiveFilterChips({
    super.key,
    required this.filters,
    required this.onChanged,
    required this.count,
  });

  final ChapterFilters filters;
  final ValueChanged<ChapterFilters> onChanged;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    String flagLabel(ChapterFlag flag) => switch (flag) {
      ChapterFlag.boardOnly => l10n.filterFlagBoardExam,
      ChapterFlag.ready => l10n.filterFlagReady,
      ChapterFlag.revisionDue => l10n.filterFlagRevisionDue,
    };
    String sortLabel(ChapterSort sort) => switch (sort) {
      ChapterSort.textbook => l10n.filterSortTextbook,
      ChapterSort.marks => l10n.filterSortMostMarks,
      ChapterSort.recent => l10n.filterSortRecent,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final flag in filters.flags)
                  _Chip(
                    label: flagLabel(flag),
                    onRemove: () => onChanged(filters.toggle(flag)),
                  ),
                if (filters.sort != ChapterSort.textbook)
                  _Chip(
                    label: sortLabel(filters.sort),
                    onRemove: () =>
                        onChanged(filters.sortBy(ChapterSort.textbook)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.studyChaptersCount(count),
            style: AppTextStyles.caption.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: l10n.filterRemove(label),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onRemove,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
          decoration: BoxDecoration(
            color: palette.tintLavender,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 16, color: palette.text),
            ],
          ),
        ),
      ),
    );
  }
}
