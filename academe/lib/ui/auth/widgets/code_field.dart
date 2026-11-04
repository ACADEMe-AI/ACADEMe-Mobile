import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/app_theme.dart';

class CodeField extends StatelessWidget {
  const CodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.code,
    required this.length,
    this.hasError = false,
    this.isEnabled = true,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String code;
  final int length;
  final bool hasError;
  final bool isEnabled;

  static const boxHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    final hidden = context.palette.text.withValues(alpha: 0);
    return Semantics(
      label: '$length-digit code',
      child: SizedBox(
        height: boxHeight,
        child: Stack(
          children: [
            ListenableBuilder(
              listenable: focusNode,
              builder: (context, _) => Row(
                children: [
                  for (var i = 0; i < length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _DigitBox(
                        digit: i < code.length ? code[i] : '',
                        isActive:
                            focusNode.hasFocus &&
                            (i == code.length ||
                                (i == length - 1 && code.length == length)),
                        hasError: hasError,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                showCursor: false,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(color: hidden, fontSize: 1),
                cursorColor: hidden,
                decoration: const InputDecoration.collapsed(hintText: null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final border = hasError
        ? AppColors.error
        : isActive
        ? AppColors.primary
        : palette.border;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: digit.isEmpty ? palette.surface : palette.tintLavender,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border, width: isActive || hasError ? 2 : 1),
      ),
      child: Text(
        digit,
        style: AppTextStyles.display.copyWith(
          fontSize: 28,
          color: hasError ? palette.errorInk : palette.text,
        ),
      ),
    );
  }
}
