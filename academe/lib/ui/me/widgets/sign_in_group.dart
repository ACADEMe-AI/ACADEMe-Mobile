import 'package:flutter/material.dart';

import '../../../domain/models/auth_failure.dart';
import '../../../utils/result.dart';
import '../../auth/widgets/auth_failure_text.dart';
import '../view_models/me_view_model.dart';
import 'password_screen.dart';
import 'settings_list.dart';
import 'unlink_google_sheet.dart';

class SignInGroup extends StatelessWidget {
  const SignInGroup({super.key, required this.viewModel});

  final MeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    void show(String message) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

    Future<void> openPassword() async {
      final message = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => PasswordScreen(viewModel: viewModel)),
      );
      if (message != null && context.mounted) show(message);
    }

    Future<void> link() async {
      await viewModel.linkGoogle.execute();
      if (!context.mounted) return;
      switch (viewModel.linkGoogle.result) {
        case Ok():
          show('Google linked. You can log in with it now.');
        case Error(error: AuthException(failure: AuthFailure.canceled)):
          break;
        case Error(:final error):
          show(failureMessage(error));
        case null:
          break;
      }
    }

    Future<void> unlink() async {
      if (!viewModel.hasPassword) {
        show(AuthFailure.passwordRequired.message);
        return;
      }
      final confirmed = await UnlinkGoogleSheet.show(
        context,
        googleEmail: viewModel.googleEmail ?? '',
      );
      if (confirmed != true) return;
      await viewModel.unlinkGoogle.execute();
      if (!context.mounted) return;
      show(switch (viewModel.unlinkGoogle.result) {
        Error(:final error) => failureMessage(error),
        _ => 'Google unlinked. Log in with your email and password.',
      });
    }

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final googleEmail = viewModel.googleEmail;
        final isLinking = viewModel.linkGoogle.isRunning;
        final isUnlinking = viewModel.unlinkGoogle.isRunning;
        return SettingsGroup(
          title: 'Sign-in',
          children: [
            SettingsRow(label: 'Email', value: viewModel.account?.email ?? ''),
            SettingsRow(
              label: viewModel.hasPassword
                  ? 'Change password'
                  : 'Set a password',
              onTap: openPassword,
            ),
            SettingsRow(
              label: googleEmail == null ? 'Link Google' : 'Google',
              value: isLinking
                  ? 'Linking…'
                  : isUnlinking
                  ? 'Unlinking…'
                  : googleEmail ?? 'Not linked',
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
