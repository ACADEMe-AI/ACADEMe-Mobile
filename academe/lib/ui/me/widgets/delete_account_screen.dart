import 'package:flutter/material.dart';

import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/keycap.dart';
import '../../core/ui/light_field.dart';
import '../view_models/me_view_model.dart';
import 'settings_list.dart';
import 'settings_page.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    super.key,
    required this.viewModel,
    required this.onDeleted,
  });

  final MeViewModel viewModel;
  final VoidCallback onDeleted;

  static const confirmWord = 'DELETE';
  static const reasons = [
    'I don’t use it enough',
    'It didn’t help with my studies',
    'Too many notifications',
    'I’m worried about my data',
    'Something else',
  ];

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _confirm = TextEditingController();
  String? _reason;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  bool get _isConfirmed =>
      _confirm.text.trim().toUpperCase() == DeleteAccountScreen.confirmWord;

  Future<void> _delete() async {
    final command = widget.viewModel.deleteAccount;
    await command.execute(_reason);
    if (!mounted) return;
    switch (command.result) {
      case Ok():
        widget.onDeleted();
      case Error(:final error):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureMessage(error))));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deleting = widget.viewModel.deleteAccount;
    return ListenableBuilder(
      listenable: deleting,
      builder: (context, _) => SettingsPage(
        title: 'Delete account',
        bottom: Keycap(
          face: AppColors.error,
          depth: AppKeycap.buttonDepth,
          height: 56,
          isEnabled: _isConfirmed && !deleting.isRunning,
          onTap: _delete,
          child: Center(
            child: Text(
              deleting.isRunning ? 'Deleting…' : 'Delete my account',
              style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ),
        children: [
          const SizedBox(height: 8),
          Text(
            'We’re sorry to see you go',
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your account will be deleted in 30 days. Log in again before '
            'then to keep it. After 30 days your profile, chats, progress and '
            'XP are erased for good and can’t be brought back.',
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
              height: 1.5,
            ),
          ),
          SettingsGroup(
            title: 'Why are you leaving? (optional)',
            children: [
              for (final reason in DeleteAccountScreen.reasons)
                SettingsRow(
                  label: reason,
                  onTap: () => setState(
                    () => _reason = _reason == reason ? null : reason,
                  ),
                  trailing: Icon(
                    _reason == reason
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _reason == reason
                        ? AppColors.primary
                        : context.palette.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LightField(
            label: 'Type ${DeleteAccountScreen.confirmWord} to confirm',
            controller: _confirm,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
