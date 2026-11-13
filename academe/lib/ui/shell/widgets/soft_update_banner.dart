import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/app_config.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/pebby_keycap_banner.dart';
import '../../core/ui/tab_bar_layout.dart';

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

  static const faceHeight = PebbyKeycapBanner.faceHeight;
  static const gapAboveNav = 8.0;

  static double get reservedHeight =>
      faceHeight + TabBarLayout.depth + gapAboveNav;

  final AppConfig config;
  final VoidCallback onDismiss;

  Future<void> _openStore() async {
    if (await canLaunchUrl(config.updateUrl)) {
      await launchUrl(config.updateUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final ink = palette.text;
    final message = config.updateMessage.isNotEmpty
        ? config.updateMessage
        : l10n.softUpdateDefaultMessage;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, gapAboveNav),
      child: PebbyKeycapBanner(
        face: palette.tintLavender,
        message: message,
        pose: PebbyPose.encourage,
        contentPadding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
        trailing: [
          TextButton(
            onPressed: _openStore,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.softUpdateAction),
          ),
          IconButton(
            tooltip: l10n.softUpdateDismiss,
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.close, color: ink, size: 20),
          ),
        ],
      ),
    );
  }
}
