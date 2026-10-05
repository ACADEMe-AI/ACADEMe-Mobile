import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';

class PickerSheet extends StatelessWidget {
  const PickerSheet({
    super.key,
    required this.title,
    required this.onDone,
    required this.child,
    this.note,
  });

  final String title;
  final VoidCallback onDone;
  final Widget child;
  final String? note;

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) => showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    barrierColor: AppColors.keycapEdge.withValues(alpha: .35),
    showDragHandle: true,
    builder: builder,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.display.copyWith(
              fontSize: 24,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: child),
          if (note case final text?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: context.palette.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 16),
          AppButton(label: 'OK', isPrimary: true, onTap: onDone),
        ],
      ),
    );
  }
}
