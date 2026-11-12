import 'package:flutter/material.dart';

import '../l10n/app_l10n.dart';
import '../themes/app_theme.dart';
import 'keycap.dart';
import 'pebby.dart';
import 'tab_bar_layout.dart';

class PebbyKeycapBanner extends StatelessWidget {
  const PebbyKeycapBanner({
    super.key,
    required this.face,
    required this.message,
    required this.pose,
    this.trailing,
    this.bottom,
    this.contentPadding = const EdgeInsets.fromLTRB(8, 4, 10, 6),
  });

  static const faceHeight = 52.0;
  static const pebbySlot = 44.0;

  final Color face;
  final String message;
  final double pose;
  final List<Widget>? trailing;
  final Widget? bottom;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final ink = context.palette.edge;
    return Keycap(
      face: face,
      depth: TabBarLayout.depth,
      height: faceHeight,
      radius: AppRadius.xl,
      child: Stack(
        children: [
          Padding(
            padding: contentPadding,
            child: Row(
              children: [
                SizedBox(
                  width: pebbySlot,
                  height: pebbySlot,
                  child: Semantics(
                    label: context.l10n.pebbySemantics,
                    child: Pebby(pose: pose),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...?trailing,
              ],
            ),
          ),
          if (bottom != null)
            Positioned(left: 0, right: 0, bottom: 0, child: bottom!),
        ],
      ),
    );
  }
}
