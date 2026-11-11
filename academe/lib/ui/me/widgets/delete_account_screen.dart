import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/l10n/app_l10n.dart';
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

  static List<(String english, String Function(AppLocalizations) label)>
  get reasons => [
    ('I don’t use it enough', (l10n) => l10n.deleteReasonNotEnough),
    ('It didn’t help with my studies', (l10n) => l10n.deleteReasonDidntHelp),
    ('Too many notifications', (l10n) => l10n.deleteReasonTooManyNotifs),
    ('I’m worried about my data', (l10n) => l10n.deleteReasonDataWorry),
    ('Something else', (l10n) => l10n.deleteReasonOther),
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

  Future<void> _manageSubscription() async {
    final url = Uri.parse(widget.viewModel.manageSubscriptionUrl);
    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.meOpenInBrowser('$url'))),
      );
  }

  Future<void> _delete() async {
    final command = widget.viewModel.deleteAccount;
    await command.execute(_reason);
    if (!mounted) return;
    switch (command.result) {
      case Ok():
        widget.onDeleted();
      case Error(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureMessage(error, context.l10n))),
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final deleting = widget.viewModel.deleteAccount;
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) => SettingsPage(
        title: l10n.deleteAccountTitle,
        bottom: Keycap(
          face: AppColors.error,
          depth: AppKeycap.buttonDepth,
          height: 56,
          isEnabled: _isConfirmed && !deleting.isRunning,
          onTap: _delete,
          child: Center(
            child: Text(
              deleting.isRunning
                  ? l10n.deleteDeleting
                  : l10n.accountDeleteMyAccount,
              style: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
            ),
          ),
        ),
        children: [
          const SizedBox(height: 8),
          Text(
            l10n.deleteSorryTitle,
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              color: context.palette.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.deleteBody,
            style: AppTextStyles.label.copyWith(
              color: context.palette.textMuted,
              height: 1.5,
            ),
          ),
          SettingsGroup(
            title: l10n.deleteSubscription,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.deleteSubscriptionNotice,
                  style: AppTextStyles.label.copyWith(
                    color: context.palette.text,
                    height: 1.5,
                  ),
                ),
              ),
              if (widget.viewModel.isPro)
                SettingsRow(
                  label: l10n.deleteManageSubscription,
                  onTap: _manageSubscription,
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    color: context.palette.textMuted,
                  ),
                ),
            ],
          ),
          SettingsGroup(
            title: l10n.deleteWhyLeaving,
            children: [
              for (final (english, labelFor) in DeleteAccountScreen.reasons)
                SettingsRow(
                  label: labelFor(l10n),
                  onTap: () => setState(
                    () => _reason = _reason == english ? null : english,
                  ),
                  trailing: Icon(
                    _reason == english
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: _reason == english
                        ? AppColors.primary
                        : context.palette.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LightField(
            label: l10n.deleteConfirmLabel(DeleteAccountScreen.confirmWord),
            controller: _confirm,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}
