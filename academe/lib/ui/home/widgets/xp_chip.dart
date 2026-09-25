import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class XpChip extends StatefulWidget {
  const XpChip({super.key, required this.xp});

  final int xp;

  @override
  State<XpChip> createState() => _XpChipState();
}

class _XpChipState extends State<XpChip> with SingleTickerProviderStateMixin {
  late final _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final _scale = _pop.drive(
    TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.35,
          end: 1,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]),
  );

  @override
  void didUpdateWidget(XpChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.xp > oldWidget.xp) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        label: '${widget.xp} XP',
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.selected,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: context.palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: context.palette.edge,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 8, 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: AppColors.keycapEdge,
                ),
                Text(
                  '${widget.xp} XP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.keycapEdge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
