import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../view_models/study_view_model.dart';
import 'filters_sheet.dart';
import 'pill_choices.dart';

class StatusFilterRow extends StatelessWidget {
  const StatusFilterRow({
    super.key,
    required this.status,
    required this.onStatus,
    required this.filters,
    required this.onFilters,
    required this.count,
  });

  final ChapterFilter status;
  final ValueChanged<ChapterFilter> onStatus;
  final ChapterFilters filters;
  final ValueChanged<ChapterFilters> onFilters;
  final int Function(ChapterFilters filters) count;

  Future<void> _open(BuildContext context) async {
    final picked = await FiltersSheet.show(
      context,
      initial: filters,
      count: count,
    );
    if (picked != null) onFilters(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PillChoices(
            choices: [for (final f in ChapterFilter.values) (f, f.label)],
            selected: status,
            onSelect: onStatus,
            isOneRow: true,
          ),
        ),
        const SizedBox(width: 8),
        _FiltersKey(count: filters.count, onTap: () => _open(context)),
      ],
    );
  }
}

class _FiltersKey extends StatelessWidget {
  const _FiltersKey({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      label: count == 0 ? 'Filters' : 'Filters, $count on',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(color: palette.edge, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 20, color: palette.text),
              if (count > 0) ...[
                const SizedBox(width: 4),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '$count',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
