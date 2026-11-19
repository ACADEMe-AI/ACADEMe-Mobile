import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class FaceCard extends StatelessWidget {
  const FaceCard({
    super.key,
    required this.child,
    this.tint,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final Color? tint;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final face = tint ?? context.palette.surfaceRaised;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: face,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.palette.border, width: 2),
        boxShadow: const [
          BoxShadow(color: AppColors.keycapEdge, offset: Offset(3, 3)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
