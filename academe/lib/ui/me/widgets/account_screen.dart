import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/light_field.dart';
import '../view_models/me_view_model.dart';
import 'settings_list.dart';
import 'settings_page.dart';
import 'sign_in_group.dart';

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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final command = widget.viewModel.saveName;
    await command.execute((first: _first.text.trim(), last: _last.text.trim()));
    if (!mounted) return;
    final message = switch (command.result) {
      Ok() => context.l10n.accountNameSaved,
      Error(:final error) => failureMessage(error, context.l10n),
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
    final l10n = context.l10n;
    final saving = widget.viewModel.saveName;
    return ListenableBuilder(
      listenable: saving,
      builder: (context, _) => SettingsPage(
        title: l10n.meAccount,
        children: [
          const SizedBox(height: 8),
          LightField(
            label: l10n.signUpFirstName,
            controller: _first,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          LightField(
            label: l10n.signUpLastName,
            controller: _last,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: saving.isRunning ? l10n.authSaving : l10n.accountSaveName,
            isPrimary: true,
            isEnabled: _isChanged && !saving.isRunning,
            onTap: _save,
          ),
          SignInGroup(viewModel: widget.viewModel),
          SettingsGroup(
            title: l10n.accountDangerZone,
            children: [
              SettingsRow(
                label: l10n.accountDeleteMyAccount,
                isDanger: true,
                onTap: widget.onDeleteAccount,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.accountDeleteGraceNote,
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
