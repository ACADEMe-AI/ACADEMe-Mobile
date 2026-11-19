import 'package:flutter/material.dart';

import '../themes/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.isAutofocused = false,
    this.onSubmitted,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool isAutofocused;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      autofocus: isAutofocused,
      autocorrect: false,
      onSubmitted: onSubmitted,
      style: AppTextStyles.input.copyWith(color: context.palette.text),
      decoration: appFieldDecoration(context, label, errorText: errorText),
    );
  }
}

InputDecoration appFieldDecoration(
  BuildContext context,
  String label, {
  Widget? suffix,
  String? errorText,
}) {
  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: context.palette.textMuted),
    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontWeight: FontWeight.w600,
    ),
    errorText: errorText,
    filled: true,
    fillColor: context.palette.surface,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.all(16),
    enabledBorder: outline(context.palette.border),
    focusedBorder: outline(AppColors.primary, 1.6),
    errorBorder: outline(AppColors.error),
    focusedErrorBorder: outline(AppColors.error, 1.6),
  );
}
