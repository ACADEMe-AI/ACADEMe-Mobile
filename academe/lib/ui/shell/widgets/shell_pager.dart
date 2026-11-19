import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/ui/shell_edge.dart';
import '../shell_tabs.dart';

class ShellPager extends StatefulWidget {
  const ShellPager({
    super.key,
    required this.tabIndex,
    required this.onTabIndex,
    required this.children,
  });

  final int tabIndex;
  final ValueChanged<int> onTabIndex;
  final List<Widget> children;

  @override
  State<ShellPager> createState() => _ShellPagerState();
}

class _ShellMotion extends ChangeNotifier {
  _ShellMotion({required int page}) : _page = page;

  int _page;
  double _drag = 0;
  bool _busy = false;

  int get page => _page;
  double get drag => _drag;
  bool get busy => _busy;

  void setDrag(double value) {
    if (_drag == value) return;
    _drag = value;
    notifyListeners();
  }

  void setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  void jump({required int page, required double drag, required bool busy}) {
    final changed = _page != page || _drag != drag || _busy != busy;
    _page = page;
    _drag = drag;
    _busy = busy;
    if (changed) notifyListeners();
  }
}

class _ShellPagerState extends State<ShellPager>
    with SingleTickerProviderStateMixin {
  static const _minFling = 700.0;
  static const _commitFraction = 0.28;
  static const _settle = Duration(milliseconds: 280);
  static const _axisSlop = 12.0;

  late final _ShellMotion _motion;
  late final AnimationController _settleCtrl;
  double _width = 0;
  bool _dragging = false;
  bool _canShell = false;
  bool? _horizontal;
  double _dx = 0;
  double _dy = 0;
  int? _pointer;
  VelocityTracker? _velocity;

  int _pageForTab(int tab) {
    final i = ShellTabs.pageIndex(tab);
    if (i >= 0) return i;
    return _motion.page;
  }

  double _pageWidth(BuildContext context) =>
      _width > 0 ? _width : MediaQuery.sizeOf(context).width;

  Duration _settleDuration(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : _settle;

  @override
  void initState() {
    super.initState();
    final initial = ShellTabs.pageIndex(widget.tabIndex);
    _motion = _ShellMotion(page: initial >= 0 ? initial : 0);
    _settleCtrl = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        _motion.setDrag(_settleCtrl.value);
        _motion.setBusy(_settleCtrl.isAnimating || _dragging);
      });
    _settleCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _motion.setBusy(_dragging);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ShellPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabIndex == widget.tabIndex) return;
    if (_dragging || _pointer != null) {
      _dragging = false;
      _pointer = null;
      _canShell = false;
      _horizontal = null;
      _velocity = null;
    }
    final next = _pageForTab(widget.tabIndex);
    if (next == _motion.page) {
      if (_motion.drag.abs() > 0.5) _settleDrag();
      return;
    }
    _animateToPage(next);
  }

  @override
  void dispose() {
    _settleCtrl.dispose();
    _motion.dispose();
    super.dispose();
  }

  bool _overHorizontalScrollable(Offset globalPosition) {
    final box = context.findRenderObject();
    if (box is! RenderBox) return false;
    final result = BoxHitTestResult();
    final local = box.globalToLocal(globalPosition);
    if (!box.hitTest(result, position: local)) return false;
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderViewportBase) {
        if (axisDirectionToAxis(target.axisDirection) == Axis.horizontal) {
          return true;
        }
      }
    }
    return false;
  }

  void _animateToPage(int next) {
    if (next == _motion.page) return;
    final width = _pageWidth(context);
    final adjusted = _motion.drag + (next - _motion.page) * width;
    _settleCtrl.stop();
    _motion.jump(page: next, drag: adjusted, busy: true);
    _settleCtrl
      ..value = adjusted
      ..animateTo(
        0,
        duration: _settleDuration(context),
        curve: Curves.easeOutCubic,
      );
  }

  void _settleDrag() {
    final from = _motion.drag;
    _motion.setBusy(true);
    _settleCtrl
      ..stop()
      ..value = from
      ..animateTo(
        0,
        duration: _settleDuration(context),
        curve: Curves.easeOutCubic,
      );
  }

  void _commitOrCancel(double width, double vx) {
    final page = _motion.page;
    var target = page;
    if (_motion.drag <= -width * _commitFraction || vx < -_minFling) {
      if (page < ShellTabs.pageOrder.length - 1) target = page + 1;
    } else if (_motion.drag >= width * _commitFraction || vx > _minFling) {
      if (page > 0) target = page - 1;
    }

    if (target != page) {
      final tab = ShellTabs.pageOrder[target];
      final adjusted = _motion.drag + (target - page) * width;
      _motion.jump(page: target, drag: adjusted, busy: true);
      widget.onTabIndex(tab);
    }

    _settleDrag();
  }

  void _onPointerDown(PointerDownEvent e, double width) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    _width = width;
    final tab = ShellTabs.pageOrder[_motion.page];
    final onAskMe = tab == ShellTabs.askMe;
    final edgeOk = !onAskMe || ShellEdge.contains(e.localPosition.dx, width);
    final blockedByChild = _overHorizontalScrollable(e.position);
    _canShell = edgeOk && !blockedByChild;
    _dragging = false;
    _horizontal = null;
    _dx = 0;
    _dy = 0;
    _velocity = VelocityTracker.withKind(e.kind)
      ..addPosition(e.timeStamp, e.position);
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _pointer || !_canShell) return;
    _velocity?.addPosition(e.timeStamp, e.position);
    _dx += e.delta.dx;
    _dy += e.delta.dy;
    if (_horizontal == null) {
      if (_dx.abs() < _axisSlop && _dy.abs() < _axisSlop) return;
      _horizontal = _dx.abs() > _dy.abs();
      if (_horizontal!) {
        _dragging = true;
        _settleCtrl.stop();
        _motion.setBusy(true);
      } else {
        return;
      }
    }
    if (!_dragging) return;
    _motion.setDrag(_motion.drag + e.delta.dx);
  }

  void _onPointerUp(PointerUpEvent e, double width) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (!_dragging) {
      _canShell = false;
      _velocity = null;
      if (_motion.drag.abs() > 0.5) _settleDrag();
      return;
    }
    _dragging = false;
    _canShell = false;
    _velocity?.addPosition(e.timeStamp, e.position);
    final vx = _velocity?.getVelocity().pixelsPerSecond.dx ?? 0;
    _velocity = null;
    _commitOrCancel(width, vx);
  }

  void _onPointerCancel(PointerCancelEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    if (!_dragging) {
      _canShell = false;
      _velocity = null;
      if (_motion.drag.abs() > 0.5) _settleDrag();
      return;
    }
    _dragging = false;
    _canShell = false;
    _velocity = null;
    _commitOrCancel(_pageWidth(context), 0);
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.children.length == ShellTabs.pageOrder.length);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => _onPointerDown(e, width),
          onPointerMove: _onPointerMove,
          onPointerUp: (e) => _onPointerUp(e, width),
          onPointerCancel: _onPointerCancel,
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                ListenableBuilder(
                  listenable: _motion,
                  builder: (context, child) => _ShellPageLayer(
                    index: i,
                    page: _motion.page,
                    drag: _motion.drag,
                    width: width,
                    ignoring: _motion.busy,
                    child: child!,
                  ),
                  child: widget.children[i],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShellPageLayer extends StatelessWidget {
  const _ShellPageLayer({
    required this.index,
    required this.page,
    required this.drag,
    required this.width,
    required this.ignoring,
    required this.child,
  });

  final int index;
  final int page;
  final double drag;
  final double width;
  final bool ignoring;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var offset = drag;
    if (page == 0 && offset > 0) offset *= 0.35;
    if (page == ShellTabs.pageOrder.length - 1 && offset < 0) offset *= 0.35;

    final dx = (index - page) * width + offset;
    final showing = index == page || dx.abs() < width;
    return Positioned.fill(
      child: Offstage(
        offstage: !showing,
        child: TickerMode(
          enabled: showing,
          child: IgnorePointer(
            ignoring: ignoring || dx.abs() > 1,
            child: Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
