import 'package:flutter/material.dart';

import '../../../domain/models/auth_failure.dart';
import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/top_notice.dart';
import '../view_models/me_view_model.dart';
import 'password_screen.dart';
import 'settings_list.dart';
import 'unlink_google_sheet.dart';

class SignInGroup extends StatelessWidget {
  const SignInGroup({super.key, required this.viewModel});

  final MeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    void show(
      String message, {
      TopNoticeKind kind = TopNoticeKind.success,
      double? pose,
    }) => context.showTopNotice(message, kind: kind, pose: pose);

    Future<void> openPassword() async {
      final message = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => PasswordScreen(viewModel: viewModel)),
      );
      if (message != null && context.mounted) {
        show(message, pose: PebbyPose.noticeSaved);
      }
    }

    Future<void> link() async {
      await viewModel.linkGoogle.execute();
      if (!context.mounted) return;
      switch (viewModel.linkGoogle.result) {
        case Ok():
          show(context.l10n.accountGoogleLinked);
        case Error(error: AuthException(failure: AuthFailure.canceled)):
          break;
        case Error(:final error):
          show(failureMessage(error, context.l10n), kind: TopNoticeKind.error);
        case null:
          break;
      }
    }

    Future<void> unlink() async {
      if (!viewModel.hasPassword) {
        show(
          AuthFailure.passwordRequired.message(context.l10n),
          kind: TopNoticeKind.error,
        );
        return;
      }
      final confirmed = await UnlinkGoogleSheet.show(
        context,
        googleEmail: viewModel.googleEmail ?? '',
      );
      if (confirmed != true) return;
      await viewModel.unlinkGoogle.execute();
      if (!context.mounted) return;
      switch (viewModel.unlinkGoogle.result) {
        case Error(:final error):
          show(failureMessage(error, context.l10n), kind: TopNoticeKind.error);
        case _:
          show(context.l10n.accountGoogleUnlinked);
      }
    }

    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final googleEmail = viewModel.googleEmail;
        final isLinking = viewModel.linkGoogle.isRunning;
        final isUnlinking = viewModel.unlinkGoogle.isRunning;
        return SettingsGroup(
          title: l10n.accountSignIn,
          children: [
            SettingsRow(
              label: l10n.authEmail,
              value: viewModel.account?.email ?? '',
            ),
            SettingsRow(
              label: viewModel.hasPassword
                  ? l10n.accountChangePassword
                  : l10n.accountSetPassword,
              onTap: openPassword,
            ),
            SettingsRow(
              label: googleEmail == null
                  ? l10n.accountLinkGoogle
                  : l10n.accountGoogle,
              value: isLinking
                  ? l10n.accountLinking
                  : isUnlinking
                  ? l10n.accountUnlinking
                  : googleEmail ?? l10n.accountNotLinked,
              onTap: isLinking || isUnlinking
                  ? null
                  : googleEmail == null
                  ? link
                  : unlink,
            ),
          ],
        );
      },
    );
  }
}
