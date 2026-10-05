import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'app_text_field.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.autofillHints = const [AutofillHints.password],
    this.isAutofocused = false,
    this.onSubmitted,
    this.onHiddenChanged,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final bool isAutofocused;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onHiddenChanged;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _isHidden = true;

  void _toggle() {
    setState(() => _isHidden = !_isHidden);
    widget.onHiddenChanged?.call(_isHidden);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _isHidden,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      autofocus: widget.isAutofocused,
      onSubmitted: widget.onSubmitted,
      style: AppTextStyles.input.copyWith(color: context.palette.text),
      decoration: appFieldDecoration(
        context,
        widget.label,
        suffix: IconButton(
          tooltip: _isHidden ? 'Show password' : 'Hide password',
          onPressed: _toggle,
          icon: Icon(
            _isHidden
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: context.palette.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }
}
