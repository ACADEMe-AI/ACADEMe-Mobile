import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/ask_me_icon.dart';
import '../../core/ui/keycap.dart';

class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.isAsking = false,
    this.askController,
    this.askFocus,
    this.canSend = false,
    this.onSend,
    this.onAttach,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final bool isAsking;
  final TextEditingController? askController;
  final FocusNode? askFocus;
  final bool canSend;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  static const morph = Duration(milliseconds: 280);

  static const scanIndex = 2;
  static const barHeight = 64.0;
  static const depth = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _TabPill(
                  child: AnimatedSwitcher(
                    duration: morph,
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: Offset(child.key == _askKey ? 1 : -1, 0),
                          end: Offset.zero,
                        ),
                      ),
                      child: child,
                    ),
                    child: isAsking
                        ? _AskField(
                            key: _askKey,
                            controller: askController,
                            focusNode: askFocus,
                            onSend: onSend,
                            onAttach: onAttach,
                          )
                        : _Tabs(
                            key: _tabsKey,
                            selected: selected,
                            onSelect: onSelect,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Semantics(
                label: isAsking ? 'Send' : 'Scan',
                selected: !isAsking && selected == scanIndex,
                child: SizedBox(
                  width: barHeight,
                  child: Keycap(
                    face: AppColors.primary,
                    depth: depth,
                    height: barHeight - depth,
                    radius: AppRadius.xl,
                    isLatched: !isAsking && selected == scanIndex,
                    onTap: isAsking
                        ? (canSend ? onSend : null)
                        : () => onSelect(scanIndex),
                    child: AnimatedSwitcher(
                      duration: morph,
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                            turns: animation.drive(Tween(begin: -.25, end: 0)),
                            child: ScaleTransition(
                              scale: animation,
                              child: child,
                            ),
                          ),
                      child: Icon(
                        isAsking
                            ? Icons.arrow_upward_rounded
                            : Icons.photo_camera_rounded,
                        key: ValueKey(isAsking),
                        size: 28,
                        color: AppColors.onPrimary.withValues(
                          alpha: isAsking && !canSend ? .55 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _askKey = ValueKey('ask');
  static const _tabsKey = ValueKey('tabs');
}

class _Tabs extends StatelessWidget {
  const _Tabs({super.key, required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (index, icon, label) in const [
          (0, Icon(Icons.home_rounded), 'Home'),
          (1, AskMeIcon(), 'ASKMe'),
          (3, Icon(Icons.menu_book_rounded), 'Study'),
          (4, Icon(Icons.person_rounded), 'Me'),
        ])
          Expanded(
            child: _NavTab(
              icon: icon,
              label: label,
              isSelected: selected == index,
              onTap: () => onSelect(index),
            ),
          ),
      ],
    );
  }
}

class _AskField extends StatelessWidget {
  const _AskField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onSend;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend?.call(),
            style: AppTextStyles.input.copyWith(color: context.palette.text),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Ask anything…',
              hintStyle: AppTextStyles.label.copyWith(
                color: context.palette.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 16),
            ),
          ),
        ),
        IconButton(
          onPressed: onAttach,
          tooltip: 'Attach',
          icon: const Icon(Icons.add_rounded, size: 26),
          color: context.palette.text,
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppNavBar.depth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: context.palette.edge,
            width: AppKeycap.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: context.palette.edge,
              offset: const Offset(0, AppNavBar.depth),
            ),
          ],
        ),
        child: SizedBox(
          height: AppNavBar.barHeight - AppNavBar.depth,
          child: Padding(
            padding: const EdgeInsets.all(AppKeycap.borderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                AppRadius.xl - AppKeycap.borderWidth,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : context.palette.textMuted;
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 24),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
