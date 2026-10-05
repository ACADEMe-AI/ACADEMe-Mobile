import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/app_text_field.dart';
import '../../core/ui/pebby.dart';
import '../view_models/forgot_password_view_model.dart';
import 'auth_page.dart';
import 'failure_line.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.viewModel,
    this.onCodeSent,
  });

  final ForgotPasswordViewModel viewModel;
  final ValueChanged<String>? onCodeSent;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final _email = TextEditingController(text: widget.viewModel.email);
  Result<void>? _handedOff;

  ForgotPasswordViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => _viewModel.setEmail(_email.text));
    _viewModel.sendCode.addListener(_onSent);
  }

  @override
  void dispose() {
    _viewModel.sendCode.removeListener(_onSent);
    _viewModel.dispose();
    _email.dispose();
    super.dispose();
  }

  void _onSent() {
    final result = _viewModel.sendCode.result;
    if (result is! Ok || identical(result, _handedOff)) return;
    _handedOff = result;
    widget.onCodeSent?.call(_viewModel.email);
  }

  void _send() {
    if (!_viewModel.canSend) return;
    FocusScope.of(context).unfocus();
    _viewModel.sendCode.execute();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      lead: 'Forgot your',
      accent: 'password?',
      subtitle: "Type your email and I'll send you a 6-digit code.",
      pebby: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Pebby(
          pose: _viewModel.sendCode.isRunning
              ? PebbyPose.think
              : _viewModel.failure != null
              ? PebbyPose.encourage
              : _viewModel.email.isEmpty
              ? PebbyPose.happy
              : PebbyPose.focused,
        ),
      ),
      children: [
        AppTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          isAutofocused: _viewModel.email.isEmpty,
          onSubmitted: (_) => _send(),
        ),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => FailureLine(failure: _viewModel.failure),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => AppButton(
            label: _viewModel.sendCode.isRunning ? 'Sending…' : 'Send code',
            isPrimary: true,
            isEnabled: _viewModel.canSend,
            onTap: _send,
          ),
        ),
      ],
    );
  }
}
