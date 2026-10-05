import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';

class AskBar extends StatelessWidget {
  const AskBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Keycap(
      face: context.palette.surface,
      depth: 3,
      height: 52,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Ask anything…',
                style: AppTextStyles.label.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ),
            const _AskIcon(icon: Icons.mic_rounded),
          ],
        ),
      ),
    );
  }
}

class _AskIcon extends StatelessWidget {
  const _AskIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.palette.surfaceRaised,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 20, color: context.palette.text),
      ),
    );
  }
}
