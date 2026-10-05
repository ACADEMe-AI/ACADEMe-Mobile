import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class LightField extends StatelessWidget {
  const LightField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: color, width: AppKeycap.borderWidth),
    );
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      minLines: 1,
      maxLines: maxLines,
      style: AppTextStyles.input.copyWith(color: context.palette.text),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        labelStyle: AppTextStyles.label.copyWith(
          color: context.palette.textMuted,
        ),
        filled: true,
        fillColor: context.palette.surface,
        enabledBorder: border(context.palette.edge),
        focusedBorder: border(AppColors.primary),
      ),
    );
  }
}
