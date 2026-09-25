import 'package:flutter/widgets.dart';

class RiseIn extends StatelessWidget {
  const RiseIn({super.key, required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - animation.value) * 14),
          child: child,
        ),
        child: child,
      ),
    );
  }
}
