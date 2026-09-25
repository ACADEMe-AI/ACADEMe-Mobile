import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

enum PebbyState {
  idle, wave, think, cheer, sleep, sad, wow, determined, confused, happy,
  excited, laughing, proud, loved, surprised, tired, shy, focused,
  actAchieved, actHighfive, actIdea, actReading, actSolving, actStudying,
  adaptive, chat, cta, hero, mastery, practice, upload, studying,
  turnFront, turnBack, turnSide, turnThreeQuarter, turnThreeQuarterBack,
  cheering, peekLeft, peekRight, dissolveIn, dissolveOut, summon,
  // the stable motion ids from academe.cc/design/character/motion
  encourage, celebrateSmall, celebrateBig, sleepy,
  // ids the design system spells differently from the motion states
  thinking, sleeping, celebrate;

  double get poseValue => index.toDouble();

  bool get isOneShot =>
      this == surprised ||
      this == dissolveIn ||
      this == dissolveOut ||
      this == summon;

  /// The design system caps big celebrations at roughly one per five minutes.
  bool get isBigMoment => this == celebrateBig || this == celebrate;

  Duration get oneShotLength => switch (this) {
        dissolveIn => const Duration(milliseconds: 1100),
        dissolveOut => const Duration(milliseconds: 850),
        summon => const Duration(milliseconds: 1950),
        surprised => const Duration(milliseconds: 4000),
        _ => Duration.zero,
      };
}

/// How Pebby arrives before settling into [PebbyRive.state].
enum PebbyEntrance { none, dissolve, summon }

class PebbyRive extends StatefulWidget {
  const PebbyRive({
    super.key,
    this.state = PebbyState.idle,
    this.size = 160,
    this.reduceMotion = false,
    this.appear = 1.0,
    this.entrance = PebbyEntrance.none,
    this.fit = BoxFit.contain,
    this.asset = 'assets/academe/mascot/animations/pebby.riv',
    this.onReady,
  });

  final PebbyState state;
  final double size;
  final bool reduceMotion;

  /// 0 fades Pebby out completely, 1 shows him. Drive it from a page
  /// transition to dissolve him in or out of a screen.
  ///
  /// The fade is applied to the composited widget rather than to the
  /// artboard's own `appear` input, because Rive fades each shape on its own:
  /// half-way through you would see the arms and tufts through the body
  /// instead of one character.
  final double appear;

  /// Played once on first build, then [state] takes over.
  final PebbyEntrance entrance;

  final BoxFit fit;
  final String asset;
  final VoidCallback? onReady;

  @override
  State<PebbyRive> createState() => _PebbyRiveState();
}

class _PebbyRiveState extends State<PebbyRive> {
  Artboard? _artboard;
  SMINumber? _pose;
  SMINumber? _appear;
  SMIBool? _reduceMotion;
  Timer? _entranceTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final file = await RiveFile.asset(widget.asset);
    final artboard = file.mainArtboard.instance();
    final controller = StateMachineController.fromArtboard(artboard, 'PebbySM');
    if (controller == null) {
      throw StateError('pebby.riv has no state machine named PebbySM');
    }
    artboard.addController(controller);
    _pose = controller.findInput<double>('pose') as SMINumber?;
    _appear = controller.findInput<double>('appear') as SMINumber?;
    _reduceMotion = controller.findInput<bool>('reduceMotion') as SMIBool?;

    final intro = switch (widget.entrance) {
      PebbyEntrance.dissolve => PebbyState.dissolveIn,
      PebbyEntrance.summon => PebbyState.summon,
      PebbyEntrance.none => null,
    };
    _apply(intro ?? widget.state);
    if (intro != null) {
      _entranceTimer = Timer(intro.oneShotLength, () {
        if (mounted) _apply(widget.state);
      });
    }
    if (mounted) {
      setState(() => _artboard = artboard);
      widget.onReady?.call();
    }
  }

  void _apply(PebbyState state) {
    _pose?.value = state.poseValue;
    _appear?.value = 100;
    _reduceMotion?.value = widget.reduceMotion;
  }

  @override
  void didUpdateWidget(PebbyRive old) {
    super.didUpdateWidget(old);
    final settled = _entranceTimer == null || !_entranceTimer!.isActive;
    if (old.state != widget.state && settled) {
      _pose?.value = widget.state.poseValue;
    }
    if (old.reduceMotion != widget.reduceMotion) {
      _reduceMotion?.value = widget.reduceMotion;
    }
  }

  @override
  Widget build(BuildContext context) {
    final artboard = _artboard;
    Widget child = SizedBox(
      width: widget.size,
      height: widget.size,
      child: artboard == null
          ? const SizedBox.shrink()
          : Rive(artboard: artboard, fit: widget.fit),
    );
    final alpha = widget.appear.clamp(0.0, 1.0);
    if (alpha < 1.0) {
      child = Opacity(opacity: alpha, child: child);
    }
    return child;
  }
}
