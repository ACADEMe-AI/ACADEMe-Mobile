import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/celebration.dart';

class ResultLine extends StatelessWidget {
  const ResultLine({
    super.key,
    required this.isCorrect,
    required this.streak,
    required this.praise,
  });

  final bool isCorrect;
  final int streak;
  final String praise;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (!isCorrect) {
      return Text(
        'Not quite. Next: why.',
        textAlign: TextAlign.center,
        style: AppTextStyles.labelStrong.copyWith(color: palette.errorInk),
      );
    }
    return PopIn(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: palette.success,
              ),
              const SizedBox(width: 4),
              Text(
                praise,
                style: AppTextStyles.labelStrong.copyWith(
                  fontSize: 16,
                  color: palette.success,
                ),
              ),
            ],
          ),
          if (streak >= 2) ...[
            const SizedBox(height: 8),
            StreakChip(streak: streak),
          ],
        ],
      ),
    );
  }
}

class StreakChip extends StatelessWidget {
  const StreakChip({super.key, required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.tintAmber,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 18,
              color: AppColors.streak,
            ),
            const SizedBox(width: 4),
            Text(
              '$streak in a row',
              style: AppTextStyles.labelStrong.copyWith(color: palette.text),
            ),
          ],
        ),
      ),
    );
  }
}

class XpChip extends StatelessWidget {
  const XpChip({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.selected,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.keycapEdge, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bolt_rounded,
              size: 14,
              color: AppColors.keycapEdge,
            ),
            Text(
              '+$xp XP',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.keycapEdge,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
