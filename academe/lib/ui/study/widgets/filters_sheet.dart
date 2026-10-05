import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../view_models/chapter_filters.dart';

class FiltersSheet extends StatefulWidget {
  const FiltersSheet({super.key, required this.initial, required this.count});

  final ChapterFilters initial;
  final int Function(ChapterFilters filters) count;

  static const descriptions = {
    ChapterFlag.boardOnly: ('Board exam only', 'Hide school-assessed chapters'),
    ChapterFlag.ready: ('Ready to study', 'Hide chapters still coming soon'),
    ChapterFlag.revisionDue: (
      'Revision due',
      'Chapters with kept cards to revise',
    ),
  };

  static Future<ChapterFilters?> show(
    BuildContext context, {
    required ChapterFilters initial,
    required int Function(ChapterFilters filters) count,
  }) => showModalBottomSheet<ChapterFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
    showDragHandle: true,
    builder: (_) => FiltersSheet(initial: initial, count: count),
  );

  @override
  State<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<FiltersSheet> {
  late ChapterFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final count = widget.count(_filters);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: AppTextStyles.display.copyWith(
                      fontSize: 24,
                      color: palette.text,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _filters = const ChapterFilters()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Clear', style: AppTextStyles.labelStrong),
                ),
              ],
            ),
            for (final flag in ChapterFlag.values)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _filters.has(flag),
                onChanged: (_) =>
                    setState(() => _filters = _filters.toggle(flag)),
                activeTrackColor: AppColors.primary,
                title: Text(
                  FiltersSheet.descriptions[flag]!.$1,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: palette.text,
                  ),
                ),
                subtitle: Text(
                  FiltersSheet.descriptions[flag]!.$2,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'SORT',
              style: AppTextStyles.caption.copyWith(
                color: palette.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: .6,
              ),
            ),
            const SizedBox(height: 8),
            _SortChoice(
              value: _filters.sort,
              onChanged: (sort) =>
                  setState(() => _filters = _filters.sortBy(sort)),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Show $count chapter${count == 1 ? '' : 's'}',
              isPrimary: true,
              onTap: () => Navigator.of(context).pop(_filters),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChoice extends StatelessWidget {
  const _SortChoice({required this.value, required this.onChanged});

  final ChapterSort value;
  final ValueChanged<ChapterSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final sort in ChapterSort.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: sort == value,
                  child: GestureDetector(
                    onTap: () => onChanged(sort),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: sort == value
                            ? palette.surface
                            : palette.surfaceRaised,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: sort == value
                            ? Border.all(
                                color: palette.edge,
                                width: AppKeycap.borderWidth,
                              )
                            : null,
                      ),
                      child: Text(
                        sort.label,
                        style: AppTextStyles.labelStrong.copyWith(
                          color: sort == value
                              ? palette.text
                              : palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
