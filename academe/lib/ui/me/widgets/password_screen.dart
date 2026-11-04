import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/view_models/sign_up_view_model.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../auth/widgets/password_length_check.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/app_password_field.dart';
import '../view_models/me_view_model.dart';
import 'settings_page.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key, required this.viewModel});

  final MeViewModel viewModel;

  static const changedMessage =
      'Password changed. Other devices have been logged out.';
  static const setMessage =
      'Password set. You can now log in with your email too.';

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  late final bool _hasPassword = widget.viewModel.hasPassword;
  final _current = TextEditingController();
  final _next = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  bool get _isLongEnough => SignUpViewModel.isLongEnough(_next.text);

  bool get _canSave =>
      _isLongEnough &&
      (!_hasPassword || _current.text.isNotEmpty) &&
      !widget.viewModel.changePassword.isRunning;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final command = widget.viewModel.changePassword;
    await command.execute((
      current: _hasPassword ? _current.text : null,
      next: _next.text,
    ));
    if (!mounted) return;
    switch (command.result) {
      case Ok():
        Navigator.of(context).pop(
          _hasPassword
              ? PasswordScreen.changedMessage
              : PasswordScreen.setMessage,
        );
      case Error(:final error):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failureMessage(error))));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.viewModel.changePassword;
    return SettingsPage(
      title: _hasPassword ? 'Change password' : 'Set a password',
      bottom: ListenableBuilder(
        listenable: Listenable.merge([saving, _current, _next]),
        builder: (context, _) => AppButton(
          label: saving.isRunning ? 'Saving…' : 'Save password',
          isPrimary: true,
          isEnabled: _canSave,
          onTap: _save,
        ),
      ),
      children: [
        const SizedBox(height: 8),
        Text(
          _hasPassword
              ? 'Use the same rules as when you signed up. Other devices '
                    'are logged out when you save.'
              : 'Add a password so you can also log in with your email, '
                    'not just Google.',
          style: AppTextStyles.label.copyWith(
            color: context.palette.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        if (_hasPassword) ...[
          AppPasswordField(
            controller: _current,
            label: 'Current password',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
        ],
        AppPasswordField(
          controller: _next,
          label: 'New password',
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) => _canSave ? _save() : null,
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: _next,
          builder: (context, _) => PasswordLengthCheck(isMet: _isLongEnough),
        ),
      ],
    );
  }
}
