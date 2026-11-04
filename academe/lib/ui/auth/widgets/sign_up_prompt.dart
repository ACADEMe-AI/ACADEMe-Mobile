import 'package:flutter/material.dart';

import '../../../domain/models/auth_method.dart';
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
    void submit(String _) => vm.next();

    final (title, subtitle, field) = switch (vm.step) {
      SignUpStep.hello => (
        vm.method == AuthMethod.email || vm.firstName.isEmpty
            ? "Hi, I'm Pebby!"
            : "Hi ${vm.firstName}, I'm Pebby!",
        _helloSubtitle(vm),
        null,
      ),
      SignUpStep.firstName => (
        'Before we start, what should I call you?',
        null,
        AppTextField(
          label: 'First name',
          controller: fields.firstName,
          focusNode: fields.firstNameFocus,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.givenName],
          onSubmitted: submit,
        ),
      ),
      SignUpStep.lastName => (
        'Nice to meet you, ${vm.firstName.trim()}! And your last name?',
        null,
        AppTextField(
          label: 'Last name',
          controller: fields.lastName,
          focusNode: fields.lastNameFocus,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.familyName],
          onSubmitted: submit,
        ),
      ),
      SignUpStep.email => (
        "What's your email, ${vm.firstName.trim()}?",
        "You'll use it to log in.",
        AppTextField(
          label: 'Email',
          controller: fields.email,
          focusNode: fields.emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          onSubmitted: submit,
          errorText: switch (vm.emailProblem) {
            EmailProblem.notAnEmail => "That doesn't look like an email yet.",
            EmailProblem.taken =>
              'An account already uses this email. Log in instead.',
            EmailProblem.none => null,
          },
        ),
      ),
      SignUpStep.password => (
        'Create a password',
        'At least ${SignUpViewModel.minPasswordLength} characters. '
            "Don't worry, I won't look.",
        AppPasswordField(
          controller: fields.password,
          focusNode: fields.passwordFocus,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: submit,
          onHiddenChanged: onPasswordHiddenChanged,
        ),
      ),
      SignUpStep.done when vm.isReturning => (
        'Welcome back, ${vm.firstName.trim()}!',
        'You already have an account, so you\'re logged in.',
        null,
      ),
      SignUpStep.done => (
        "You're in, ${vm.firstName.trim()}!",
        'Your account is ready. Next, tell me what you study.',
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
            vm.failure!.message,
            style: AppTextStyles.label.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }

  static String _helloSubtitle(SignUpViewModel vm) {
    if (vm.method == AuthMethod.email) {
      return "I'll help you study smarter. Let's set up your account, it "
          'takes a minute.';
    }
    if (vm.connectProvider.isRunning) return 'Connecting your account…';
    if (vm.failure case final failure?) return failure.message;
    return "Let's check your name, then you're in.";
  }
}
