import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/light_field.dart';
import '../view_models/me_view_model.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.viewModel,
    required this.onDeleteAccount,
  });

  final MeViewModel viewModel;
  final VoidCallback onDeleteAccount;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final _first = TextEditingController(
    text: widget.viewModel.account?.firstName ?? '',
  );
  late final _last = TextEditingController(
    text: widget.viewModel.account?.lastName ?? '',
  );

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  bool get _isChanged =>
      _first.text.trim() != (widget.viewModel.account?.firstName ?? '') ||
      _last.text.trim() != (widget.viewModel.account?.lastName ?? '');

  void _soon(String what) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('$what is coming soon.')));

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final command = widget.viewModel.saveName;
    await command.execute((first: _first.text.trim(), last: _last.text.trim()));
    if (!mounted) return;
    final message = switch (command.result) {
      Ok() => 'Name saved',
      Error(:final error) => failureMessage(error),
      null => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saving = widget.viewModel.saveName;
    return ListenableBuilder(
      listenable: saving,
      builder: (context, _) => SettingsPage(
        title: 'Account',
        children: [
          const SizedBox(height: 8),
          LightField(
            label: 'First name',
            controller: _first,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          LightField(
            label: 'Last name',
            controller: _last,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: saving.isRunning ? 'Saving…' : 'Save name',
            isPrimary: true,
            isEnabled: _isChanged && !saving.isRunning,
            onTap: _save,
          ),
          SettingsGroup(
            title: 'Sign-in',
            children: [
              SettingsRow(
                label: 'Email',
                value: widget.viewModel.account?.email ?? '',
              ),
              SettingsRow(
                label: 'Change password',
                onTap: () => _soon('Changing your password'),
              ),
              SettingsRow(
                label: 'Google',
                value: 'Not linked',
                onTap: () => _soon('Linking Google'),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Danger zone',
            children: [
              SettingsRow(
                label: 'Delete my account',
                isDanger: true,
                onTap: widget.onDeleteAccount,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Your account is deleted 30 days after you ask. Log in before then to keep it.',
              style: AppTextStyles.caption.copyWith(
                color: context.palette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
