import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/app_theme.dart';
import '../../core/ui/app_back_button.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/celebration.dart';
import '../../core/ui/screen_scale.dart';
import '../view_models/sign_up_view_model.dart';
import 'sign_up_pebby.dart';
import 'sign_up_prompt.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.viewModel, this.onFinished});

  final SignUpViewModel viewModel;

  final VoidCallback? onFinished;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fields = SignUpFields();
  final _isPasswordHidden = ValueNotifier(true);
  late SignUpStep _lastStep;

  SignUpViewModel get _viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();
    _lastStep = _viewModel.step;
    _fields.firstName.addListener(
      () => _viewModel.setFirstName(_fields.firstName.text),
    );
    _fields.lastName.addListener(
      () => _viewModel.setLastName(_fields.lastName.text),
    );
    _fields.email.addListener(() => _viewModel.setEmail(_fields.email.text));
    _fields.password.addListener(
      () => _viewModel.setPassword(_fields.password.text),
    );
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (_fields.firstName.text.isEmpty && _viewModel.firstName.isNotEmpty) {
      _fields.firstName.text = _viewModel.firstName;
    }
    if (_fields.lastName.text.isEmpty && _viewModel.lastName.isNotEmpty) {
      _fields.lastName.text = _viewModel.lastName;
    }
    final step = _viewModel.step;
    if (step != _lastStep) {
      if (step == SignUpStep.done) HapticFeedback.heavyImpact();
      _focusField(step);
    }
    _lastStep = step;
  }

  void _focusField(SignUpStep step) {
    final node = _fields.focusFor(step);
    if (node == null) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) node.requestFocus();
    });
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onViewModelChanged)
      ..dispose();
    _fields.dispose();
    _isPasswordHidden.dispose();
    super.dispose();
  }

  void _back() {
    if (!_viewModel.back()) Navigator.of(context).pop();
  }

  void _onPrimary() {
    if (_viewModel.step == SignUpStep.done) {
      widget.onFinished?.call();
    } else {
      _viewModel.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);
    final changes = Listenable.merge([
      _viewModel,
      _viewModel.connectProvider,
      _viewModel.createAccount,
      _viewModel.saveName,
    ]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemBars.onLight,
        child: Scaffold(
          backgroundColor: AppColors.lightSurface,
          body: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    scale.pagePadding,
                    8,
                    scale.pagePadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListenableBuilder(
                        listenable: changes,
                        builder: (context, _) => _TopBar(
                          progress: _viewModel.progress,
                          isVisible: _viewModel.step != SignUpStep.done,
                          onBack: _back,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: SignUpPebby(
                                viewModel: _viewModel,
                                isPasswordHidden: _isPasswordHidden,
                              ),
                            ),
                          ),
                        ),
                      ),
                      ListenableBuilder(
                        listenable: changes,
                        builder: (context, _) => _StepSwitcher(
                          step: _viewModel.step,
                          child: SignUpPrompt(
                            viewModel: _viewModel,
                            fields: _fields,
                            titleSize: scale.headlineSize * .62,
                            bodySize: scale.bodySize,
                            onPasswordHiddenChanged: (isHidden) =>
                                _isPasswordHidden.value = isHidden,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListenableBuilder(
                        listenable: changes,
                        builder: (context, _) => AppButton(
                          label: _primaryLabel(_viewModel),
                          isPrimary: true,
                          isEnabled: _viewModel.canContinue,
                          onTap: _onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) => _viewModel.step == SignUpStep.done
                    ? const _Confetti()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _primaryLabel(SignUpViewModel vm) => switch (vm.step) {
    SignUpStep.hello when vm.connectProvider.isRunning => 'Connecting…',
    SignUpStep.hello when vm.connectProvider.hasError => 'Try again',
    SignUpStep.hello => 'Hi Pebby!',
    SignUpStep.password when vm.createAccount.isRunning =>
      'Creating your account…',
    SignUpStep.password => 'Create account',
    SignUpStep.lastName when vm.saveName.isRunning => 'Saving…',
    SignUpStep.done => "Let's go",
    _ => 'Continue',
  };
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.isVisible,
    required this.onBack,
  });

  final double progress;
  final bool isVisible;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(height: 44);
    return Row(
      children: [
        AppBackButton(onTap: onBack),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppRadius.full),
              color: AppColors.primary,
              backgroundColor: AppColors.lightSurfaceRaised,
            ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _StepSwitcher extends StatelessWidget {
  const _StepSwitcher({required this.step, required this.child});

  final SignUpStep step;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.bottomLeft,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(.45, 1),
        ),
        child: SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(.08, 0), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(step), child: child),
    );
  }
}

class _Confetti extends StatelessWidget {
  const _Confetti();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Burst(size: 320, dots: 18, duration: Duration(milliseconds: 900)),
    );
  }
}
