import 'package:flutter/material.dart';

import '../../../domain/models/level.dart';
import '../../../domain/models/streak.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';

class MeStats extends StatelessWidget {
  const MeStats({
    super.key,
    required this.xp,
    required this.level,
    required this.streak,
  });

  final int xp;
  final Level level;
  final Streak streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            leading: Icon(
              Icons.local_fire_department_rounded,
              size: 22,
              color: streak.isTodayCounted
                  ? AppColors.streak
                  : context.palette.border,
            ),
            value: '${streak.current}',
            label: context.l10n.meDayStreak,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Stat(
            value: context.l10n.meLevelValue(level.number),
            label: context.l10n.meXpToNextLevel(
              level.toNext(xp),
              level.number + 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Stat(
            leading: const Icon(
              Icons.bolt_rounded,
              size: 22,
              color: AppColors.selected,
            ),
            value: '$xp',
            label: context.l10n.meXpLabel,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.leading});

  final String value;
  final String label;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ?leading,
                Text(
                  value,
                  style: AppTextStyles.display.copyWith(
                    fontSize: 22,
                    color: context.palette.text,
                  ),
                ),
              ],
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
