import 'package:flutter/material.dart';

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
                  'Ask Pebby anything',
                  style: AppTextStyles.labelStrong.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type a question, or tap Solve homework to snap one.',
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
                  child: const Text('Got it', style: AppTextStyles.labelStrong),
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
