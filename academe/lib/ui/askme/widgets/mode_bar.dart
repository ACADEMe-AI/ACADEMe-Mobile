import 'package:flutter/material.dart';

import '../../../domain/models/chat.dart';
import '../../core/themes/app_theme.dart';

class ModeBar extends StatelessWidget {
  const ModeBar({super.key, required this.mode, required this.onSelect});

  final ChatMode mode;
  final ValueChanged<ChatMode> onSelect;

  static const slide = Duration(milliseconds: 320);
  static const icons = {
    ChatMode.explain: Icons.menu_book_rounded,
    ChatMode.solve: Icons.extension_rounded,
    ChatMode.quiz: Icons.task_alt_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final count = ChatMode.values.length;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.palette.edge,
          width: AppKeycap.borderWidth,
        ),
        boxShadow: [
          BoxShadow(color: context.palette.edge, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: SizedBox(
          height: 36,
          child: Stack(
            children: [
              AnimatedAlign(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : slide,
                curve: Curves.easeInOutCubic,
                alignment: Alignment(
                  count == 1 ? 0 : -1 + 2 * mode.index / (count - 1),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / count,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.selected,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.md),
                      ),
                      border: Border.fromBorderSide(
                        BorderSide(
                          color: context.palette.edge,
                          width: AppKeycap.borderWidth,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  children: [
                    for (final value in ChatMode.values)
                      Expanded(
                        child: _ModeOption(
                          icon: icons[value]!,
                          label: value.label,
                          isSelected: value == mode,
                          onTap: () => onSelect(value),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.keycapEdge : context.palette.textMuted;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              turns: isSelected ? -.02 : 0,
              duration: ModeBar.slide,
              curve: Curves.easeOutBack,
              child: AnimatedScale(
                scale: isSelected ? 1.15 : 1,
                duration: ModeBar.slide,
                curve: Curves.easeOutBack,
                child: Icon(icon, size: 16, color: color),
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: DefaultTextStyle.of(context).style.merge(
                  AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
