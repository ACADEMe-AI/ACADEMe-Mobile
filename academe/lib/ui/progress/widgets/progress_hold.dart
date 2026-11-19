import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/keycap_surface.dart';
import '../../core/ui/pebby.dart';

class ProgressHold extends StatelessWidget {
  const ProgressHold({super.key, required this.onGoPro});

  final VoidCallback onGoPro;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = context.l10n;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: ColoredBox(
          color: palette.surface.withValues(alpha: .42),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: KeycapSurface(
                    shadowDepth: 4,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 132,
                          child: FittedBox(
                            child: SizedBox.square(
                              dimension: 160,
                              child: Semantics(
                                label: l10n.pebbySemantics,
                                child: const Pebby(
                                  pose: PebbyPose.progressGate,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.progressHoldTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.sheetTitle.copyWith(
                            color: palette.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.progressHoldBody,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.label.copyWith(
                            color: palette.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: l10n.progressGoProLimits,
                          isPrimary: true,
                          onTap: onGoPro,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
