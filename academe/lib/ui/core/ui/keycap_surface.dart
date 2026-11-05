import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class KeycapSurface extends StatelessWidget {
  const KeycapSurface({
    super.key,
    required this.child,
    this.face,
    this.padding = const EdgeInsets.all(12),
    this.shadowDepth = 3,
  });

  final Widget child;
  final Color? face;
  final EdgeInsetsGeometry padding;
  final double shadowDepth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: face ?? context.palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.palette.edge,
          width: AppKeycap.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: context.palette.edge,
            offset: Offset(0, shadowDepth),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
