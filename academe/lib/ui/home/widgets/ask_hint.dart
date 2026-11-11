import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';

class AskHint extends StatelessWidget {
  const AskHint({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 24),
          child: CustomPaint(size: Size(16, 8), painter: _Pointer()),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.keycapEdge,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.homeAskHintTitle,
                  style: AppTextStyles.labelStrong.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.homeAskHintBody,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.selected,
                    foregroundColor: AppColors.keycapEdge,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    context.l10n.homeAskHintGotIt,
                    style: AppTextStyles.labelStrong,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pointer extends CustomPainter {
  const _Pointer();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..close(),
      Paint()..color = AppColors.keycapEdge,
    );
  }

  @override
  bool shouldRepaint(_Pointer oldDelegate) => false;
}
