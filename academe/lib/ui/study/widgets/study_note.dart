import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class StudyNote extends StatelessWidget {
  const StudyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.palette.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(color: context.palette.textMuted),
        ),
      ),
    );
  }
}
