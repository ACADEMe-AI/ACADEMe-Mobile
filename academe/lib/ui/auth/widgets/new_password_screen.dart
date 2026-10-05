import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/ui/app_button.dart';
import '../../core/ui/app_password_field.dart';
import '../../core/ui/pebby.dart';
import '../view_models/new_password_view_model.dart';
import 'auth_page.dart';
import 'failure_line.dart';
import 'password_length_check.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    super.key,
    required this.viewModel,
    this.onDone,
    this.onStartOver,
  });

  final NewPasswordViewModel viewModel;
  final VoidCallback? onDone;
  final VoidCallback? onStartOver;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _password = TextEditingController();
  final _isPasswordHidden = ValueNotifier(true);
  Timer? _handOff;

  static const _celebrationLength = Duration(milliseconds: 900);

  NewPasswordViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => _viewModel.setPassword(_password.text));
    _viewModel.save.addListener(_onSaved);
  }

  @override
  void dispose() {
    _handOff?.cancel();
    _viewModel.save.removeListener(_onSaved);
    _viewModel.dispose();
    _password.dispose();
    _isPasswordHidden.dispose();
    super.dispose();
  }

  void _onSaved() {
    if (_viewModel.save.isCompleted && _handOff == null) {
      HapticFeedback.mediumImpact();
      _handOff = Timer(_celebrationLength, () => widget.onDone?.call());
    }
  }

  void _save() {
    if (!_viewModel.canSave) return;
    FocusScope.of(context).unfocus();
    _viewModel.save.execute();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      lead: 'Choose a new',
      accent: 'password.',
      subtitle: "At least 8 characters. Don't worry, I won't look.",
      pebby: ListenableBuilder(
        listenable: Listenable.merge([_viewModel, _isPasswordHidden]),
        builder: (context, _) => Pebby(
          pose: _viewModel.save.isRunning
              ? PebbyPose.think
              : _viewModel.save.isCompleted
              ? PebbyPose.celebrateSmall
              : _viewModel.failure != null
              ? PebbyPose.encourage
              : _isPasswordHidden.value
              ? PebbyPose.coverEyes
              : PebbyPose.shy,
        ),
      ),
      children: [
        AppPasswordField(
          controller: _password,
          label: 'New password',
          autofillHints: const [AutofillHints.newPassword],
          isAutofocused: true,
          onSubmitted: (_) => _save(),
          onHiddenChanged: (isHidden) => _isPasswordHidden.value = isHidden,
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) =>
              PasswordLengthCheck(isMet: _viewModel.isPasswordLongEnough),
        ),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => FailureLine(failure: _viewModel.failure),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) => _viewModel.hasExpired
              ? AppButton(
                  label: 'Start again',
                  isPrimary: true,
                  onTap: widget.onStartOver,
                )
              : AppButton(
                  label: _viewModel.save.isRunning
                      ? 'Saving…'
                      : 'Save and log in',
                  isPrimary: true,
                  isEnabled: _viewModel.canSave,
                  onTap: _save,
                ),
        ),
      ],
    );
  }
}
