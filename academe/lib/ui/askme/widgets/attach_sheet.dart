import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class AttachSheet extends StatelessWidget {
  const AttachSheet({super.key, required this.onPick});

  final ValueChanged<String> onPick;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onPick,
  }) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.palette.surface,
    barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
    showDragHandle: true,
    builder: (_) => AttachSheet(onPick: onPick),
  );

  static const camera = 'Camera';
  static const photos = 'Photos';

  static final _options = <(IconData, String, Color Function(AppPalette))>[
    (Icons.photo_camera_rounded, camera, (p) => p.tintAmber),
    (Icons.photo_library_rounded, photos, (p) => p.tintLavender),
    (Icons.picture_as_pdf_rounded, 'PDF', (p) => p.tintPink),
    (Icons.menu_book_rounded, 'From Study', (p) => p.tintMint),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to your question',
              style: AppTextStyles.subhead.copyWith(
                fontSize: 16,
                color: context.palette.text,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final (icon, label, tint) in _options)
                  Expanded(
                    child: _Option(
                      icon: icon,
                      label: label,
                      tint: tint(context.palette),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPick(label);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: context.palette.edge,
                  width: AppKeycap.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.palette.edge,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: context.palette.text),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: context.palette.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
