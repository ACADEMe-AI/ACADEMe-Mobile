import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

abstract final class PebbyPose {
  static const idle = 0.0;
  static const wave = 1.0;
  static const sleep = 4.0;
  static const think = 2.0;
  static const happy = 9.0;
  static const shy = 16.0;
  static const focused = 17.0;
  static const reading = 21.0;
  static const peekRight = 39.0;
  static const encourage = 43.0;
  static const celebrateSmall = 44.0;
  static const celebrateBig = 45.0;
  static const coverEyes = 50.0;
  static const working = 51.0;
  static const wakeUp = 52.0;
}

class PebbyStandIn extends InheritedWidget {
  const PebbyStandIn({super.key, required super.child});

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PebbyStandIn>() != null;

  @override
  bool updateShouldNotify(PebbyStandIn oldWidget) => false;
}

class Pebby extends StatefulWidget {
  const Pebby({super.key, required this.pose});

  final double pose;

  @override
  State<Pebby> createState() => _PebbyState();
}

class _PebbyState extends State<Pebby> {
  File? _file;
  RiveWidgetController? _controller;
  NumberInput? _appear;
  NumberInput? _pose;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading || PebbyStandIn.isActive(context)) return;
    _isLoading = true;
    _load();
  }

  Future<void> _load() async {
    final file = await File.asset(
      'assets/academe/mascot/animations/pebby.riv',
      riveFactory: Factory.rive,
    );
    if (file == null) return;
    if (!mounted) {
      file.dispose();
      return;
    }
    final controller = RiveWidgetController(
      file,
      artboardSelector: ArtboardSelector.byName('Pebby'),
      stateMachineSelector: StateMachineSelector.byName('PebbySM'),
    );
    // ignore: deprecated_member_use
    _appear = controller.stateMachine.number('appear')?..value = 100;
    // ignore: deprecated_member_use
    _pose = controller.stateMachine.number('pose')?..value = widget.pose;
    setState(() {
      _file = file;
      _controller = controller;
    });
  }

  @override
  void didUpdateWidget(Pebby oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose != widget.pose) _pose?.value = widget.pose;
  }

  @override
  void dispose() {
    _appear?.dispose();
    _pose?.dispose();
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return const SizedBox.expand();
    return RiveWidget(controller: controller);
  }
}
