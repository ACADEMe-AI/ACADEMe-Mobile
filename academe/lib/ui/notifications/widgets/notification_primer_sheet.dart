import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/pebby.dart';

class NotificationPrimerSheet extends StatelessWidget {
  const NotificationPrimerSheet({super.key});

  static Future<bool?> show(BuildContext context) => showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: context.palette.surface,
    barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
    showDragHandle: true,
    builder: (_) => const NotificationPrimerSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: SizedBox.square(
              dimension: 120,
              child: Pebby(pose: PebbyPose.encourage),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get a nudge before your test',
            textAlign: TextAlign.center,
            style: AppTextStyles.sheetTitle.copyWith(color: palette.text),
          ),
          const SizedBox(height: 16),
          const _Promise(
            icon: Icons.event_outlined,
            text:
                'A heads-up 3 days before, the evening before and the '
                'morning of each test',
          ),
          const _Promise(
            icon: Icons.schedule_outlined,
            text: 'Your study reminder, only on the days and time you pick',
          ),
          const _Promise(
            icon: Icons.tune_outlined,
            text: 'Nothing else. Change it any time in Me',
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Allow',
            isPrimary: true,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Not now',
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.label.copyWith(color: palette.text),
            ),
          ),
        ],
      ),
    );
  }
}
