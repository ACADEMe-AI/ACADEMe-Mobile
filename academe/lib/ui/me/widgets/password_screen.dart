import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/view_models/sign_up_view_model.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../auth/widgets/password_length_check.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/app_password_field.dart';
import '../../core/ui/top_notice.dart';
import '../view_models/me_view_model.dart';
import 'settings_page.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key, required this.viewModel});

  final MeViewModel viewModel;

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
              ? context.l10n.passwordChangedSnack
              : context.l10n.passwordSetSnack,
        );
      case Error(:final error):
        context.showTopNotice(
          failureMessage(error, context.l10n),
          kind: TopNoticeKind.error,
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saving = widget.viewModel.changePassword;
    return SettingsPage(
      title: _hasPassword
          ? l10n.accountChangePassword
          : l10n.accountSetPassword,
      bottom: ListenableBuilder(
        listenable: Listenable.merge([saving, _current, _next]),
        builder: (context, _) => AppButton(
          label: saving.isRunning ? l10n.authSaving : l10n.passwordSave,
          isPrimary: true,
          isEnabled: _canSave,
          onTap: _save,
        ),
      ),
      children: [
        const SizedBox(height: 8),
        Text(
          _hasPassword ? l10n.passwordChangeBody : l10n.passwordSetBody,
          style: AppTextStyles.label.copyWith(
            color: context.palette.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        if (_hasPassword) ...[
          AppPasswordField(
            controller: _current,
            label: l10n.passwordCurrent,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
        ],
        AppPasswordField(
          controller: _next,
          label: l10n.authNewPassword,
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
