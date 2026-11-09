import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/app_config.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/tab_bar_layout.dart';

/// Extra bottom scroll clearance while the soft-update banner is showing.
class SoftUpdateInset extends InheritedWidget {
  const SoftUpdateInset({
    super.key,
    required this.height,
    required super.child,
  });

  final double height;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SoftUpdateInset>()?.height ??
      0;

  @override
  bool updateShouldNotify(SoftUpdateInset oldWidget) =>
      height != oldWidget.height;
}

class SoftUpdateBanner extends StatelessWidget {
  const SoftUpdateBanner({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  /// Face height of the keycap (matches nav bar face, slightly shorter).
  static const faceHeight = 52.0;

  /// Gap between banner and the nav row (mock: 8).
  static const gapAboveNav = 8.0;

  /// Total height reserved above the nav for scroll padding.
  static double get reservedHeight =>
      faceHeight + TabBarLayout.depth + gapAboveNav;

  static const _pebbySlot = 44.0;

  final AppConfig config;
  final VoidCallback onDismiss;

  Future<void> _openStore() async {
    if (await canLaunchUrl(config.updateUrl)) {
      await launchUrl(config.updateUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const ink = AppColors.keycapEdge;
    final message = config.updateMessage.isNotEmpty
        ? config.updateMessage
        : 'New version just dropped, you don\'t wanna miss this!';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, gapAboveNav),
      child: Keycap(
        face: palette.tintLavender,
        depth: TabBarLayout.depth,
        height: faceHeight,
        radius: AppRadius.xl,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
          child: Row(
            children: [
              SizedBox(
                width: _pebbySlot,
                height: _pebbySlot,
                child: Semantics(
                  label: 'Pebby',
                  child: const Pebby(pose: PebbyPose.encourage),
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
              TextButton(
                onPressed: _openStore,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Update'),
              ),
              IconButton(
                tooltip: 'Not now',
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: const Icon(Icons.close, color: ink, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
