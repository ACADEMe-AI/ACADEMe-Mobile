import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../domain/models/profile.dart';
import '../../../core/themes/app_theme.dart';

class SetupRewardFlight extends StatelessWidget {
  const SetupRewardFlight({
    super.key,
    required this.progress,
    required this.from,
    required this.to,
  });

  final Animation<double> progress;
  final Rect from;
  final Rect to;

  static const duration = Duration(milliseconds: 1500);
  static const _pillSize = Size(104, 44);

  static const _green = Interval(0, .22, curve: Curves.easeOut);
  static const _shrink = Interval(.3, .56, curve: Curves.easeInOutCubic);
  static const _fly = Interval(.64, 1, curve: Curves.easeInCubic);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value;
        final green = _green.transform(t);
        final shrink = _shrink.transform(t);
        final fly = _fly.transform(t);
        final pill = Rect.fromCenter(
          center: from.center,
          width: _pillSize.width,
          height: _pillSize.height,
        );
        final rect = Rect.lerp(Rect.lerp(from, pill, shrink), to, fly)!;
        final isPlus = shrink >= .5;
        final face = isPlus
            ? Color.lerp(
                context.palette.success,
                AppColors.selected,
                (shrink - .5) * 2,
              )!
            : Color.lerp(
                context.palette.tintCream,
                context.palette.success,
                green,
              )!;
        final radius = lerpDouble(
          AppRadius.lg + 2,
          rect.shortestSide / 2,
          shrink,
        )!;
        return Positioned.fromRect(
          rect: rect,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: face,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: context.palette.edge,
                width: AppKeycap.borderWidth,
              ),
            ),
            child: Center(
              child: FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: isPlus
                      ? Text(
                          '+${Profile.setupReward}',
                          style: AppTextStyles.display.copyWith(
                            fontSize: 28,
                            color: AppColors.keycapEdge,
                          ),
                        )
                      : Icon(
                          Icons.check_rounded,
                          size: 72,
                          color: AppColors.onPrimary.withValues(alpha: green),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
