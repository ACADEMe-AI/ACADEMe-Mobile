import 'package:flutter/material.dart';

import '../ui/auth/view_models/forgot_password_view_model.dart';
import '../ui/auth/view_models/new_password_view_model.dart';
import '../ui/auth/view_models/reset_code_view_model.dart';
import '../ui/auth/widgets/forgot_password_screen.dart';
import '../ui/auth/widgets/new_password_screen.dart';
import '../ui/auth/widgets/reset_code_screen.dart';
import 'routes.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key, required this.viewModel});

  final ForgotPasswordViewModel viewModel;

  @override
  Widget build(BuildContext context) => ForgotPasswordScreen(
    viewModel: viewModel,
    onCodeSent: (email) =>
        Navigator.of(context).pushNamed(Routes.resetCode, arguments: email),
  );
}

class ResetCodePage extends StatelessWidget {
  const ResetCodePage({super.key, required this.viewModel});

  final ResetCodeViewModel viewModel;

  @override
  Widget build(BuildContext context) => ResetCodeScreen(
    viewModel: viewModel,
    onVerified: (resetToken) => Navigator.of(
      context,
    ).pushReplacementNamed(Routes.newPassword, arguments: resetToken),
  );
}

class NewPasswordPage extends StatelessWidget {
  const NewPasswordPage({super.key, required this.viewModel});

  final NewPasswordViewModel viewModel;

  @override
  Widget build(BuildContext context) => NewPasswordScreen(
    viewModel: viewModel,
    onDone: () => Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(Routes.home, (_) => false, arguments: false),
    onStartOver: () => Navigator.of(context).pop(),
  );
}
