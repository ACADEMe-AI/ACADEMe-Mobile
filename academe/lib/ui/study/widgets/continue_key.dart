import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';

class ContinueKey extends StatelessWidget {
  const ContinueKey({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Keycap(
      face: AppColors.primary,
      depth: 4,
      height: 84,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.display.copyWith(
                      fontSize: 20,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.onPrimary,
                borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
