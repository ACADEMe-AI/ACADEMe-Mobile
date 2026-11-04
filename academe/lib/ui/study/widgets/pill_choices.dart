import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class PillChoices<T> extends StatelessWidget {
  const PillChoices({
    super.key,
    required this.choices,
    required this.selected,
    required this.onSelect,
    this.isOneRow = false,
  });

  final List<(T, String)> choices;
  final T? selected;
  final ValueChanged<T> onSelect;
  final bool isOneRow;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pills = [
      for (final (value, label) in choices)
        Semantics(
          button: true,
          selected: value == selected,
          child: GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: value == selected ? AppColors.selected : palette.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: palette.edge,
                  width: AppKeycap.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(color: palette.edge, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                label,
                style: AppTextStyles.labelStrong.copyWith(
                  color: value == selected
                      ? AppColors.keycapEdge
                      : palette.text,
                ),
              ),
            ),
          ),
        ),
    ];
    if (!isOneRow) return Wrap(spacing: 8, runSpacing: 8, children: pills);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final (i, pill) in pills.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            pill,
          ],
        ],
      ),
    );
  }
}
