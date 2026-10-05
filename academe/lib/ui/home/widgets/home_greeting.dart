import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import 'xp_chip.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({
    super.key,
    required this.name,
    required this.syllabus,
    required this.xpKey,
    required this.xp,
  });

  final String name;
  final String? syllabus;
  final GlobalKey xpKey;
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name!',
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
        Icon(
          Icons.local_fire_department_rounded,
          size: 20,
          color: context.palette.border,
        ),
        Text(
          '0',
          style: AppTextStyles.labelStrong.copyWith(
            color: context.palette.textMuted,
          ),
        ),
        const SizedBox(width: 12),
        XpChip(key: xpKey, xp: xp),
      ],
    );
  }
}
