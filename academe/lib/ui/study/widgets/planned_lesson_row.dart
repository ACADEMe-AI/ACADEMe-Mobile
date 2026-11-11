import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';

class PlannedLessonRow extends StatelessWidget {
  const PlannedLessonRow({
    super.key,
    required this.position,
    required this.title,
  });

  final int position;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceRaised,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: Text(
                  '$position',
                  style: AppTextStyles.display.copyWith(
                    fontSize: 17,
                    color: palette.textMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: palette.textMuted,
                  ),
                ),
                Text(
                  l10n.studyComingSoon,
                  style: AppTextStyles.caption.copyWith(
                    color: palette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.schedule_rounded, color: palette.textMuted),
        ],
      ),
    );
  }
}
