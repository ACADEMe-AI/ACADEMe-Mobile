import 'package:flutter/material.dart';

import '../../../domain/models/auth_method.dart';
import '../../core/l10n/app_l10n.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/app_password_field.dart';
import '../../core/ui/app_text_field.dart';
import '../view_models/sign_up_view_model.dart';
import 'auth_failure_text.dart';
import 'password_length_check.dart';

class SignUpFields {
  SignUpFields();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  final firstNameFocus = FocusNode();
  final lastNameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  FocusNode? focusFor(SignUpStep step) => switch (step) {
    SignUpStep.firstName => firstNameFocus,
    SignUpStep.lastName => lastNameFocus,
    SignUpStep.email => emailFocus,
    SignUpStep.password => passwordFocus,
    SignUpStep.hello || SignUpStep.done => null,
  };

  void dispose() {
    for (final controller in [firstName, lastName, email, password]) {
      controller.dispose();
    }
    for (final node in [
      firstNameFocus,
      lastNameFocus,
      emailFocus,
      passwordFocus,
    ]) {
      node.dispose();
    }
  }
}

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({
    super.key,
    required this.viewModel,
    required this.fields,
    required this.titleSize,
    required this.bodySize,
    required this.onPasswordHiddenChanged,
  });

  final SignUpViewModel viewModel;
  final SignUpFields fields;
  final double titleSize;
  final double bodySize;
  final ValueChanged<bool> onPasswordHiddenChanged;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    final l10n = context.l10n;
    void submit(String _) => vm.next();

    final (title, subtitle, field) = switch (vm.step) {
      SignUpStep.hello => (
        vm.method == AuthMethod.email || vm.firstName.isEmpty
            ? l10n.signUpHiPebby
            : l10n.signUpHiNamed(vm.firstName),
        _helloSubtitle(vm, l10n),
        null,
      ),
      SignUpStep.firstName => (
        l10n.signUpAskFirstName,
        null,
        AppTextField(
          label: l10n.signUpFirstName,
          controller: fields.firstName,
          focusNode: fields.firstNameFocus,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.givenName],
          onSubmitted: submit,
        ),
      ),
      SignUpStep.lastName => (
        l10n.signUpAskLastName(vm.firstName.trim()),
        null,
        AppTextField(
          label: l10n.signUpLastName,
          controller: fields.lastName,
          focusNode: fields.lastNameFocus,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.familyName],
          onSubmitted: submit,
        ),
      ),
      SignUpStep.email => (
        l10n.signUpAskEmail(vm.firstName.trim()),
        l10n.signUpEmailHint,
        AppTextField(
          label: l10n.authEmail,
          controller: fields.email,
          focusNode: fields.emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onSubmitted: submit,
          errorText: switch (vm.emailProblem) {
            EmailProblem.notAnEmail => l10n.signUpEmailInvalid,
            EmailProblem.taken => l10n.authFailureEmailTaken,
            EmailProblem.none => null,
          },
        ),
      ),
      SignUpStep.password => (
        l10n.signUpCreatePassword,
        l10n.signUpPasswordHint(SignUpViewModel.minPasswordLength),
        AppPasswordField(
          controller: fields.password,
          focusNode: fields.passwordFocus,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: submit,
          onHiddenChanged: onPasswordHiddenChanged,
        ),
      ),
      SignUpStep.done when vm.isReturning => (
        l10n.signUpWelcomeBack(vm.firstName.trim()),
        l10n.signUpAlreadyLoggedIn,
        null,
      ),
      SignUpStep.done => (
        l10n.signUpYoureIn(vm.firstName.trim()),
        l10n.signUpAccountReady,
        null,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.display.copyWith(
            fontSize: titleSize,
            color: AppColors.lightText,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: bodySize,
              height: 1.45,
              color: vm.step == SignUpStep.hello && vm.failure != null
                  ? AppColors.error
                  : AppColors.lightTextMuted,
            ),
          ),
        ],
        if (field != null) ...[const SizedBox(height: 20), field],
        if (vm.step == SignUpStep.password) ...[
          const SizedBox(height: 10),
          PasswordLengthCheck(isMet: vm.isPasswordLongEnough),
        ],
        if (vm.step != SignUpStep.hello && vm.failure != null) ...[
          const SizedBox(height: 8),
          Text(
            vm.failure!.message(l10n),
            style: AppTextStyles.label.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  static String _helloSubtitle(SignUpViewModel vm, AppLocalizations l10n) {
    if (vm.method == AuthMethod.email) {
      return l10n.signUpHelloEmail;
    }
    if (vm.connectProvider.isRunning) return l10n.signUpConnectingAccount;
    if (vm.failure case final failure?) return failure.message(l10n);
    return l10n.signUpCheckName;
  }
}
