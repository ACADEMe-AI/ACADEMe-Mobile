import 'package:flutter/material.dart';

import '../../../domain/models/profile.dart';
import '../../core/themes/app_theme.dart';

class PickSubjectsCard extends StatelessWidget {
  const PickSubjectsCard({
    super.key,
    required this.onPick,
    required this.onDismiss,
  });

  final VoidCallback onPick;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: Ink(
          decoration: BoxDecoration(
            color: palette.tintLavender,
            borderRadius: BorderRadius.circular(AppRadius.lg + 2),
            border: Border.all(
              color: palette.edge,
              width: AppKeycap.borderWidth,
            ),
            boxShadow: [
              BoxShadow(color: palette.edge, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              children: [
                Icon(Icons.library_books_rounded, color: palette.text),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick your subjects',
                        style: AppTextStyles.display.copyWith(
                          fontSize: 18,
                          color: palette.text,
                        ),
                      ),
                      Text(
                        'Home and Study show only the ones you take. '
                        '+${Profile.subjectsReward} XP',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onDismiss,
                  tooltip: 'Not now',
                  icon: Icon(Icons.close_rounded, color: palette.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
