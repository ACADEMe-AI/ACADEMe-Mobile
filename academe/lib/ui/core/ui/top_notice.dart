import 'package:flutter/material.dart';

import '../themes/app_theme.dart';
import 'pebby.dart';
import 'pebby_keycap_banner.dart';

enum TopNoticeKind { success, error, offline }

class TopNotice {
  const TopNotice({
    required this.kind,
    required this.message,
    this.pose,
    this.duration = TopNoticeController.defaultDuration,
  });

  final TopNoticeKind kind;
  final String message;
  final double? pose;
  final Duration duration;

  double get resolvedPose =>
      pose ??
      switch (kind) {
        TopNoticeKind.success => PebbyPose.noticeSuccess,
        TopNoticeKind.error => PebbyPose.noticeError,
        TopNoticeKind.offline => PebbyPose.noticeOffline,
      };

  Color face(AppPalette palette) => switch (kind) {
    TopNoticeKind.success => palette.tintMint,
    TopNoticeKind.error => palette.tintRose,
    TopNoticeKind.offline => palette.surfaceRaised,
  };

  Color timerColor(AppPalette palette) => switch (kind) {
    TopNoticeKind.success => palette.success,
    TopNoticeKind.error => palette.errorInk,
    TopNoticeKind.offline => palette.textMuted,
  };
}

class TopNoticeController extends ChangeNotifier {
  static const defaultDuration = Duration(milliseconds: 4000);

  TopNotice? _current;
  int _generation = 0;

  TopNotice? get current => _current;

  void show(TopNotice notice) {
    _generation += 1;
    _current = notice;
    notifyListeners();
  }

  void showMessage(
    String message, {
    TopNoticeKind kind = TopNoticeKind.success,
    double? pose,
    Duration duration = defaultDuration,
  }) {
    show(
      TopNotice(kind: kind, message: message, pose: pose, duration: duration),
    );
  }

  void dismiss([TopNotice? notice]) {
    if (notice != null && !identical(_current, notice)) return;
    if (_current == null) return;
    _current = null;
    notifyListeners();
  }

  int get generation => _generation;
}

class TopNoticeScope extends InheritedNotifier<TopNoticeController> {
  const TopNoticeScope({
    super.key,
    required TopNoticeController controller,
    required super.child,
  }) : super(notifier: controller);

  static TopNoticeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TopNoticeScope>();
    assert(scope != null, 'TopNoticeScope not found');
    return scope!.notifier!;
  }

  static TopNoticeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TopNoticeScope>()?.notifier;
}

extension TopNoticeContext on BuildContext {
  void showTopNotice(
    String message, {
    TopNoticeKind kind = TopNoticeKind.success,
    double? pose,
    Duration duration = TopNoticeController.defaultDuration,
  }) {
    TopNoticeScope.maybeOf(
      this,
    )?.showMessage(message, kind: kind, pose: pose, duration: duration);
  }
}

class TopNoticeHost extends StatelessWidget {
  const TopNoticeHost({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TopNoticeScope.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final notice = controller.current;
        if (notice == null) return const SizedBox.shrink();
        return SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _TopNoticeBanner(
                  key: ValueKey(controller.generation),
                  notice: notice,
                  onFinished: () => controller.dismiss(notice),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopNoticeBanner extends StatefulWidget {
  const _TopNoticeBanner({
    super.key,
    required this.notice,
    required this.onFinished,
  });

  final TopNotice notice;
  final VoidCallback onFinished;

  @override
  State<_TopNoticeBanner> createState() => _TopNoticeBannerState();
}

class _TopNoticeBannerState extends State<_TopNoticeBanner>
    with TickerProviderStateMixin {
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: widget.notice.duration,
  )..forward();

  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _life.addStatusListener((status) {
      if (status == AnimationStatus.completed) _exit();
    });
  }

  Future<void> _exit() async {
    if (_isExiting) return;
    _isExiting = true;
    await _enter.reverse();
    if (mounted) widget.onFinished();
  }

  @override
  void dispose() {
    _life.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final notice = widget.notice;
    final ink = palette.text;
    final motion = CurvedAnimation(
      parent: _enter,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(motion);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: motion,
        child: Material(
          type: MaterialType.transparency,
          child: PebbyKeycapBanner(
            face: notice.face(palette),
            message: notice.message,
            pose: notice.resolvedPose,
            bottom: AnimatedBuilder(
              animation: _life,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: 1 - _life.value,
                  minHeight: 3,
                  backgroundColor: ink.withValues(alpha: 0.12),
                  color: notice.timerColor(palette),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
