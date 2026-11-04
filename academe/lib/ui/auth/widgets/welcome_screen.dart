import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/auth_method.dart';
import '../../core/themes/app_theme.dart';
import '../../core/ui/academe_wordmark.dart';
import '../../core/ui/app_button.dart';
import '../../core/ui/brand_mark.dart';
import '../../core/ui/google_logo.dart';
import '../../core/ui/inline_link.dart';
import '../../core/ui/pebby.dart';
import '../../core/ui/rise_in.dart';
import '../../core/ui/screen_scale.dart';
import '../../core/ui/split_headline.dart';
import '../../core/ui/stagger.dart';

enum _SheetMode { start, logIn, signUp }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.onSignUp, this.onLogIn});

  final ValueChanged<AuthMethod>? onSignUp;

  final Future<bool> Function(AuthMethod method)? onLogIn;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: _Entrance.duration,
  )..forward();

  _SheetMode _mode = _SheetMode.start;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _show(_SheetMode mode) => setState(() => _mode = mode);

  Future<void> _logIn(AuthMethod method) async {
    final wantsSignUp = await widget.onLogIn?.call(method) ?? false;
    if (wantsSignUp && mounted) _show(_SheetMode.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final scale = ScreenScale.of(context);
    final entrance = _Entrance(_entrance);

    return PopScope(
      canPop: _mode == _SheetMode.start,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _show(_SheetMode.start);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppSystemBars.onLight,
        child: Scaffold(
          backgroundColor: AppColors.lightSurface,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Intro(entrance: entrance, scale: scale),
              ),
              _Sheet(
                entrance: entrance,
                scale: scale,
                isPebbyPeeking: _mode != _SheetMode.start,
                child: switch (_mode) {
                  _SheetMode.start => _StartActions(
                    key: const ValueKey(_SheetMode.start),
                    entrance: entrance,
                    onGetStarted: () => _show(_SheetMode.signUp),
                    onLogIn: () => _show(_SheetMode.logIn),
                  ),
                  _SheetMode.signUp => _AccountOptions(
                    key: const ValueKey(_SheetMode.signUp),
                    title: 'Sign up',
                    footerLead: 'Already have an account? ',
                    footerAction: 'Log in',
                    onFooter: () => _show(_SheetMode.logIn),
                    onMethod: widget.onSignUp,
                  ),
                  _SheetMode.logIn => _AccountOptions(
                    key: const ValueKey(_SheetMode.logIn),
                    title: 'Log in',
                    footerLead: 'New user? ',
                    footerAction: 'Sign up',
                    onFooter: () => _show(_SheetMode.signUp),
                    onMethod: _logIn,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Entrance {
  const _Entrance(this.controller);

  static const duration = Duration(milliseconds: 1300);

  final AnimationController controller;

  Animation<double> at(
    int startMs, {
    int lengthMs = 420,
    Curve curve = Curves.easeOutCubic,
  }) {
    final total = duration.inMilliseconds;
    return controller.drive(
      CurveTween(
        curve: Interval(
          startMs / total,
          ((startMs + lengthMs) / total).clamp(0.0, 1.0),
          curve: curve,
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.entrance, required this.scale});

  final _Entrance entrance;
  final ScreenScale scale;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          scale.pagePadding,
          16,
          scale.pagePadding,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RiseIn(
              animation: entrance.at(0),
              child: Row(
                children: [
                  BrandMark(size: scale.markSize),
                  const Spacer(),
                  AcademeWordmark(size: scale.markSize * .5),
                ],
              ),
            ),
            SizedBox(height: scale.markGap),
            RiseIn(
              animation: entrance.at(90),
              child: SplitHeadline(
                lead: 'Study\nsmarter.',
                accent: 'Not longer.',
                size: scale.headlineSize,
              ),
            ),
            const SizedBox(height: 16),
            RiseIn(
              animation: entrance.at(180),
              child: Text(
                'Notes, quizzes and flashcards made from what you are '
                'actually studying.',
                style: TextStyle(
                  fontSize: scale.bodySize,
                  height: 1.45,
                  color: AppColors.lightTextMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.entrance,
    required this.scale,
    required this.isPebbyPeeking,
    required this.child,
  });

  final _Entrance entrance;
  final ScreenScale scale;
  final bool isPebbyPeeking;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SlideTransition(
      position: entrance
          .at(450, lengthMs: 550, curve: Curves.easeOutBack)
          .drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
      child: _PeekingPebby(
        isPeeking: isPebbyPeeking,
        child: _SheetBody(scale: scale, bottomInset: bottomInset, child: child),
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.scale,
    required this.bottomInset,
    required this.child,
  });

  final ScreenScale scale;
  final double bottomInset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        scale.pagePadding,
        12,
        scale.pagePadding,
        16 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 28,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: _Handle()),
          const SizedBox(height: 24),
          AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: Alignment.bottomCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.bottomCenter,
                children: [...previous, ?current],
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeekingPebby extends StatefulWidget {
  const _PeekingPebby({required this.isPeeking, required this.child});

  final bool isPeeking;
  final Widget child;

  @override
  State<_PeekingPebby> createState() => _PeekingPebbyState();
}

class _PeekingPebbyState extends State<_PeekingPebby>
    with SingleTickerProviderStateMixin {
  static const _size = 150.0;
  static const _visibleShare = .6;
  static const _rise = Duration(milliseconds: 1000);
  static const _drop = Duration(milliseconds: 220);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _rise,
    value: widget.isPeeking ? 1 : 0,
  );

  late final Animation<Offset> _body = _controller
      .drive(
        CurveTween(curve: const Interval(.4, .85, curve: Curves.easeOutCubic)),
      )
      .drive(
        Tween(begin: const Offset(0, _visibleShare + .05), end: Offset.zero),
      );

  late final Animation<double> _paws = _controller.drive(
    CurveTween(curve: const Interval(.78, 1, curve: Curves.easeOutBack)),
  );

  @override
  void didUpdateWidget(_PeekingPebby oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPeeking == oldWidget.isPeeking) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = widget.isPeeking ? 1 : 0;
    } else if (widget.isPeeking) {
      _controller.forward();
    } else {
      _controller.animateBack(0, duration: _drop, curve: Curves.easeIn);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -_size * _visibleShare,
          left: 0,
          right: 0,
          child: Center(
            child: SlideTransition(
              position: _body,
              child: const SizedBox.square(
                dimension: _size,
                child: Pebby(pose: PebbyPose.idle),
              ),
            ),
          ),
        ),
        widget.child,
        Positioned(
          top: -_PebbyPaws.aboveEdge * _PebbyPaws.scaleFor(_size),
          left: 0,
          right: 0,
          child: Center(
            child: ScaleTransition(
              scale: _paws,
              alignment: Alignment.topCenter,
              child: const _PebbyPaws(pebbySize: _size),
            ),
          ),
        ),
      ],
    );
  }
}

class _PebbyPaws extends StatelessWidget {
  const _PebbyPaws({required this.pebbySize});

  static const aboveEdge = 26.0;
  static const _width = 230.0;
  static const _height = 64.0;

  static double scaleFor(double pebbySize) => pebbySize / 360;

  final double pebbySize;

  @override
  Widget build(BuildContext context) {
    final scale = scaleFor(pebbySize);
    return CustomPaint(
      size: Size(_width * scale, _height * scale),
      painter: _PawPainter(scale),
    );
  }
}

class _PawPainter extends CustomPainter {
  const _PawPainter(this.scale);

  static const _spread = 80.0;

  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width / 2, _PebbyPaws.aboveEdge * scale)
      ..scale(scale);
    for (final side in const [-1.0, 1.0]) {
      _paw(canvas, Offset(side * _spread, 0));
    }
    canvas.restore();
  }

  void _paw(Canvas canvas, Offset at) {
    final base = Paint()
      ..shader = const RadialGradient(
        center: Alignment.topLeft,
        radius: 1.3,
        colors: [AppColors.pebbyLight, AppColors.pebbyMid, AppColors.pebbyDeep],
        stops: [0, .4, 1],
      ).createShader(Rect.fromCenter(center: at, width: 58, height: 60));
    final pads = [
      for (final (dx, dy, w, h) in const [
        (-17.0, 21.0, 17.0, 20.0),
        (0.0, 25.0, 18.0, 22.0),
        (17.0, 21.0, 17.0, 20.0),
      ])
        Rect.fromCenter(center: at + Offset(dx, dy), width: w, height: h),
    ];
    canvas.drawShadow(
      Path()
        ..addOval(Rect.fromCenter(center: at, width: 58, height: 48))
        ..addOval(pads[0])
        ..addOval(pads[1])
        ..addOval(pads[2]),
      AppColors.pebbyDeep,
      3,
      false,
    );
    canvas.drawOval(Rect.fromCenter(center: at, width: 58, height: 48), base);
    for (final pad in pads) {
      canvas.drawOval(pad, base);
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: at + const Offset(-10, -12),
        width: 22,
        height: 12,
      ),
      Paint()..color = AppColors.pebbySheen,
    );
  }

  @override
  bool shouldRepaint(_PawPainter oldDelegate) => oldDelegate.scale != scale;
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.lightBorder,
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.full)),
        ),
      ),
    );
  }
}

class _StartActions extends StatelessWidget {
  const _StartActions({
    super.key,
    required this.entrance,
    required this.onLogIn,
    this.onGetStarted,
  });

  final _Entrance entrance;
  final VoidCallback onLogIn;
  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RiseIn(
          animation: entrance.at(800),
          child: AppButton(
            label: 'Get started',
            isPrimary: true,
            onTap: onGetStarted,
          ),
        ),
        const SizedBox(height: 12),
        RiseIn(
          animation: entrance.at(870),
          child: InlineLink(
            lead: 'Already have an account? ',
            action: 'Log in',
            onTap: onLogIn,
          ),
        ),
        const SizedBox(height: 8),
        RiseIn(
          animation: entrance.at(940),
          child: Text(
            'By continuing you agree to our Terms and Privacy Policy.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.lightTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccountOptions extends StatelessWidget {
  const _AccountOptions({
    super.key,
    required this.title,
    required this.footerLead,
    required this.footerAction,
    required this.onFooter,
    this.onMethod,
  });

  final String title;
  final String footerLead;
  final String footerAction;
  final VoidCallback onFooter;
  final ValueChanged<AuthMethod>? onMethod;

  @override
  Widget build(BuildContext context) {
    final showApple = defaultTargetPlatform == TargetPlatform.iOS;
    return Stagger(
      delay: const Duration(milliseconds: 120),
      children: [
        Text(
          title,
          style: AppTextStyles.sheetTitle.copyWith(color: AppColors.lightText),
        ),
        AppButton(
          label: 'Continue with Google',
          icon: const GoogleLogo(size: 20),
          onTap: () => onMethod?.call(AuthMethod.google),
        ),
        if (showApple)
          AppButton(
            label: 'Continue with Apple',
            icon: const Icon(Icons.apple, size: 22, color: AppColors.lightText),
            onTap: () => onMethod?.call(AuthMethod.apple),
          ),
        AppButton(
          label: 'Continue with email',
          icon: const Icon(
            Icons.mail_outline_rounded,
            size: 20,
            color: AppColors.onPrimary,
          ),
          isPrimary: true,
          onTap: () => onMethod?.call(AuthMethod.email),
        ),
        InlineLink(lead: footerLead, action: footerAction, onTap: onFooter),
      ],
    );
  }
}
