import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/auth_failure.dart';
import '../../../utils/result.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/inline_link.dart';
import '../../core/ui/pebby.dart';
import '../view_models/reset_code_view_model.dart';
import 'auth_page.dart';
import 'code_field.dart';
import 'failure_line.dart';

class ResetCodeScreen extends StatefulWidget {
  const ResetCodeScreen({super.key, required this.viewModel, this.onVerified});

  final ResetCodeViewModel viewModel;
  final ValueChanged<String>? onVerified;

  @override
  State<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends State<ResetCodeScreen> {
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  Result<String>? _handedOff;

  ResetCodeViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => _viewModel.setCode(_code.text));
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_code.text != _viewModel.code) {
      _code.value = TextEditingValue(
        text: _viewModel.code,
        selection: TextSelection.collapsed(offset: _viewModel.code.length),
      );
    }
    final result = _viewModel.verify.result;
    if (result is Ok<String> && !identical(result, _handedOff)) {
      _handedOff = result;
      HapticFeedback.lightImpact();
      widget.onVerified?.call(result.value);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && mounted) _viewModel.setCode(text);
  }

  void _verify() {
    if (_viewModel.canVerify) _viewModel.verify.execute();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      lead: 'Check your',
      accent: 'email.',
      subtitle:
          'If ${_viewModel.email} has an ACADEMe account, a 6-digit code '
          'is on its way. It expires in 15 minutes.',
      pebby: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => Pebby(
          pose: _viewModel.verify.isRunning || _viewModel.resend.isRunning
              ? PebbyPose.think
              : _viewModel.verify.isCompleted
              ? PebbyPose.celebrateSmall
              : _viewModel.failure != null
              ? PebbyPose.encourage
              : _viewModel.code.isEmpty
              ? PebbyPose.reading
              : PebbyPose.focused,
        ),
      ),
      children: [
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => CodeField(
            controller: _code,
            focusNode: _codeFocus,
            code: _viewModel.code,
            length: ResetCodeViewModel.codeLength,
            hasError: _viewModel.failure == AuthFailure.wrongCode,
            isEnabled: !_viewModel.isCodeUsedUp,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _paste,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            icon: const Icon(Icons.content_paste_rounded, size: 18),
            label: const Text('Paste code', style: AppTextStyles.labelStrong),
          ),
        ),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => FailureLine(failure: _viewModel.failure),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => AppButton(
            label: _viewModel.verify.isRunning ? 'Checking…' : 'Verify',
            isPrimary: true,
            isEnabled: _viewModel.canVerify,
            onTap: _verify,
          ),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _Resend(viewModel: _viewModel),
        ),
      ],
    );
  }
}

class _Resend extends StatelessWidget {
  const _Resend({required this.viewModel});

  final ResetCodeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.canResend) {
      return InlineLink(
        lead: "Didn't get it? ",
        action: 'Send a new code',
        onTap: viewModel.resend.execute,
      );
    }
    final seconds = viewModel.resendIn.inSeconds.toString().padLeft(2, '0');
    final text = viewModel.resend.isRunning
        ? 'Sending a new code…'
        : viewModel.resend.isCompleted
        ? 'New code sent. You can ask again in 0:$seconds'
        : 'You can ask for a new code in 0:$seconds';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.label.copyWith(color: context.palette.textMuted),
      ),
    );
  }
}
