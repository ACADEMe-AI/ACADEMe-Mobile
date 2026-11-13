import 'package:flutter/material.dart';

import '../../../domain/models/streak.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import 'xp_chip.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({
    super.key,
    required this.hello,
    required this.syllabus,
    required this.xpKey,
    required this.xp,
    required this.streak,
  });

  final String hello;
  final String? syllabus;
  final GlobalKey xpKey;
  final int xp;
  final Streak streak;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hello,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display.copyWith(
                  fontSize: 28,
                  color: context.palette.text,
                ),
              ),
              if (syllabus case final label?)
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.palette.textMuted,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: context.l10n.homeStreakSemantics(streak.current),
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: streak.isTodayCounted
                    ? AppColors.streak
                    : context.palette.border,
              ),
              Text(
                '${streak.current}',
                style: AppTextStyles.labelStrong.copyWith(
                  color: streak.isTodayCounted
                      ? context.palette.text
                      : context.palette.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        XpChip(key: xpKey, xp: xp),
      ],
    );
  }
}
