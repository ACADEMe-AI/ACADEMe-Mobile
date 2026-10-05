import 'package:flutter/material.dart';

import '../../../utils/plural.dart';
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
                    label: flag.label,
                    onRemove: () => onChanged(filters.toggle(flag)),
                  ),
                if (filters.sort != ChapterSort.textbook)
                  _Chip(
                    label: filters.sort.label,
                    onRemove: () =>
                        onChanged(filters.sortBy(ChapterSort.textbook)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            pluralize(count, 'chapter'),
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
    return Semantics(
      button: true,
      label: 'Remove $label',
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
