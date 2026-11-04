import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/app_config.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/pebby.dart';

class SoftUpdateBanner extends StatelessWidget {
  const SoftUpdateBanner({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  static const _bannerHeight = 72.0;
  static const _pebbySlot = 64.0;

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
        : 'A new version of ACADEMe is on Google Play.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      child: Keycap(
        face: palette.tintLavender,
        depth: AppKeycap.optionDepth,
        height: _bannerHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
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
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(color: ink),
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
