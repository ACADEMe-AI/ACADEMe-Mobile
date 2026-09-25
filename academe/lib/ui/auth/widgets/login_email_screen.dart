import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_back_button.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/app_password_field.dart';
import '../../core/ui/app_text_field.dart';
import '../../core/ui/brand_mark.dart';
import '../../core/ui/inline_link.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/split_headline.dart';
import '../../core/ui/stagger.dart';
import '../view_models/login_view_model.dart';
import 'auth_failure_text.dart';

class LoginEmailScreen extends StatefulWidget {
  const LoginEmailScreen({
    super.key,
    required this.viewModel,
    this.onLoggedIn,
    this.onForgotPassword,
    this.onSignUp,
  });

  final LoginViewModel viewModel;
  final VoidCallback? onLoggedIn;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;

  @override
  State<LoginEmailScreen> createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends State<LoginEmailScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  final _pebbyPose = ValueNotifier(PebbyPose.happy);
  Timer? _handOff;

  static const _celebrationLength = Duration(milliseconds: 900);

  LoginViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => _viewModel.setEmail(_email.text));
    _password.addListener(() => _viewModel.setPassword(_password.text));
    _emailFocus.addListener(_updatePose);
    _passwordFocus.addListener(_updatePose);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _handOff?.cancel();
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _pebbyPose.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    _updatePose();
    if (_viewModel.logIn.isCompleted && _handOff == null) {
      HapticFeedback.mediumImpact();
      _handOff = Timer(_celebrationLength, () => widget.onLoggedIn?.call());
    }
  }

  void _updatePose() {
    final logIn = _viewModel.logIn;
    _pebbyPose.value = logIn.isRunning
        ? PebbyPose.think
        : logIn.isCompleted
        ? PebbyPose.celebrateSmall
        : _viewModel.failure != null
        ? PebbyPose.encourage
        : _passwordFocus.hasFocus
        ? PebbyPose.coverEyes
        : _emailFocus.hasFocus
        ? PebbyPose.focused
        : PebbyPose.happy;
  }

  void _logIn() {
    FocusScope.of(context).unfocus();
    _viewModel.logIn.execute();
  }

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemBars.onLight,
      child: Scaffold(
        backgroundColor: AppColors.lightSurface,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    scale.pagePadding,
                    8,
                    scale.pagePadding,
                    16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const AppBackButton(),
                          const Spacer(),
                          BrandMark(size: scale.markSize * .8, atEnd: true),
                        ],
                      ),
                      Center(
                        child: SizedBox.square(
                          dimension: (scale.headlineSize * 3.4).clamp(
                            150.0,
                            220.0,
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: _pebbyPose,
                            builder: (context, pose, _) => Pebby(pose: pose),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Stagger(
                            gap: 0,
                            delay: const Duration(milliseconds: 120),
                            step: const Duration(milliseconds: 60),
                            children: [
                              SplitHeadline(
                                lead: 'Welcome',
                                accent: 'back.',
                                size: scale.headlineSize * .82,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Log in to pick up where you left off.',
                                style: TextStyle(
                                  fontSize: scale.bodySize,
                                  height: 1.45,
                                  color: AppColors.lightTextMuted,
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppTextField(
                                label: 'Email',
                                controller: _email,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 12),
                              AppPasswordField(
                                controller: _password,
                                focusNode: _passwordFocus,
                                onSubmitted: (_) {
                                  if (_viewModel.canLogIn) _logIn();
                                },
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: widget.onForgotPassword ?? () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: AppTextStyles.labelStrong,
                                  ),
                                ),
                              ),
                              ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) => _Failure(
                                  message: _viewModel.failure?.message,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListenableBuilder(
                                listenable: _viewModel,
                                builder: (context, _) => AppButton(
                                  label: _viewModel.logIn.isRunning
                                      ? 'Logging in…'
                                      : 'Log in',
                                  isPrimary: true,
                                  isEnabled: _viewModel.canLogIn,
                                  onTap: _logIn,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          InlineLink(
                            lead: 'New here? ',
                            action: 'Sign up',
                            onTap: widget.onSignUp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: AppColors.error),
      ),
    );
  }
}
